import 'package:flutter/material.dart';

class OtherPage extends StatelessWidget {
  const OtherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Other Page"),
      ),
      body: const Center(
        child: Text(
          "This is a dummy Other page.",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
