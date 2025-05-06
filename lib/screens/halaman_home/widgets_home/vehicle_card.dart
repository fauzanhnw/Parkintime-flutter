import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final String plate;
  final String brand;
  final String type;
  final String color;

  const VehicleCard({
    required this.plate,
    required this.brand,
    required this.type,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car, size: 40, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plate, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("$brand $type", style: const TextStyle(color: Colors.black54)),
                Text("Color: $color", style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
