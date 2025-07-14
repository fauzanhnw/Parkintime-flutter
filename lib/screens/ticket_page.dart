import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

// Model untuk menampung data tiket dari API
class Ticket {
  final String orderId;
  final String status;
  final String nomorPlat;
  final String jenisKendaraan;
  final String parkingArea;
  final String address;
  final String vehicle;
  final String parkingSpot;
  final String waktuMasuk;
  final String qrData;
  final String tarifPerJam;
  final String total;
  final String statusPembayaran;

  Ticket({
    required this.orderId,
    required this.status,
    required this.nomorPlat,
    required this.jenisKendaraan,
    required this.parkingArea,
    required this.address,
    required this.vehicle,
    required this.parkingSpot,
    required this.waktuMasuk,
    required this.qrData,
    required this.tarifPerJam,
    required this.total,
    required this.statusPembayaran,
  });

  // Factory constructor untuk membuat instance Ticket dari JSON
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      orderId: json['order_id'] ?? '',
      // Normalisasi status ke huruf kecil untuk konsistensi
      status: (json['status'] as String? ?? 'Unknown').toLowerCase(),
      nomorPlat: json['nomor_plat'],
      jenisKendaraan: json['jenis_kendaraan'],
      parkingArea: json['parking_area'],
      address: json['address'],
      vehicle: json['vehicle'],
      parkingSpot: json['parking_spot'],
      waktuMasuk: json['waktu_masuk'],
      qrData: json['qr_data'],
      tarifPerJam: json['tarif_per_jam'],
      total: json['total'],
      statusPembayaran: json['status_pembayaran'],
    );
  }
}

class TicketPage extends StatefulWidget {
  final int ticketId; // ID tiket yang akan diambil

  const TicketPage({Key? key, required this.ticketId}) : super(key: key);

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  late Future<Ticket> futureTicket;

  @override
  void initState() {
    super.initState();
    futureTicket = fetchTicket();
  }

  // Fungsi untuk mengambil data dari API
  Future<Ticket> fetchTicket() async {
    // GANTI DENGAN URL API ANDA
    final apiUrl =
        'https://app.parkintime.web.id/flutter/tiket.php?id=${widget.ticketId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return Ticket.fromJson(jsonResponse['data']);
        } else {
          throw Exception('Gagal memuat tiket: ${jsonResponse['message']}');
        }
      } else {
        throw Exception(
          'Gagal terhubung ke server. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Gagal memuat data. Periksa koneksi internet Anda. Error: $e',
      );
    }
  }

  // --- FUNGSI UNTUK AKSI TOMBOL ---

  void _handlePayment(String orderId) {
    // TODO: Implementasikan logika navigasi ke Midtrans di sini
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membuka pembayaran untuk: $orderId')),
    );
  }

  void _cancelOrder(String orderId) {
    // TODO: Implementasikan logika untuk membatalkan pesanan (panggil API, dll)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membatalkan pesanan: $orderId')),
    );
    // Mungkin refresh halaman setelah berhasil
    // setState(() {
    //   futureTicket = fetchTicket();
    // });
  }

  void _deleteTicket(String orderId) {
    // TODO: Implementasikan logika untuk menghapus tiket
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Menghapus tiket: $orderId')),
    );
    // Mungkin kembali ke halaman sebelumnya setelah berhasil
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Color(0xFF629584),
        centerTitle: true,
        title: Text(
          'View Ticket',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Ticket>(
        future: futureTicket,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final ticket = snapshot.data!;
            return buildTicketBody(context, ticket);
          }
          return const Center(
            child: Text(
              'Tidak ada data tiket.',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget buildTicketBody(BuildContext context, Ticket ticket) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ticket.orderId,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    buildTicketStatusBadge(ticket.status),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildHeaderInfo('Nomor Plat:', ticket.nomorPlat),
                    buildHeaderInfo(
                      'Jenis Kendaraan',
                      ticket.jenisKendaraan,
                      isRight: true,
                    ),
                  ],
                ),
                const Divider(height: 30),
                buildInfoRow('Parking Area:', ticket.parkingArea),
                buildInfoRow('Address:', ticket.address),
                buildInfoRow('Vehicle:', ticket.vehicle),
                buildInfoRow('Parking Spot:', ticket.parkingSpot),
                buildInfoRow('Waktu Masuk:', ticket.waktuMasuk),
                const SizedBox(height: 20),
                Center(
                  child: QrImageView(
                    data: ticket.qrData,
                    version: QrVersions.auto,
                    size: 150.0,
                    gapless: false,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                buildInfoRow('Tarif per jam:', ticket.tarifPerJam),
                buildInfoRow('Total:', ticket.total),
                const SizedBox(height: 20),
                buildPaymentStatus(ticket.statusPembayaran),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ✅ TOMBOL DINAMIS BERDASARKAN STATUS
          _buildActionButtons(context, ticket),
        ],
      ),
    );
  }

  // ✅ WIDGET BARU UNTUK MEMBUAT TOMBOL KONDISIONAL
  Widget _buildActionButtons(BuildContext context, Ticket ticket) {
    switch (ticket.status) {
      case 'pending':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _handlePayment(ticket.orderId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Warna untuk aksi utama
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Lanjutkan Pembayaran',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => _cancelOrder(ticket.orderId),
                child: const Text(
                  'Batalkan Pesanan',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ),
          ],
        );
      case 'canceled':
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _deleteTicket(ticket.orderId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Warna untuk aksi destruktif
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Hapus Tiket',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        );
      default: // Untuk status lain ('valid', 'completed', dll.)
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This feature has not been implemented yet.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Save Ticket',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        );
    }
  }

  Widget buildHeaderInfo(String label, String value, {bool isRight = false}) {
    return Column(
      crossAxisAlignment:
      isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ PENAMBAHAN CASE UNTUK 'waiting for payment'
  Widget buildTicketStatusBadge(String status) {
    Color badgeColor;
    String displayText;

    switch (status) {
      case 'valid':
        badgeColor = Colors.blue;
        displayText = 'Valid';
        break;
      case 'completed':
        badgeColor = Colors.green;
        displayText = 'Completed';
        break;
      case 'canceled':
        badgeColor = Colors.red;
        displayText = 'Canceled';
        break;
      case 'waiting for payment': // <-- KASUS BARU
      case 'pending':
        badgeColor = Colors.orange;
        displayText = 'Menunggu Pembayaran'; // Teks lebih deskriptif
        break;
      default:
        badgeColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildPaymentStatus(String status) {
    bool isPaid = status.toLowerCase() == 'lunas';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPaid ? Colors.green : Colors.orange),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.error,
            color: isPaid ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 10),
          Text(
            'Status Pembayaran: $status',
            style: TextStyle(
              color: isPaid ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}