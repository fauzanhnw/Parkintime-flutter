import 'package:flutter/material.dart';

class InformationSpotPage extends StatefulWidget {
  @override
  _InformationSpotPageState createState() => _InformationSpotPageState();
}

class _InformationSpotPageState extends State<InformationSpotPage> {
  int selectedFloor = 1;

  final Map<int, List<Map<String, dynamic>>> floorData = {
    1: [
      {
        'labels': ['', 'A-06'],
        'hasCar': [true, false],
      },
      {
        'labels': ['A-02', ''],
        'hasCar': [false, true],
      },
      {
        'labels': ['', 'A-04'],
        'hasCar': [true, false],
      },
      {'divider': true},
      {
        'labels': ['B-01', ''],
        'hasCar': [false, true],
      },
      {
        'labels': ['', 'B-05'],
        'hasCar': [true, false],
      },
      {
        'labels': ['B-03', 'B-04'],
        'hasCar': [false, false],
      },
    ],
    2: [
      {
        'labels': ['C-01', 'C-02'],
        'hasCar': [false, false],
      },
      {
        'labels': ['C-03', ''],
        'hasCar': [true, false],
      },
      {
        'labels': ['', 'C-05'],
        'hasCar': [true, false],
      },
      {'divider': true},
      {
        'labels': ['D-01', 'D-02'],
        'hasCar': [false, false],
      },
    ],
    3: [
      {
        'labels': ['E-01', 'E-02'],
        'hasCar': [false, false],
      },
      {
        'labels': ['E-03', 'E-04'],
        'hasCar': [false, true],
      },
      {'divider': true},
      {
        'labels': ['F-01', ''],
        'hasCar': [true, false],
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color(0xFF2ECC40),
        title: Text(
          'Information Spot',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Floor selector
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFloorButton(1, "1st Floor"),
                SizedBox(width: 8),
                _buildFloorButton(2, "2nd Floor"),
                SizedBox(width: 8),
                _buildFloorButton(3, "3rd Floor"),
              ],
            ),
          ),

          // Dynamic slot list
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children:
                    floorData[selectedFloor]!.map<Widget>((row) {
                      if (row.containsKey('divider')) {
                        return Divider(thickness: 1);
                      } else {
                        return _buildParkingRow(
                          List<String>.from(row['labels']),
                          List<bool>.from(row['hasCar']),
                        );
                      }
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorButton(int floor, String label) {
    final isSelected = floor == selectedFloor;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedFloor = floor;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF2ECC40) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Color(0xFF2ECC40)),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildParkingRow(List<String> labels, List<bool> hasCar) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(2, (index) {
          return Expanded(
            child: Container(
              height: 80,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color:
                    hasCar[index] ? Colors.green.shade50 : Colors.transparent,
                border: Border.all(
                  color: Colors.black26,
                  style: BorderStyle.solid,
                  width: labels[index].isNotEmpty ? 1 : 0,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  hasCar[index]
                      ? Image.asset(
                        'assets/car.png',
                      ) // Gambar mobil tampak atas
                      : Center(
                        child: Text(
                          labels[index],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
            ),
          );
        }),
      ),
    );
  }
}
