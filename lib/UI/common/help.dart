import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Page"),
      ),
      body: const Center(
        child: Text(
          "This is a dummy Help page.",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
