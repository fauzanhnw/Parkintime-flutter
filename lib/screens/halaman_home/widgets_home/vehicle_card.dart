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
    return SizedBox(
      width: 320, // atau ukuran sesuai desain kamu
      child: Container(
        margin: const EdgeInsets.only(right: 12), // spasi antar card
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
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("$brand $type", style: const TextStyle(color: Colors.black54)),
                  Text("$color", style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
