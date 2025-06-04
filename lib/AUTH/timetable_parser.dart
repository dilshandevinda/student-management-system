import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class TimetableParser {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> updateTimetableFromStorage() async {
    try {
      final String downloadURL =
          await _storage.ref('databases/timetable.json').getDownloadURL();

      final response = await http.get(Uri.parse(downloadURL));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        await _uploadTimetableToFirestore(jsonData);
        print('Timetable updated successfully!');
      } else {
        throw Exception(
            'Failed to fetch timetable.json: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating timetable: $e');
      rethrow;
    }
  }

  Future<void> _uploadTimetableToFirestore(List<dynamic> jsonData) async {
    final batch = _firestore.batch();

    for (final entry in jsonData) {
      final docRef =
          _firestore.collection('timetable').doc(); // Auto-generate ID

      // Map JSON fields to Firestore fields
      batch.set(docRef, {
        'time': entry['Time'],
        'day': entry['Day'],
        'subjectCode': entry['Subject Code'],
        'subjectName': entry['Subject Name'],
        'type': entry['Type'],
        'hallLocation': entry['Hall/Location'],
        'lecturer': entry['Lecturer'],
      });
    }

    await batch.commit();
  }
}
