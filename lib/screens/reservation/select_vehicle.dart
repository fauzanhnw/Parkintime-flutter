import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkintime/screens/reservation/book_parking.dart';
import 'package:parkintime/screens/my_car/add_car.dart';

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
    idAkun = prefs.getInt('id_akun')?.toString(); // Konversi ke String

    print('idAkun yang diambil: $idAkun');

    if (idAkun != null) {
      fetchVehicles();
    } else {
      print('idAkun tidak tersedia');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchVehicles() async {
    try {
      print('Fetching vehicles...');
      final response = await http.get(Uri.parse(
        'https://app.parkintime.web.id/flutter/get_car.php?id_akun=$idAkun',
      ));

      print('Response received: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print('Parsed JSON: $json');

        if (json['status'] == true) {
          final List<dynamic> data = json['data'];
          print('Vehicle data: $data');

          setState(() {
            vehicles = data.map<Map<String, String>>((item) => {
              'carid': item['id'] ?? '',
              'brand': item['merek'] ?? 'No brand',
              'type': item['tipe'] ?? 'No type',
              'plate': item['no_kendaraan'] ?? 'No plate',
              'image': 'assets/car.png',
            }).toList();
            isLoading = false;
          });
          print('isLoading status: $isLoading');
        } else {
          throw Exception('No vehicles found');
        }
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      print('Error: $e');
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
                    Text("There are no vehicles registered"),
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/AddCarScreen');
                      },
                      child: Text(
                        "Add Vehicle",
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
                          Image.asset(vehicle['image']!, height: 60),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle['plate']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  vehicle['brand']!,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  vehicle['type']!,
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
                        vehicleId: selectedVehicle['carid']!, vehiclePlate: '',
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
