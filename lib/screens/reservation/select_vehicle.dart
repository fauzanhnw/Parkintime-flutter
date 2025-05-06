import 'package:flutter/material.dart';
import 'package:parkintime/screens/reservation/book_parking.dart';

class SelectVehiclePage extends StatefulWidget {
  @override
  _SelectVehiclePageState createState() => _SelectVehiclePageState();
}

class _SelectVehiclePageState extends State<SelectVehiclePage> {
  int? selectedVehicleIndex;

  final List<Map<String, String>> vehicles = [
    {"brand": "Daihatsu", "plate": "BP 1234 AA", "image": "assets/car.png"},
    {"brand": "Toyota", "plate": "BP 2341 AA", "image": "assets/car.png"},
    {"brand": "Honda Civic", "plate": "BP 3412 AA", "image": "assets/car.png"},
    {"brand": "Hyundai", "plate": "BP 4123 AA", "image": "assets/car.png"},
  ];

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
              child: ListView.builder(
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
                                  vehicle['brand']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  vehicle['plate']!,
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
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24,
              ), // <- tidak terlalu bawah
              child: ElevatedButton(
                onPressed:
                    selectedVehicleIndex != null
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BookParkingDetailsPage(
                                    pricePerHour: 5000,
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
