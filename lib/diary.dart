import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF007BFF), // same blue as homepage
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search box
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Note preview box
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: Text('Title\nwritten.'),
                ),
                Text('MM/DD/YYYY'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
