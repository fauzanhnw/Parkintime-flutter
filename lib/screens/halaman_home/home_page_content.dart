import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'widgets_home/Feature_item.dart';
import 'widgets_home/vehicle_card.dart';
import 'package:parkintime/screens/my_car/mycar_page.dart';
import 'package:parkintime/screens/checklot/checklotpage.dart';
import 'package:parkintime/screens/reservation/ReservasionPage.dart';
import 'package:parkintime/screens/ticket_page.dart';

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final List<Map<String, dynamic>> vehicles = [];
  String _userName = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAllData();

    // Refresh otomatis setiap 30 detik
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _loadAllData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadUserNameFromAPI(),
      _loadVehiclesFromAPI(),
    ]);
  }

  Future<void> _handleRefresh() async {
    await _loadAllData();
  }

  Future<void> _loadUserNameFromAPI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idAkun = prefs.getInt('id_akun') ?? 0;

      final response = await http.get(
        Uri.parse('https://app.parkintime.web.id/flutter/profile.php?id_akun=$idAkun'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final fullName = data['nama_lengkap'] ?? 'User';
          setState(() {
            _userName = _capitalizeEachWord(fullName);
          });
        } else {
          setState(() => _userName = 'User');
        }
      } else {
        setState(() => _userName = 'User');
      }
    } catch (e) {
      print("Error fetching user name: $e");
      setState(() => _userName = 'User');
    }
  }

  Future<void> _loadVehiclesFromAPI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idAkun = prefs.getInt('id_akun') ?? 0;

      final response = await http.get(
        Uri.parse('https://app.parkintime.web.id/flutter/get_car.php?id_akun=$idAkun'),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status']) {
          setState(() {
            vehicles.clear();
            vehicles.addAll(List<Map<String, dynamic>>.from(result['data']));
          });
        }
      }
    } catch (e) {
      print("Error loading vehicles: $e");
    }
  }

  String _capitalizeEachWord(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: _buildScrollableContent(context),
                ),
              ),
            ],
          ),
          Positioned(
            top: 160,
            left: 20,
            right: 20,
            child: _buildFeatureMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Color(0xFF2ECC40),
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 246, 250, 251),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset('assets/log.png', height: 30),
          ),
          const SizedBox(height: 40),
          Text(
            "Hi, $_userName",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 202, 225, 238),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FeatureItem(
            imagePath: 'assets/chek.png',
            title: "Check Lot",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CheckLotPage()),
            ),
          ),
          FeatureItem(
            imagePath: 'assets/reservation.png',
            title: "Reservation",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Reservasionpage()),
            ),
          ),
          FeatureItem(
            imagePath: 'assets/tik.png',
            title: "Ticket",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TicketPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 235, 229, 229),
      padding: const EdgeInsets.only(top: 100),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Car Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Car",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageVehiclePage(),
                        ),
                      );
                      if (result == true) {
                        _loadVehiclesFromAPI();
                      }
                    },
                    child: const Text(
                      "Manage Vehicle",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2ECC40),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: vehicles.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.directions_car,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "No cars added yet",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Column(
                children: vehicles.map((vehicle) {
                  return VehicleCard(
                    plate: vehicle['no_kendaraan'] ?? '-',
                    brand: vehicle['merek'] ?? '-',
                    type: vehicle['tipe'] ?? '-',
                    color: vehicle['warna'] ?? '-',
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 45),

            // Parking Spot (static for now)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 29),
              child: const Text(
                "Parking Spot",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 160,
              padding: const EdgeInsets.only(left: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildParkingCard("Mega Mall", 31),
                  const SizedBox(width: 15),
                  _buildParkingCard("Grand Mall", 12),
                  const SizedBox(width: 15),
                  _buildParkingCard("Nagoya Hill", 7),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingCard(String title, int available) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/spot.png"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Available $available",
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
