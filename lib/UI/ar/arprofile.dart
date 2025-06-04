// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class arprofile extends StatelessWidget {
  const arprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Profile"),
      ),
      body: const Center(
        child: Text(
          "Welcome, AR!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
