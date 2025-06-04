import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimetableAuth {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Method to fetch timetable data from Firestore
  Future<List<Map<String, dynamic>>> getTimetableData() async {
    try {
      // Access the 'timetable' collection directly
      var timetableCollection = _firestore.collection('timetable');
      var querySnapshot = await timetableCollection.get();

      List<Map<String, dynamic>> timetableData = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        data['docId'] = doc.id; // Optionally add the document ID
        timetableData.add(data);
      }

      return timetableData;
    } catch (e) {
      print("Error getting timetable data from Firestore: $e");
      return []; // Return an empty list on error
    }
  }

  // Method to fetch timetable data from Firebase Storage (unchanged)
  Future<String> fetchTimetableDataFromStorage(String timetableId) async {
    try {
      final ref = _storage.ref().child('databases/$timetableId.json');
      final downloadUrl = await ref.getDownloadURL();
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        print("Failed to fetch data from Storage: ${response.statusCode}");
        return '';
      }
    } catch (e) {
      print("Error fetching timetable data from Storage: $e");
      return '';
    }
  }

  // Method to get timetable data from storage (updated)
  Future<List<Map<String, dynamic>>> getTimetableDataFromStorage(
      String timetableId) async {
    try {
      String jsonData = await fetchTimetableDataFromStorage(timetableId);
      List<dynamic> parsedJson = json.decode(jsonData);
      List<Map<String, dynamic>> timetableData =
          parsedJson.map((item) => item as Map<String, dynamic>).toList();
      return timetableData;
    } catch (e) {
      print("Error getting timetable data from storage: $e");
      return []; // Return an empty list on error
    }
  }

  // Method to add a timeslot (no Firestore interaction yet)
  Future<void> addTimeslot(
    String timetableId,
    String day,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String subjectName,
    String subjectCode,
    String teacher,
    String type,
  ) async {
    // Convert TimeOfDay to string format
    String startTimeString =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    String endTimeString =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    String timeRange = '$startTimeString-$endTimeString';

    // Get the timetable data from storage
    List<Map<String, dynamic>> timetableData =
        await getTimetableDataFromStorage(timetableId);

    // Find the index for the given day
    int dayIndex = timetableData.indexWhere((element) => element['Day'] == day);

    // If the day is not found, add a new entry for the day
    if (dayIndex == -1) {
      timetableData.add({
        'Day': day,
        'timeslots': [],
      });
      dayIndex = timetableData.length - 1;
    }

    // Add the new timeslot to the day's list
    timetableData[dayIndex]['timeslots'].add({
      'Time': timeRange,
      'Subject Code': subjectCode,
      'Subject Name': subjectName,
      'Type': type,
      'Lecturer': teacher,
    });

    // Update the JSON data in Firebase Storage
    await updateTimetableDataInStorage(timetableId, timetableData);
  }

// Method to update timetable data in Firebase Storage
  Future<void> updateTimetableDataInStorage(
      String timetableId, List<Map<String, dynamic>> timetableData) async {
    try {
      // Convert the timetable data to a JSON string
      String jsonData = json.encode(timetableData);

      // Get a reference to the JSON file in Firebase Storage
      final ref = _storage.ref().child('databases/$timetableId.json');

      // Upload the updated JSON string to Firebase Storage
      await ref.putString(jsonData);

      print("Timetable data updated successfully in Storage!");
    } catch (e) {
      print("Error updating timetable data in Storage: $e");
    }
  }

  // Method to import timetable data to Firestore (keep this for later)
  Future<void> importTimetableDataToFirestore(
      String timetableId, String jsonData) async {
    try {
      final List<dynamic> timetableData = json.decode(jsonData);
      final timetableRef = _firestore.collection('timetables').doc(timetableId);
      Map<String, List<Map<String, dynamic>>> timeslotsByDay = {};

      for (var timeslot in timetableData) {
        String day = timeslot['Day'];
        if (!timeslotsByDay.containsKey(day)) {
          timeslotsByDay[day] = [];
        }
        timeslotsByDay[day]!.add({
          'Time': timeslot['Time'],
          'Subject Code': timeslot['Subject Code'],
          'Subject Name': timeslot['Subject Name'],
          'Type': timeslot['Type'],
          'Hall/Location': timeslot['Hall/Location'],
          'Lecturer': timeslot['Lecturer'],
        });
      }

      WriteBatch batch = _firestore.batch();
      timeslotsByDay.forEach((day, timeslots) {
        for (var timeslot in timeslots) {
          final timeslotRef = timetableRef.collection(day).doc();
          batch.set(timeslotRef, timeslot);
        }
      });

      await batch.commit();
      print("Timetable data imported successfully to Firestore!");
    } catch (e) {
      print("Error importing timetable data to Firestore: $e");
    }
  }

  // Method to fetch and import timetable data from JSON (keep this for later)
  Future<void> fetchTimetableDataFromJSON(String timetableId) async {
    String jsonData = await fetchTimetableDataFromStorage(timetableId);
    if (jsonData.isNotEmpty &&
        jsonData.startsWith('[') &&
        jsonData.endsWith(']')) {
      await importTimetableDataToFirestore(timetableId, jsonData);
    } else {
      print("Invalid JSON data fetched or data is empty.");
    }
  }

  // Method to add a new timetable and link it to the current user (keep this for later)
  Future<void> addNewTimetable(String timetableId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await fetchTimetableDataFromJSON(timetableId);
      await _firestore.collection('users').doc(user.uid).update({
        'timetables': FieldValue.arrayUnion([timetableId])
      });
      print('New timetable added and linked to user successfully.');
    }
  }

  // Method to get the timetable IDs associated with the current user
  Future<List<String>> getUserTimetableIds() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<String> timetableIds = List<String>.from(data['timetables'] ?? []);
        return timetableIds;
      }
    }
    return [];
  }
}
