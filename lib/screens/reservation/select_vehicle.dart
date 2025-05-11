import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkintime/screens/reservation/book_parking.dart';

class SelectVehiclePage extends StatefulWidget {
  final String kodeslot;

  const SelectVehiclePage({
    Key? key,
    required this.kodeslot,
  }) : super(key: key);

  @override
  _SelectVehiclePageState createState() => _SelectVehiclePageState();
}

class _SelectVehiclePageState extends State<SelectVehiclePage> {
  int? selectedVehicleIndex;
  List<Map<String, String>> vehicles = [];
  bool isLoading = true;
  String? idAkun;

  @override
  void initState() {
    super.initState();
    loadIdAkun();
  }

  Future<void> loadIdAkun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idAkun = prefs.getString('id_akun');

    if (idAkun != null) {
      fetchVehicles();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchVehicles() async {
    try {
      // Mengambil data kendaraan dari API
      final response = await http.get(Uri.parse(
        'https://app.parkintime.web.id/flutter/get_car.php?id_akun=$idAkun',
      ));

      // Debugging response body
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['status'] == true) {
          final List<dynamic> data = json['data'];

          // Map data kendaraan ke dalam list vehicles
          setState(() {
            vehicles = data.map<Map<String, String>>((item) => {
              'brand': item['merek'] ?? 'No brand',  // Menggunakan merek
              'plate': item['no_kendaraan'] ?? 'No plate',  // Menggunakan no_kendaraan
              'image': 'assets/car.png',  // Gambar default jika tidak ada gambar
            }).toList();
            isLoading = false;
          });
        } else {
          throw Exception('No vehicles found or status is false');
        }
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.green,
        title: Text("Select Your Vehicle"),
        leading: BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())  // Menunggu data
                  : vehicles.isEmpty
                  ? Center(  // Tidak ada kendaraan
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Tidak ada kendaraan yang terdaftar."),
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/addCar');
                      },
                      child: Text(
                        "Tambahkan kendaraan",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedVehicleIndex = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Image.asset(vehicle['image']!, height: 60),  // Gambar kendaraan
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle['brand']!,  // Merek kendaraan
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  vehicle['plate']!,  // Nomor kendaraan
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Radio<int>(
                            value: index,
                            groupValue: selectedVehicleIndex,
                            onChanged: (value) {
                              setState(() {
                                selectedVehicleIndex = value;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: ElevatedButton(
                onPressed: selectedVehicleIndex != null
                    ? () {
                  final selectedVehicle = vehicles[selectedVehicleIndex!];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookParkingDetailsPage(
                        pricePerHour: 5000,
                        kodeslot: widget.kodeslot,
                        vehiclePlate: selectedVehicle['plate']!,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Continue", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
