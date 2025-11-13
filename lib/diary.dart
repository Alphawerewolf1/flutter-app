import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'services/firebase_database_service.dart';

class DiaryPage extends StatefulWidget {
  final Function(String, String, String)? onNoteTap;

  const DiaryPage({super.key, this.onNoteTap});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final FirebaseDatabaseService _dbService = FirebaseDatabaseService();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final DatabaseReference notesRef = _dbService.getUserNotesRef();

    return Container(
      color: const Color(0xFF007BFF),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // 🔹 Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  filled: true,
                  fillColor: Colors.white70,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            // 🔹 Notes list
            Expanded(
              child: StreamBuilder(
                stream: notesRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }

                  if (!snapshot.hasData ||
                      (snapshot.data! as DatabaseEvent).snapshot.value ==
                          null) {
                    return const Center(
                      child: Text(
                        "No notes yet. Tap + to add one!",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  final data = Map<String, dynamic>.from(
                      (snapshot.data! as DatabaseEvent).snapshot.value as Map);
                  final notes = data.entries
                      .map((e) => {
                    'id': e.key,
                    'title': e.value['title'] ?? 'Untitled',
                    'content': e.value['content'] ?? '',
                    'date': e.value['date'] ?? '',
                  })
                      .where((note) => note['title']
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                      .toList()
                    ..sort((a, b) =>
                        (b['date'] ?? '').compareTo(a['date'] ?? ''));

                  return ListView.builder(
                    itemCount: notes.length,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return GestureDetector(
                        onTap: () {
                          if (widget.onNoteTap != null) {
                            widget.onNoteTap!(
                              note['id']!,
                              note['title']!,
                              note['content']!,
                            );
                          }
                        },
                        // 🔹 Long press to delete
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete Note'),
                                content: Text(
                                    'Are you sure you want to delete "${note['title']}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await notesRef
                                          .child(note['id']!)
                                          .remove();
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Note "${note['title']}" deleted'),
                                          duration:
                                          const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Title + Date Row
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      note['title']!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    note['date'] != ''
                                        ? DateFormat('MM/dd/yyyy').format(
                                        DateTime.parse(note['date']!))
                                        : '',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                note['content']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
