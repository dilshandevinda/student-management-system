// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class coprofile extends StatelessWidget {
  const coprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Canteen Owner Profile"),
      ),
      body: const Center(
        child: Text(
          "Welcome, Canteen Owner!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
