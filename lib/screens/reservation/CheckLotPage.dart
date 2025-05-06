import 'package:flutter/material.dart';
import 'package:parkintime/screens/reservation/select_vehicle.dart';

class CheckLotPage extends StatelessWidget {
  final List<Map<String, dynamic>> parkingSpots = [
    {
      "name": "Grand Batam Mall",
      "address": "Jl. Pembangunan, Batu Selicin, Lubuk Baja",
      "price": "Rp 5.000",
      "capacity": "80/100",
      "status": "Tersedia",
    },
    {
      "name": "Mega Mall Batam Center",
      "address": "Jl. Engku Putri No.1, Belian, Kec. Batam Kota",
      "price": "Rp 5.000",
      "capacity": "95/100",
      "status": "Hampir Penuh",
    },
    {
      "name": "Nagoya Hill Mall",
      "address": "Jl. Nagoya Hill, Lubuk Baja Kota, Kec. Lubuk Baja",
      "price": "Rp 5.000",
      "capacity": "100/100",
      "status": "Penuh",
    },
    {
      "name": "Grand Batam Mall",
      "address": "Jl. Pembangunan, Batu Selicin, Lubuk Baja",
      "price": "Rp 5.000",
      "capacity": "80/100",
      "status": "Tersedia",
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return Colors.green.shade100;
      case 'Hampir Penuh':
        return Colors.orange.shade100;
      case 'Penuh':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Tersedia':
        return Colors.green;
      case 'Hampir Penuh':
        return Colors.orange;
      case 'Penuh':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140),
        child: AppBar(
          backgroundColor: Colors.green,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BackButton(color: Colors.white),
                      Text(
                        'Reservation',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search parking location..',
                      prefixIcon: Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parkingSpots.length,
        itemBuilder: (context, index) {
          final spot = parkingSpots[index];
          final status = spot["status"];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        spot["name"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusTextColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  spot["address"],
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tarif per jam\n${spot["price"]}"),
                    Text("Kapasitas\n${spot["capacity"]}"),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SelectVehiclePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("Reservasi"),
                      ),
                    ),
                    SizedBox(width: 8),
                    _iconBox(
                      icon: Icons.navigation,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectVehiclePage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    _iconBox(
                      icon: Icons.share,
                      onTap: () {
                        // TODO: share function
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _iconBox({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
