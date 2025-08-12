import 'package:flutter/material.dart';

class NewNotePage extends StatelessWidget {
  const NewNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'New Note Page Placeholder',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
