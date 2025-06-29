import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkintime/screens/reservation/book_parking.dart';


class SelectVehiclePage extends StatefulWidget {
  final String kodeslot;
  final String id_lahan;

  const SelectVehiclePage({
    Key? key,
    required this.kodeslot,
    required this.id_lahan,
  }) : super(key: key);

  @override
  _SelectVehiclePageState createState() => _SelectVehiclePageState();
}

class _SelectVehiclePageState extends State<SelectVehiclePage> {
  int? selectedVehicleIndex;
  List<Map<String, String>> vehicles = [];
  bool isLoading = true;
  String? idAkun;
  int? tarifPerJam;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await loadIdAkun();
    if (idAkun != null) {
      await Future.wait([
        fetchVehicles(),
        fetchTarifLahan(),
      ]);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadIdAkun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idAkun = prefs.getInt('id_akun')?.toString();
    print('Debug: idAkun yang diambil dari SharedPreferences: $idAkun');
  }

  Future<void> fetchTarifLahan() async {
    try {
      print('Debug: Memulai fetchTarifLahan untuk id_lahan: ${widget.id_lahan}');
      final response = await http.get(Uri.parse(
        'https://app.parkintime.web.id/flutter/get_lahan.php',
      ));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // --- Enhanced Debugging ---
        print('Debug: Full response dari get_lahan.php: $jsonResponse');

        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];

          // Mencari data lahan yang cocok
          final lahanData = data.firstWhere(
                (lahan) {
              // Menambahkan print untuk setiap item yang diperiksa
              print('Debug: Memeriksa lahan dengan id: ${lahan['id']} vs widget.id_lahan: ${widget.id_lahan}');
              return lahan['id'].toString() == widget.id_lahan;
            },
            orElse: () => null,
          );

          if (lahanData != null) {
            print('Debug: Lahan ditemukan: $lahanData');
            String tarifString = lahanData['tarif_per_jam'].toString();
            print('Debug: Nilai tarif_per_jam dari API (string): "$tarifString"');

            // --- PERBAIKAN UTAMA ---
            // Menggunakan double.tryParse untuk menangani format desimal "5000.00"
            // kemudian diubah ke integer.
            double? tarifDouble = double.tryParse(tarifString);

            if (tarifDouble != null) {
              setState(() {
                tarifPerJam = tarifDouble.toInt();
              });
              print('Debug: Parsing tarif berhasil. tarifPerJam diatur ke: $tarifPerJam');
            } else {
              print('Debug: Gagal mem-parsing tarif. Nilai tidak valid: "$tarifString"');
            }

          } else {
            print('Debug: Error! Lahan dengan id ${widget.id_lahan} tidak ditemukan dalam response API.');
          }
        } else {
          print('Debug: API response success = false. Message: ${jsonResponse['message']}');
        }
      } else {
        print('Debug: Error! Gagal memuat info lahan. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Debug: Exception terjadi di fetchTarifLahan: $e');
    }
  }


  Future<void> fetchVehicles() async {
    // ... (kode fetchVehicles tidak berubah) ...
    try {
      print('Fetching vehicles...');
      final response = await http.get(Uri.parse(
        'https://app.parkintime.web.id/flutter/get_car.php?id_akun=$idAkun',
      ));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json['status'] == true) {
          final List<dynamic> data = json['data'];
          setState(() {
            vehicles = data.map<Map<String, String>>((item) => {
              'carid': item['id']?.toString() ?? '',
              'brand': item['merek'] ?? 'No brand',
              'type': item['tipe'] ?? 'No type',
              'plate': item['no_kendaraan'] ?? 'No plate',
              'image': 'assets/car.png',
            }).toList();
          });
        }
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = selectedVehicleIndex != null && tarifPerJam != null;

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
                  ? Center(child: CircularProgressIndicator())
                  : vehicles.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("There are no vehicles registered"),
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        // Ganti dengan navigasi yang benar
                        // Navigator.pushNamed(context, '/AddCarScreen');
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
                        border: selectedVehicleIndex == index
                            ? Border.all(color: Colors.green, width: 2)
                            : null,
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
                onPressed: canContinue
                    ? () {
                  final selectedVehicle = vehicles[selectedVehicleIndex!];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookParkingDetailsPage(
                        kodeslot: widget.kodeslot,
                        id_lahan: widget.id_lahan,
                        vehicleId: selectedVehicle['carid']!,
                        vehiclePlate: selectedVehicle['plate']!,
                        pricePerHour: tarifPerJam!,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canContinue ? Colors.green : Colors.grey,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Continue", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
