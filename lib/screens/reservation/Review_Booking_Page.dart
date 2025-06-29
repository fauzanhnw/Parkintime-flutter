import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:parkintime/screens/payment_webview_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewBookingPage extends StatefulWidget {
  final String kodeslot;
  final String id_lahan;
  final String carid;
  final String date;
  final String duration;
  final String hours;
  final int total_price;
  final String vehiclePlate;
  final int pricePerHour;

  const ReviewBookingPage({
    super.key,
    required this.kodeslot,
    required this.id_lahan,
    required this.carid,
    required this.date,
    required this.duration,
    required this.hours,
    required this.total_price,
    required this.vehiclePlate,
    required this.pricePerHour,
  });

  @override
  State<ReviewBookingPage> createState() => _ReviewBookingPageState();
}

class _ReviewBookingPageState extends State<ReviewBookingPage> {
  String? parkingArea;
  String? address;
  String? vehicleName;
  bool _isLoading = true;
  bool _isCreatingOrder = false;
  String? _idAkun;

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchPageDetails();
  }

  Future<void> _fetchPageDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _idAkun = prefs.getInt('id_akun')?.toString();

      await Future.wait([
        _fetchLahanDetails(),
        _fetchVehicleDetails(),
      ]);
    } catch (e) {
      print("Error fetching page details: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchLahanDetails() async {
    try {
      final response = await http.get(Uri.parse('https://app.parkintime.web.id/flutter/get_lahan.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final lahanData = data.firstWhere((l) => l['id'].toString() == widget.id_lahan, orElse: () => null);
        if (lahanData != null && mounted) {
          setState(() {
            parkingArea = lahanData['nama_lokasi'];
            address = lahanData['alamat'];
          });
        }
      }
    } catch (e) {
      print("Error fetching lahan: $e");
    }
  }

  Future<void> _fetchVehicleDetails() async {
    try {
      if (_idAkun == null) return;

      final response = await http.get(Uri.parse('https://app.parkintime.web.id/flutter/get_car.php?id_akun=$_idAkun'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final carData = data.firstWhere((c) => c['id'].toString() == widget.carid, orElse: () => null);
        if (carData != null && mounted) {
          setState(() {
            vehicleName = "${carData['merek'] ?? ''} ${carData['tipe'] ?? ''}".trim();
          });
        }
      }
    } catch (e) {
      print("Error fetching vehicle: $e");
    }
  }

  Future<void> _createBookingAndPay() async {
    if (_idAkun == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isCreatingOrder = true;
    });

    http.Response? response; // Variabel untuk menyimpan response

    try {
      final url = Uri.parse('https://app.parkintime.web.id/flutter/create_booking.php');

      final requestBody = {
        'id_akun': _idAkun,
        'id_slot': widget.kodeslot,
        'durasi': widget.duration.split(' ')[0],
        'biaya_total': widget.total_price,
        'waktu_masuk': "${widget.date} ${widget.hours.split(' - ')[0]}:00",
      };

      response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final String redirectUrl = responseData['redirect_url'];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebViewPage(
                paymentUrl: redirectUrl,
              ),
            ),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create booking.');
        }
      } else {
        throw Exception('Server Error. Status Code: ${response.statusCode}');
      }

    } catch (e) {
      // --- PERUBAHAN UNTUK DEBUGGING ---
      String errorMessage = e.toString();
      // Jika errornya adalah FormatException, tampilkan seluruh body response dari server
      if (e is FormatException && response != null) {
        errorMessage = "Failed to parse JSON. Server Response:\n${response.body}";
      }

      print("--- ERROR LOG ---");
      print(errorMessage);
      print("--- END ERROR LOG ---");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isCreatingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Create Booking'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  buildDetailRow('Parking Area', parkingArea ?? 'Loading...'),
                  buildDetailRow('Address', address ?? 'Loading...'),
                  buildDetailRow('Vehicle Plate', widget.vehiclePlate),
                  buildDetailRow('Vehicle', vehicleName ?? 'Loading...'),
                  buildDetailRow('Parking Spot', widget.kodeslot),
                  buildDetailRow('Date', widget.date),
                  buildDetailRow('Duration', widget.duration),
                  buildDetailRow('Hours', widget.hours),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  buildDetailRow('Amount', currencyFormatter.format(widget.pricePerHour), isPrice: true),
                  buildDetailRow('Duration', widget.duration),
                  const Divider(),
                  buildDetailRow('Total', currencyFormatter.format(widget.total_price), isBold: true, isPrice: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isCreatingOrder ? null : _createBookingAndPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.green.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isCreatingOrder
                ? CircularProgressIndicator(color: Colors.white)
                : const Text('Create Order & Continue', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value, {bool isBold = false, bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: isPrice ? TextOverflow.visible : TextOverflow.ellipsis,
              maxLines: isPrice ? null : 1,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: isBold ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
