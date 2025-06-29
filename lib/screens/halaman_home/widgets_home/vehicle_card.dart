import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final String plate;
  final String brand;
  final String type;
  final String color;

  const VehicleCard({
    super.key,
    required this.plate,
    required this.brand,
    required this.type,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gambar mobil
            Image.asset(
              'assets/car.png', // Ganti dengan path gambar Anda
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),

            const SizedBox(width: 12),

            // Garis vertikal pemisah
            Container(width: 1, height: 50, color: Colors.grey[300]),

            const SizedBox(width: 12),

            // Informasi kendaraan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$brand $type".toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plate.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
