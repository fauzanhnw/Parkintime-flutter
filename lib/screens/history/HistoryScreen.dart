import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 0;

  final List<String> filters = ["Valid", "Complete", "Canceled"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          // AppBar Hijau (hanya header)
          Container(
            height: 70,
            width: double.infinity,
            color: Colors.green,
            alignment: Alignment.bottomCenter,
          ),

          // Tab Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(filters.length, (index) {
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          Divider(height: 1, thickness: 1),

          Expanded(child: _buildContentForTab()),
        ],
      ),
    );
  }

  Widget _buildContentForTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildValidHistory();
      case 1:
        return _buildCompleteHistory();
      case 2:
        return _buildCanceledHistory();
      default:
        return Container();
    }
  }

  Widget _buildValidHistory() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        _buildHistoryCard(
          ticket: "TICKET-1",
          date: "7 June 2025 - 10.00",
          location: "Mega Mall Batam",
          floor: "1st Floor",
          slot: "4A",
          duration: "3 Hours",
          statusWidget: _buildStatusBox(
            title: "Valid until",
            date: "7 June 2025",
            time: "13.00",
            color: Colors.blue,
          ),
        ),
        _buildHistoryCard(
          ticket: "TICKET-2",
          date: "7 June 2025 - 10.00",
          location: "Mega Mall Batam",
          floor: "1st Floor",
          slot: "4A",
          duration: "3 Hours",
          statusWidget: _buildTextStatusBox(
            "Waiting for Payment",
            Colors.blue,
            Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteHistory() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        _buildHistoryCard(
          ticket: "TICKET-3",
          date: "1 April 2025 - 10.00",
          location: "Mega Mall Batam",
          floor: "1st Floor",
          slot: "4A",
          duration: "3 Hours",
          statusWidget: _buildTextStatusBox(
            "Completed",
            Colors.green,
            Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCanceledHistory() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        _buildHistoryCard(
          ticket: "TICKET-4",
          date: "7 June 2025 - 10.00",
          location: "Mega Mall Batam",
          floor: "1st Floor",
          slot: "4A",
          duration: "3 Hours",
          statusWidget: _buildTextStatusBox(
            "Canceled",
            Colors.red,
            Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBox({
    required String title,
    required String date,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
          SizedBox(height: 2),
          Text(date, style: TextStyle(color: Colors.white, fontSize: 12)),
          SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextStatusBox(String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String ticket,
    required String date,
    required String location,
    required String floor,
    required String slot,
    required String duration,
    required Widget statusWidget,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ticket, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: TextStyle(fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info lokasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(floor),
                    Text(slot),
                    Text(duration),
                  ],
                ),
              ),

              // Status di kanan
              statusWidget,
            ],
          ),
        ],
      ),
    );
  }
}
