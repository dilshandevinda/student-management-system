import 'package:educonnectfinal/UI/common/chatlist.dart';
import 'package:educonnectfinal/UI/common/navigation.dart';
import 'package:educonnectfinal/UI/common/timetable.dart';
import 'package:educonnectfinal/UI/common/timetableupdate.dart';
import 'package:educonnectfinal/UI/login.dart';
import 'package:educonnectfinal/UI/home.dart';
import 'package:educonnectfinal/UI/student/studentprofile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import generated Firebase options

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define the routes table
      routes: {
        '/': (context) => const Login(), // Default route (Login page)
        '/login': (context) => const Login(), // Route for the login page
        '/student_profile': (context) =>
            const stdprofile(), // Route for the student profile page
        '/home': (context) =>
            const HomePage(), // Route for the student profile page
        '/map': (context) => navigationPage(), // Route for the login page
        '/chat': (context) => ChatScreen(), // Route for the login page
        '/timetable': (context) => Timetable(), // Route for the login page
        '/timetable_update': (context) => TimetableUpdate(),

        // You can add other routes here if needed
      },
      initialRoute: '/login', // Set the initial route to the login page
    );
  }
}
