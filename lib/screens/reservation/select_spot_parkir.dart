import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:parkintime/screens/reservation/review_booking_page.dart';

class ParkingLotDetailPage extends StatefulWidget {
  final String spotName;

  const ParkingLotDetailPage({required this.spotName, super.key});

  @override
  State<ParkingLotDetailPage> createState() => _ParkingLotDetailPageState();
}

class _ParkingLotDetailPageState extends State<ParkingLotDetailPage> {
  int selectedFloor = 1;
  String? selectedSlot;

  final Map<int, List<String>> slotData = {
    1: ['A-02', 'A-04', 'A-06', 'B-01', 'B-05'],
    2: ['C-01', 'C-02', 'C-03'],
    3: ['D-01', 'D-02'],
  };

  final List<String> occupiedSlots = ['A-02', 'A-04', 'B-05'];

  @override
  Widget build(BuildContext context) {
    final slots = slotData[selectedFloor] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Parking Spot'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                [1, 2, 3].map((floor) {
                  final isSelected = selectedFloor == floor;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child:
                        isSelected
                            ? ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              child: Text('${floor}st Floor'),
                            )
                            : OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedFloor = floor;
                                  selectedSlot = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              child: Text(
                                '${floor}st Floor',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: (slots.length / 2).ceil(),
                itemBuilder: (context, index) {
                  final leftIndex = index * 2;
                  final rightIndex = leftIndex + 1;

                  return Column(
                    children: [
                      Row(
                        children: [
                          buildSlot(
                            slots.length > leftIndex ? slots[leftIndex] : null,
                          ),
                          buildSlot(
                            slots.length > rightIndex
                                ? slots[rightIndex]
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed:
                  selectedSlot == null
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ReviewBookingPage(
                                  parkingArea: 'Mega Mall Batam Center',
                                  address: 'Jl. Engku Putri No.1, Belian',
                                  vehicle: 'Daihatsu (BP 1234 AA)',
                                  parkingSpot: '1st Floor ($selectedSlot)',
                                  date: '12 March 2025',
                                  duration: '4 hours',
                                  hours: '09:00 AM - 12:00 PM',
                                  pricePerHour: 5000,
                                ),
                          ),
                        );
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlot(String? slot) {
    final isOccupied = slot != null && occupiedSlots.contains(slot);
    final isSelected = slot == selectedSlot;

    return Expanded(
      child: GestureDetector(
        onTap:
            (slot == null || isOccupied)
                ? null
                : () {
                  setState(() {
                    selectedSlot = slot;
                  });
                },
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 1, end: isSelected ? 1.05 : 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.all(6),
                height: 80,
                child:
                    isOccupied
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/car.png',
                            fit: BoxFit.contain,
                          ),
                        )
                        : Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.yellow : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            color: Colors.green,
                            strokeWidth: 2,
                            dashPattern: [5, 4],
                            child: Center(
                              child: Text(
                                slot ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
              ),
            );
          },
        ),
      ),
    );
  }
}
