import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:parkintime/screens/reservation/select_spot_parkir.dart';

class BookParkingDetailsPage extends StatefulWidget {
  final int pricePerHour;
  const BookParkingDetailsPage({Key? key, this.pricePerHour = 5000})
    : super(key: key);

  @override
  _BookParkingDetailsPageState createState() => _BookParkingDetailsPageState();
}

class _BookParkingDetailsPageState extends State<BookParkingDetailsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  double _duration = 4.0;
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 13, minute: 0);

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Book Parking Details'),
        backgroundColor: Colors.green,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Select Date',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2030),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFFD5F5E3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Duration',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  Slider(
                    value: _duration,
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: '${_duration.toInt()} Hours',
                    activeColor: Colors.green,
                    onChanged: (v) {
                      setState(() {
                        _duration = v;
                        final newHour = (_startTime.hour + v.toInt()) % 24;
                        _endTime = TimeOfDay(
                          hour: newHour,
                          minute: _startTime.minute,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTimeCard('Start Hour', _startTime, (t) {
                    setState(() {
                      _startTime = t;
                      final newHour = (t.hour + _duration.toInt()) % 24;
                      _endTime = TimeOfDay(hour: newHour, minute: t.minute);
                    });
                  }),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  const SizedBox(width: 8),
                  _buildTimeCard('End Hour', _endTime, (t) {
                    setState(() {
                      final diff = (t.hour - _startTime.hour);
                      if (diff > 0) _duration = diff.toDouble();
                      _endTime = t;
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), // Geser ke atas
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${formatter.format(widget.pricePerHour * _duration.toInt())} / ${_duration.toInt()} Hours',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    (_selectedDay != null)
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => const ParkingLotDetailPage(
                                    spotName: 'Mega mall',
                                  ),
                            ),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onPicked,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (picked != null) onPicked(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Color(0xFFD5F5E3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    time.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
