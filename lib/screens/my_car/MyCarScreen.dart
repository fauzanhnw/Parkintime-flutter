import 'package:flutter/material.dart';
import 'add_car.dart'; // Pastikan file ini ada di folder yang sama atau sesuaikan path-nya

class MyCarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Choose a Car", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [_buildCarCard(), SizedBox(height: 20), _buildEmptyCard()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCarScreen()),
          );
        },
      ),
    );
  }

  Widget _buildCarCard() {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BP 121 AN",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Divider(),
                Text("TOYOTA"),
                Text("CIVIC NISMO GTR"),
                Text("MERAH"),
                Text("MINIBUS"),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {},
                      child: Text("Manage"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {},
                      child: Text("Delete"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Image.asset(
            "assets/car.png", // Ganti dengan path gambar mobil sesuai kebutuhanmu
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Center(child: Text("No additional cars yet")),
    );
  }
}
