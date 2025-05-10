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
  List<Map<String, dynamic>> parkingLots = [];
  String _userName = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAllData();
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
      _loadParkingLotsFromAPI(),
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
          final trimmedName = _limitWords(_capitalizeEachWord(fullName), 3);
          setState(() {
            _userName = trimmedName;
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

  Future<void> _loadParkingLotsFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('https://app.parkintime.web.id/flutter/get_lahan.php'),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          setState(() {
            parkingLots = List<Map<String, dynamic>>.from(result['data']);
          });
        }
      }
    } catch (e) {
      print("Error loading parking lots: $e");
    }
  }

  String _capitalizeEachWord(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _limitWords(String text, int maxWords) {
    final words = text.split(' ');
    if (words.length <= maxWords) return text;
    return words.sublist(0, maxWords).join(' ') + '...';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildHeader(),
                  Positioned(
                    bottom: -40,
                    left: 20,
                    right: 20,
                    child: _buildFeatureMenu(context),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMyCarSection(context),
              ),
              const SizedBox(height: 45),
              _buildParkingSpotSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Color(0xFF2ECC40),
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
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

  Widget _buildMyCarSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                  MaterialPageRoute(builder: (_) => ManageVehiclePage()),
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
        const SizedBox(height: 15),
        vehicles.isEmpty
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.all(2),
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
              Icon(Icons.directions_car, size: 50, color: Colors.grey),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "No cars added yet",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ],
          ),
        )
            : SizedBox(
          height: 100, // pastikan ini cukup untuk menampung tinggi card
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return VehicleCard(
                plate: vehicle['no_kendaraan'] ?? '-',
                brand: vehicle['merek'] ?? '-',
                type: vehicle['tipe'] ?? '-',
                color: vehicle['warna'] ?? '-',
              );
            },
          ),
        ),

      ],
    );
  }

  Widget _buildParkingSpotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 29),
          child: Text(
            "Parking Spot",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 160,
          padding: const EdgeInsets.only(left: 20),
          margin: const EdgeInsets.only(bottom: 20),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: parkingLots.length,
            itemBuilder: (context, index) {
              final lot = parkingLots[index];
              return _buildParkingCard(
                lot['nama_lokasi'] ?? 'Unknown',
                lot['foto'] ?? '',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParkingCard(String title, String foto) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
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
            height: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (foto != null && foto.isNotEmpty)
                    ? NetworkImage('https://app.parkintime.web.id/foto/$foto')
                    : AssetImage("assets/spot.png") as ImageProvider,
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
