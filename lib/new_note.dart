import 'package:flutter/material.dart';

class NewNotePage extends StatelessWidget {
  const NewNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF007BFF),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Write your new note here...',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}

