// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class lecprofile extends StatelessWidget {
  const lecprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer Profile"),
      ),
      body: const Center(
        child: Text(
          "Welcome, Lecturer!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
