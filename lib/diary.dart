import 'package:flutter/material.dart';
import 'package:quinez/new_note.dart'; // Create this for the "add note" page

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top black bar with PFP, Username, and Plus button
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/pfp.png'),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Username',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewNotePage()),
                  );
                },
              ),
            ],
          ),
        ),

        // Blue background body
        Expanded(
          child: Container(
            color: const Color(0xFF007BFF),
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
          ),
        ),
      ],
    );
  }
}
