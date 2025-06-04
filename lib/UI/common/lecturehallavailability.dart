import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../AUTH/timetable_auth.dart';

class lecturehallavailability extends StatefulWidget {
  const lecturehallavailability({Key? key}) : super(key: key);

  @override
  _LectureHallAvailabilityState createState() =>
      _LectureHallAvailabilityState();
}

class _LectureHallAvailabilityState extends State<lecturehallavailability> {
  final _timetableAuth = TimetableAuth();
  List<Map<String, dynamic>> _timeslots = [];

  @override
  void initState() {
    super.initState();
    _loadTimetableData();
  }

  Future<void> _loadTimetableData() async {
    List<Map<String, dynamic>> data = await _timetableAuth.getTimetableData();
    setState(() {
      _timeslots = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecture Halls Availability"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search the Lecture Halls...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (text) {
                // Implement search functionality here if needed
              },
            ),
          ),
          Expanded(
            child: _buildLectureHallList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureHallList() {
    // Get the current time and weekday
    DateTime now = DateTime.now();
    String currentWeekday = DateFormat('EEEE').format(now).toUpperCase();

    // Filter timeslots for the current weekday
    List<Map<String, dynamic>> timeslotsForToday = _timeslots.where((timeslot) {
      return timeslot['day']?.toUpperCase() == currentWeekday;
    }).toList();

    // Get unique lecture halls
    Set<String> uniqueHalls = {};
    for (var timeslot in timeslotsForToday) {
      if (timeslot['hallLocation'] != null) {
        uniqueHalls.add(timeslot['hallLocation']);
      }
    }

    if (uniqueHalls.isEmpty) {
      return const Center(child: Text('No lecture halls found for today.'));
    }

    return ListView.builder(
      itemCount: uniqueHalls.length, // Use the number of unique halls
      itemBuilder: (context, index) {
        String hallName = uniqueHalls.elementAt(index);

        // Hardcode capacity based on hall name
        int capacity = 0; // Default capacity
        if (hallName == 'L2 Hall' ||
            hallName == 'S 305' ||
            hallName == 'S 201') {
          capacity = 150;
        } else if (hallName == 'ICT Lab') {
          capacity = 100;
        }

        Map<String, dynamic>? currentTimeslot =
            _getCurrentTimeslot(timeslotsForToday, hallName, now);

        bool isAvailable = currentTimeslot == null;

        return Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              hallName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${isAvailable ? 'Available' : 'Not available'}',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                  ),
                ),
                Text('Capacity: $capacity'), // Display hardcoded capacity
                if (!isAvailable && currentTimeslot != null) ...[
                  Text('Lecture: ${currentTimeslot['subjectName']}'),
                  Text('Lecturer: ${currentTimeslot['lecturer']}'),
                  Text(
                      'Time: ${currentTimeslot['time']}'), // Display the time range
                ] else if (isAvailable) ...[
                  Text(
                      'Time: ${_getAvailableTimeRange(timeslotsForToday, hallName, now)}'), // Get and display available time range
                ],
              ],
            ),
            trailing: Icon(
              isAvailable ? Icons.check_circle : Icons.cancel,
              color: isAvailable ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic>? _getCurrentTimeslot(
      List<Map<String, dynamic>> timeslots, String hallName, DateTime now) {
    String currentTimeStr = DateFormat('HH:mm').format(now);

    for (var timeslot in timeslots) {
      if (timeslot['hallLocation'] == hallName) {
        // Extract start and end times
        String startTimeStr = timeslot['time'].split('-')[0];
        String endTimeStr = timeslot['time'].split('-')[1];

        // Parse time strings with custom parsing
        DateTime? startTime = parseTime(startTimeStr);
        DateTime? endTime = parseTime(endTimeStr);

        if (startTime != null && endTime != null) {
          DateTime now = DateTime.now(); // Get the current time

          // Set the date components of startTime and endTime to today's date
          startTime = DateTime(
              now.year, now.month, now.day, startTime.hour, startTime.minute);
          endTime = DateTime(
              now.year, now.month, now.day, endTime.hour, endTime.minute);

          if (!now.isBefore(startTime) && now.isBefore(endTime)) {
            return timeslot;
          }
        }
      }
    }
    return null;
  }

// Helper function to parse time with custom format
  DateTime? parseTime(String timeStr) {
    try {
      // Parse time strings directly using HH.mm format
      return DateFormat('HH.mm').parse(timeStr);
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
  }

  // Add this method to your _LectureHallAvailabilityState class
  String _getAvailableTimeRange(
      List<Map<String, dynamic>> timeslots, String hallName, DateTime now) {
    // Find all timeslots for this hall
    List<Map<String, dynamic>> hallTimeslots = timeslots
        .where((timeslot) => timeslot['hallLocation'] == hallName)
        .toList();

    // Sort timeslots by start time
    hallTimeslots.sort((a, b) {
      String startTimeA = a['time'].split('-')[0];
      String startTimeB = b['time'].split('-')[0];
      return parseTime(startTimeA)!.compareTo(parseTime(startTimeB)!);
    });

    // Find the first available time slot after the current time
    String availableFrom = DateFormat('HH:mm').format(now);
    String availableUntil = '';

    for (var timeslot in hallTimeslots) {
      DateTime? endTime = parseTime(timeslot['time'].split('-')[1]);
      if (endTime != null && now.isBefore(endTime)) {
        availableUntil = DateFormat('HH:mm').format(endTime);
        break;
      }
    }

    if (availableUntil.isNotEmpty) {
      return '$availableFrom-$availableUntil';
    } else {
      return 'Not available today';
    }
  }
}
