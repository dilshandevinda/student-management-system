import 'package:educonnectfinal/UI/ar/createannouncement.dart';
import 'package:educonnectfinal/UI/ar/createpolls.dart';
import 'package:educonnectfinal/UI/common/lecturehallavailability.dart';
import 'package:educonnectfinal/UI/common/navigation.dart';
import 'package:educonnectfinal/UI/common/notifications.dart';
import 'package:educonnectfinal/UI/common/timetable.dart';
import 'package:educonnectfinal/UI/common/timetableupdate.dart';
import 'package:educonnectfinal/UI/student/profileandsecurity.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Placeholder pages (replace with your actual pages)
class TimeTable extends StatelessWidget {
  const TimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Time Table')),
        body: Center(child: Text('Time Table')));
  }
}

class CourseRegistration extends StatelessWidget {
  const CourseRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Course Registration')),
        body: Center(child: Text('Course Registration')));
  }
}

class LectureHallAvailability extends StatelessWidget {
  const LectureHallAvailability({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Lecture Hall Availability')),
        body: Center(child: Text('Lecture Hall Availability')));
  }
}

class Polls extends StatelessWidget {
  const Polls({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Vote for Polls')),
        body: Center(child: Text('Vote for Polls')));
  }
}

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Navigation')),
        body: Center(child: Text('Navigation')));
  }
}

class Canteen extends StatelessWidget {
  const Canteen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Canteen')),
        body: Center(child: Text('Canteen')));
  }
}

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Notifications')),
        body: Center(child: Text('Notifications')));
  }
}

class arprofilehome extends StatefulWidget {
  const arprofilehome({super.key});

  @override
  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<arprofilehome> {
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  _fetchUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.get('name') ?? 'Student';
          });
        } else {
          setState(() {
            _userName = 'Student';
          });
        }
      } else {
        setState(() {
          _userName = 'Guest';
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _userName = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 201, 218, 254),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '',
              style: TextStyle(color: Colors.black),
            ),
            // Add some padding around the icon
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: Icon(Icons.notifications,
                    color: const Color.fromARGB(255, 49, 66, 148)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello Welcome',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 49, 66, 148),
                  ),
                ),
                SizedBox(height: 0),
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 49, 66, 148),
                  ),
                ),
                /* Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search the what you want.',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ), */
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 20,
                childAspectRatio: 1.1,
                children: [
                  _buildGridItem(
                    context,
                    'Profile & Security',
                    Icons.person,
                    ProfileAndSecurity(),
                  ),
                  _buildGridItem(
                    context,
                    'Update Timetable',
                    Icons.calendar_today,
                    TimetableUpdate(),
                  ),
                  _buildGridItem(
                    context,
                    'Course\nRegistration',
                    Icons.app_registration,
                    CourseRegistration(),
                  ),
                  _buildGridItem(
                    context,
                    'Lecture Hall\nAvailability',
                    Icons.meeting_room,
                    lecturehallavailability(),
                  ),
                  _buildGridItem(
                    context,
                    'Create Polls',
                    Icons.poll,
                    CreatePollPage(),
                  ),
                  _buildGridItem(
                    context,
                    'Navigation',
                    Icons.map,
                    navigationPage(),
                  ),
                  _buildGridItem(
                    context,
                    'Create\nAnnouncement',
                    Icons.announcement,
                    CreateAnnouncementPage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
      BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 49, 66, 148),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
