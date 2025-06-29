import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddCarScreen extends StatefulWidget {
  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _chassisController = TextEditingController();

  Map<String, String>? _vehicleData;
  bool _isLoading = false;
  String? _message;

  final String _fetchUrl = "https://app.parkintime.web.id/flutter/car.php";
  final String _submitUrl = "https://app.parkintime.web.id/flutter/add_car.php";

  Future<void> _fetchVehicleData() async {
    final plat = _plateController.text.trim().toUpperCase();
    final rangka = _chassisController.text.trim();

    if (plat.isEmpty || rangka.length != 4) {
      setState(() {
        _vehicleData = null;
        _message = "Enter valid registration number & 4-digit chassis number.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final response = await http.post(
        Uri.parse(_fetchUrl),
        body: {"noreg": plat, "bbn": '0', "norangka": rangka},
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        final info = Map<String, dynamic>.from(data['data']);
        setState(() {
          _vehicleData = {
            "Registration Number": info['no_kendaraan'] ?? '',
            "Name of Owner": info['pemilik'] ?? '',
            "Brand": info['merek'] ?? '',
            "Type": info['tipe'] ?? '',
            "Category": info['kategori'] ?? '',
            "Color": info['warna'] ?? '',
            "Manufacture Year": info['tahun'] ?? '',
            "Cylinder Capacity": info['kapasitas'] ?? '',
            "Energy Source": info['energi'] ?? '',
            "License Plate Color": info['warna_plat'] ?? '',
          };
        });
      } else {
        setState(() {
          _vehicleData = null;
          _message = data['message'] ?? 'Failed to retrieve data';
        });
      }
    } catch (e) {
      setState(() {
        _vehicleData = null;
        _message = "Failed to connect to server";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCar() async {
    if (_vehicleData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vehicle data not available")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final idAkun = prefs.getInt('id_akun');

    if (idAkun == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_submitUrl),
        body: {
          'id_akun': idAkun.toString(),
          'no_kendaraan': _vehicleData!["Registration Number"] ?? '',
          'pemilik': _vehicleData!["Name of Owner"] ?? '',
          'merek': _vehicleData!["Brand"] ?? '',
          'tipe': _vehicleData!["Type"] ?? '',
          'kategori': _vehicleData!["Category"] ?? '',
          'warna': _vehicleData!["Color"] ?? '',
          'tahun': _vehicleData!["Manufacture Year"] ?? '',
          'kapasitas': _vehicleData!["Cylinder Capacity"] ?? '',
          'energi': _vehicleData!["Energy Source"] ?? '',
          'warna_plat': _vehicleData!["License Plate Color"] ?? '',
        },
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Car added successfully!")),
        );
        Navigator.pop(context,true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to add car")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _chassisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 227, 227),
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Color(0xFF629584),
         centerTitle: true, // ✅ Tengahin judul
        title: Text(
          'Add Car',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 28,
          ), // ✅ Icon back lebih tebal
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("* Vehicle data must match actual vehicle data",
                style: TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 16),

            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Center(
                child: TextField(
                  controller: _plateController,
                  onChanged: (_) => _fetchVehicleData(),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    UpperCaseTextFormatter(),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "BP1234YY",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text("Last 4 digits of chassis number"),
            const SizedBox(height: 8),
            TextField(
              controller: _chassisController,
              onChanged: (_) => _fetchVehicleData(),
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "1234",
              ),
            ),

            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _message!,
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),

            if (_vehicleData != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _vehicleData!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text("${entry.key}:",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(entry.value,
                                style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _vehicleData != null && !_isLoading ? _addCar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Add Car", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ubah input ke huruf kapital
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
