import 'package:educonnectfinal/AUTH/timetable_parser.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimetableUpdate extends StatefulWidget {
  const TimetableUpdate({Key? key}) : super(key: key);

  @override
  _TimetableUpdateState createState() => _TimetableUpdateState();
}

class _TimetableUpdateState extends State<TimetableUpdate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TimetableParser _parser = TimetableParser();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    User? user = _auth.currentUser;
    if (user == null) {
      // Redirect to login or handle unauthenticated user
      // Example: Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _updateTimetable() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _parser.updateTimetableFromStorage();
      _showSnackBar('Timetable updated successfully!');
    } catch (e) {
      _showSnackBar('Error updating timetable: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Update'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _updateTimetable,
                child: const Text('Update Timetable from JSON'),
              ),
      ),
    );
  }
}
