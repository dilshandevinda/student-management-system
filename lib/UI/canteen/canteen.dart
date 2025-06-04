import 'package:educonnectfinal/UI/canteen/applied.dart';
import 'package:educonnectfinal/UI/canteen/canteen.dart';
import 'package:educonnectfinal/UI/canteen/dutugemunu.dart';
import 'package:educonnectfinal/UI/canteen/milkbar.dart';
import 'package:educonnectfinal/UI/canteen/social.dart';
import 'package:educonnectfinal/UI/canteen/technology.dart';
import 'package:educonnectfinal/UI/canteen/viharamahadevi.dart';
import 'package:educonnectfinal/UI/common/lecturehallavailability.dart';
import 'package:educonnectfinal/UI/common/navigation.dart';
import 'package:educonnectfinal/UI/common/notifications.dart';
import 'package:educonnectfinal/UI/common/timetable.dart';
import 'package:educonnectfinal/UI/student/profileandsecurity.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Dutugemunu extends StatelessWidget {
  const Dutugemunu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Dutugemunu')),
        body: Center(child: Text('Dutugemunu')));
  }
}

class Viharamahadevi extends StatelessWidget {
  const Viharamahadevi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Viharamahadevi')),
        body: Center(child: Text('Viharamahadevi')));
  }
}

class Technology extends StatelessWidget {
  const Technology({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Technology')),
        body: Center(child: Text('Technology')));
  }
}

class Applied extends StatelessWidget {
  const Applied({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Applied')),
        body: Center(child: Text('Applied')));
  }
}

class MilkBar extends StatelessWidget {
  const MilkBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('MilkBar')),
        body: Center(child: Text('MilkBar')));
  }
}

class Social extends StatelessWidget {
  const Social({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Social')),
        body: Center(child: Text('Social')));
  }
}

class canteenpage extends StatefulWidget {
  const canteenpage({super.key});

  @override
  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<canteenpage> {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CANTEEN',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 49, 66, 148),
                  ),
                ),
                SizedBox(height: 0),
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
                    'Dutugemunu',
                    Icons.restaurant,
                    dutugemunu(),
                  ),
                  _buildGridItem(
                    context,
                    'Viharamahadevi',
                    Icons.restaurant,
                    viharamahadevi(),
                  ),
                  _buildGridItem(
                    context,
                    'Technology',
                    Icons.restaurant,
                    technology(),
                  ),
                  _buildGridItem(
                    context,
                    'Applied',
                    Icons.restaurant,
                    applied(),
                  ),
                  _buildGridItem(
                    context,
                    'Milkbar',
                    Icons.restaurant,
                    milkbar(),
                  ),
                  _buildGridItem(
                    context,
                    'Social',
                    Icons.restaurant,
                    social(),
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
