import 'package:flutter/material.dart';

class TicketPage extends StatelessWidget {
  const TicketPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Ticket', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        width: double.infinity,
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nomor Plat & Jenis Kendaraan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nomor Plat:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'BP 1234 HJ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jenis Kendaraan',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Mobil',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  // Informasi Parkir
                  buildInfoRow('Parking Area:', 'Mega Mall Batam Center'),
                  buildInfoRow('Address:', 'Jl. Engku Putri No.1, Belian'),
                  buildInfoRow('Vehicle:', 'Daihatsu (BP 1234 AA)'),
                  buildInfoRow('Parking Spot:', '1st Floor (A-06)'),
                  buildInfoRow('Waktu Masuk:', '12 March 2025, 09:00'),
                  const SizedBox(height: 20),
                  // QR Code
                  Center(
                    child: Container(
                      height: 150,
                      width: 150,
                      color: Colors.black12,
                      child: const Icon(Icons.qr_code, size: 100),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  // Tarif
                  buildInfoRow('Tarif per jam:', 'Rp 5.000'),
                  buildInfoRow('Total:', 'Rp 20.000'),
                  const SizedBox(height: 20),
                  // Status Pembayaran
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          'Status Pembayaran: Lunas',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Tombol Simpan Ticket
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi Simpan Ticket (Optional bisa ditambahkan nanti)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Simpan Ticket',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
