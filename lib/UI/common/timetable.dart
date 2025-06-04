// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../AUTH/timetable_auth.dart';

class Timetable extends StatefulWidget {
  const Timetable({super.key});

  @override
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  final _timetableAuth = TimetableAuth();
  DateTime _selectedDate = DateTime.now();
  late PageController _pageController;
  List<Map<String, dynamic>> _timeslots = []; // Store fetched timeslots here

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 7,
      viewportFraction: 0.2,
    );
    _loadTimetableData(); // Load timetable data on initialization
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadTimetableData() async {
    List<Map<String, dynamic>> data =
        await _timetableAuth.getTimetableData(); // Fetch data from Firestore
    setState(() {
      _timeslots = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TIMETABLE"),
      ),
      body: Column(
        children: [
          _buildDatePicker(),
          Expanded(
            child: _buildTimeslotList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      height: 75,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 15,
        onPageChanged: (index) {
          setState(() {
            _selectedDate = DateTime.now().add(Duration(days: index - 7));
          });
        },
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 7));
          return _buildDateItem(date, index);
        },
      ),
    );
  }

  Widget _buildDateItem(DateTime date, int index) {
    bool isSelected = date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        });
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue
              : const Color.fromARGB(255, 163, 163, 163),
          borderRadius: BorderRadius.circular(75),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(date),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 0),
            Text(
              DateFormat('dd').format(date),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeslotList() {
    // Get the weekday of the selected date
    String selectedWeekday =
        DateFormat('EEEE').format(_selectedDate).toUpperCase();

    // Filter timeslots for the selected weekday
    List<Map<String, dynamic>> timeslotsForDay = _timeslots.where((timeslot) {
      return timeslot['day']?.toUpperCase() == selectedWeekday;
    }).toList();

    if (timeslotsForDay.isEmpty) {
      return const Center(child: Text('No timeslots for this day.'));
    }

    // Sort timeslots by start time
    timeslotsForDay.sort((a, b) {
      String startTimeA = a['time'].split('-')[0]; // Extract start time
      String startTimeB = b['time'].split('-')[0]; // Extract start time
      return startTimeA.compareTo(startTimeB);
    });

    return ListView.builder(
      itemCount: timeslotsForDay.length,
      itemBuilder: (context, index) {
        final timeslotData = timeslotsForDay[index];
        final startTime = timeslotData['time'] as String;
        final subjectCode = timeslotData['subjectCode'] as String;
        final subjectName = timeslotData['subjectName'] as String;
        final type = timeslotData['type'] as String;
        final lecturer = timeslotData['lecturer'] as String;
        final hallLocation = timeslotData['hallLocation'] as String;

        return Container(
          margin: const EdgeInsets.all(8.0), // Add margin for spacing
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: _getSubjectColor(
                subjectCode), // Get color based on subject code
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            boxShadow: [
              // Add a subtle shadow
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$subjectName ($subjectCode)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$startTime',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lecturer: $lecturer',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: $hallLocation',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              _buildTypeIndicator(type),
              const SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeIndicator(String type) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          type,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subjectCode) {
    switch (subjectCode) {
      case 'ICT 4203':
        return Colors.lightBlue[100]!;
      case 'ICT 4207':
        return Colors.green[100]!;
      case 'ICT 4202':
        return Colors.orange[100]!;
      case 'ICT 4210':
        return Colors.purple[100]!;
      case 'ICT 4301':
        return Colors.red[100]!;
      case 'ICT 4306':
        return Colors.amber[200]!;
      case 'ICT 4205':
        return Colors.teal[100]!;
      case 'ICT 4211':
        return Colors.pink[100]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
