// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_build_context_synchronously

import 'package:educonnectfinal/UI/common/chatlist.dart';
import 'package:educonnectfinal/UI/common/help.dart';
import 'package:educonnectfinal/UI/common/navigation.dart';
import 'package:educonnectfinal/UI/common/notifications.dart';
import 'package:educonnectfinal/UI/common/other.dart';
import 'package:educonnectfinal/UI/common/settings.dart';
import 'package:educonnectfinal/UI/common/timetable.dart';
import 'package:educonnectfinal/UI/student/profileandsecurity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'undergraduatestatus.dart';

class stdprofile extends StatefulWidget {
  const stdprofile({super.key});

  @override
  _stdprofileState createState() => _stdprofileState();
}

class _stdprofileState extends State<stdprofile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _userName;
  String? _userEmail;
  String? _userImageUrl;

  // State variable for the currently selected drawer item
  int _selectedDrawerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      // Fetch additional user data from Firestore
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(_user!.uid).get();
      if (userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        setState(() {
          _userName = data.containsKey('name') ? userData.get('name') : null;
          _userEmail = data.containsKey('email') ? userData.get('email') : null;
          _userImageUrl = data.containsKey('imageUrl')
              ? userData.get('imageUrl')
              : null; // Handle missing imageUrl
        });
      }
    }
  }

  // Function to handle drawer item selection
  void _onSelectItem(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  // Function to get the appropriate page based on the selected drawer item
  Widget _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return const ProfileAndSecurity();
      case 1:
        return const Undergraduatestatus();
      case 2:
        return const Timetable();
      case 3:
        return ChatScreen();
      case 4:
        return const SettingsPage();
      case 5:
        return navigationPage();
      case 6:
        // Handle logout in _buildDrawer()
        return Container(); // Placeholder, as logout doesn't display a page
      default:
        return const Text("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedDrawerIndex == 0
            ? "Profile & Security"
            : _getAppBarTitle(_selectedDrawerIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 1:
        return "Undergraduate Status";
      case 2:
        return "Lecture Timetable";
      case 3:
        return "Other";
      case 4:
        return "Settings";
      case 5:
        return "Help";
      default:
        return "Profile";
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30, // Reduced size
                  backgroundImage: _userImageUrl != null
                      ? NetworkImage(_userImageUrl!)
                      : const AssetImage('assets/images/default_profile.png')
                          as ImageProvider<Object>,
                ),
                const SizedBox(height: 10),
                Text(
                  _userName ?? 'Student Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Reduced font size
                  ),
                ),
                Text(
                  _userEmail ?? 'student@example.com',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Reduced font size
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile & Security'),
            selected: _selectedDrawerIndex == 0,
            onTap: () => _onSelectItem(0),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Undergraduate Status'),
            selected: _selectedDrawerIndex == 1,
            onTap: () => _onSelectItem(1),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Lecture Timetable'),
            selected: _selectedDrawerIndex == 2,
            onTap: () => _onSelectItem(2),
          ),
          ListTile(
            leading: const Icon(Icons.more_horiz),
            title: const Text('Other'),
            selected: _selectedDrawerIndex == 3,
            onTap: () => _onSelectItem(3),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: _selectedDrawerIndex == 4,
            onTap: () => _onSelectItem(4),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            selected: _selectedDrawerIndex == 5,
            onTap: () => _onSelectItem(5),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
