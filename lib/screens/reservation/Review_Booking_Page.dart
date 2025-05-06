import 'package:flutter/material.dart';
import 'package:parkintime/screens/ticket_page.dart';

class ReviewBookingPage extends StatefulWidget {
  final String parkingArea;
  final String address;
  final String vehicle;
  final String parkingSpot;
  final String date;
  final String duration;
  final String hours;
  final int pricePerHour;

  const ReviewBookingPage({
    super.key,
    required this.parkingArea,
    required this.address,
    required this.vehicle,
    required this.parkingSpot,
    required this.date,
    required this.duration,
    required this.hours,
    required this.pricePerHour,
  });

  @override
  State<ReviewBookingPage> createState() => _ReviewBookingPageState();
}

class _ReviewBookingPageState extends State<ReviewBookingPage> {
  String selectedPayment = 'gopay';

  final List<String> paymentMethods = ['gopay', 'ovo', 'dana'];

  Map<String, Map<String, dynamic>> paymentInfo = {
    'gopay': {
      'name': 'GoPay',
      'color': Color(0xFF00AA13),
      'icon': Icons.account_balance_wallet_rounded,
    },
    'ovo': {
      'name': 'OVO',
      'color': Color(0xFF4B0082),
      'icon': Icons.account_balance_wallet_rounded,
    },
    'dana': {
      'name': 'DANA',
      'color': Color(0xFF008FE5),
      'icon': Icons.account_balance_wallet_rounded,
    },
  };

  @override
  Widget build(BuildContext context) {
    int durationInHours = int.tryParse(widget.duration.split(' ').first) ?? 1;
    int totalPrice = durationInHours * widget.pricePerHour;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Booking'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Detail Info ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  buildDetailRow('Parking Area', widget.parkingArea),
                  buildDetailRow('Address', widget.address),
                  buildDetailRow('Vehicle', widget.vehicle),
                  buildDetailRow('Parking Spot', widget.parkingSpot),
                  buildDetailRow('Date', widget.date),
                  buildDetailRow('Duration', widget.duration),
                  buildDetailRow('Hours', widget.hours),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Price Info ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  buildDetailRow('Amount', 'Rp ${widget.pricePerHour}'),
                  buildDetailRow('Duration', '${widget.duration}'),
                  const Divider(),
                  buildDetailRow('Total', 'Rp $totalPrice', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Payment Method ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: paymentInfo[selectedPayment]!['color'],
                        child: Icon(
                          paymentInfo[selectedPayment]!['icon'],
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        paymentInfo[selectedPayment]!['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return ListView(
                            shrinkWrap: true,
                            children:
                                paymentMethods.map((method) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor:
                                          paymentInfo[method]!['color'],
                                      child: Icon(
                                        paymentInfo[method]!['icon'],
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      paymentInfo[method]!['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedPayment = method;
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                }).toList(),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Change',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Confirm Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // supaya harus pilih tombol
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Successful',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Successfully made payment for\nyour parking',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Tutup dialog
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const TicketPage(),
                                      ),
                                    );
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('View Parking Ticket'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Tutup popup
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
    );
  }

  Widget buildDetailRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
