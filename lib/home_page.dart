import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'diary.dart';
import 'new_note.dart';
import 'weather.dart';
import 'sf.dart';
import 'logout.dart';
import 'services/firebase_database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isWritingNote = false;
  final double _pfpRadius = 20;
  File? _imageFile;
  Uint8List? _webImageBytes;

  String _username = "Loading...";
  String? _editingNoteId;
  String _noteTitle = "";
  String _noteContent = "";

  final FirebaseDatabaseService _dbService = FirebaseDatabaseService();

  final List<Map<String, String>> _flipHistory = [];
  int _currentWeek = _getWeekNumber(DateTime.now());

  final List<Widget> _pages = [
    const DiaryPage(),
    const WeatherPage(),
    const SfPage(),
    const LogoutPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  static int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysPassed = date.difference(firstDayOfYear).inDays;
    return (daysPassed / 7).floor();
  }

  Future<void> _fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _username = data['username'] ?? data['name'] ?? user.email ?? 'User';
        });
      } else {
        setState(() {
          _username = user.email ?? 'User';
        });
      }
    } catch (e) {
      debugPrint("Error loading username: $e");
      setState(() {
        _username = "User";
      });
    }
  }


  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void addFlipResult(String result) {
    int thisWeek = _getWeekNumber(DateTime.now());
    if (thisWeek != _currentWeek) {
      _flipHistory.clear();
      _currentWeek = thisWeek;
    }

    String day = DateFormat('EEEE').format(DateTime.now());
    setState(() {
      _flipHistory.add({"day": day, "result": result});
    });
  }

  void _showFlipHistory() async {
    // show a loading dialog while fetching
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final flips = await _dbService.getLatestFlips(limit: 5);

      // close the loading dialog
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Flip History (Latest 5)"),
            content: flips.isEmpty
                ? const Text("No flips yet.")
                : SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: flips.length,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemBuilder: (context, index) {
                  final f = flips[index];
                  String result = f['result'] ?? '';
                  String ts = f['timestamp'] ?? '';
                  String formatted = ts.isNotEmpty
                      ? DateFormat('MM/dd/yyyy h:mm a')
                      .format(DateTime.parse(ts))
                      : '';
                  return ListTile(
                    dense: true,
                    title: Text(
                      "$result — $formatted",
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // close the loading dialog if still open
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      debugPrint("Error fetching flip history: $e");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to load history: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isWritingNote = false;
    });
  }

  void _startNewNote() {
    setState(() {
      _isWritingNote = true;
      _noteTitle = "";
      _noteContent = "";
      _editingNoteId = null;
    });
  }

  void _editExistingNote(String id, String title, String content) {
    setState(() {
      _isWritingNote = true;
      _editingNoteId = id;
      _noteTitle = title;
      _noteContent = content;
    });
  }

  Future<void> _saveNote() async {
    if (_noteTitle.trim().isEmpty && _noteContent.trim().isEmpty) return;

    if (_editingNoteId != null) {
      await _dbService.updateNote(_editingNoteId!, _noteTitle, _noteContent);
    } else {
      await _dbService.addNote(_noteTitle, _noteContent);
    }

    setState(() {
      _isWritingNote = false;
      _editingNoteId = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note saved successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 70;
    PreferredSizeWidget? appBar;

    Row _buildUserRow(double radius) {
      return Row(
        children: [
          CircleAvatar(radius: radius, backgroundImage: _buildPfpImageProvider()),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _username,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (_selectedIndex == 0 && _isWritingNote) {
      appBar = AppBar(
        backgroundColor: Colors.black,
        title: _buildUserRow(16),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.white),
            onPressed: () => setState(() => _isWritingNote = false),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveNote,
          ),
        ],
      );
    } else if (_selectedIndex == 0) {
      appBar = AppBar(
        backgroundColor: Colors.black,
        title: _buildUserRow(20),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _startNewNote,
          ),
        ],
      );
    } else if (_selectedIndex == 1 || _selectedIndex == 3) {
      appBar = AppBar(
        backgroundColor: Colors.black,
        title: _buildUserRow(20),
        automaticallyImplyLeading: false,
      );
    } else if (_selectedIndex == 2) {
      appBar = AppBar(
        backgroundColor: Colors.black,
        title: _buildUserRow(20),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _showFlipHistory,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF007BFF),
      appBar: appBar,
      body: _selectedIndex == 0
          ? (_isWritingNote
          ? NewNotePage(
        existingTitle: _noteTitle,
        existingContent: _noteContent,
        onTitleChanged: (val) => _noteTitle = val,
        onContentChanged: (val) => _noteContent = val,
      )
          : DiaryPage(onNoteTap: _editExistingNote))
          : _pages[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: barHeight,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            _buildNavItem('Diary', 'assets/images/diary.png', 0),
            _buildNavItem('Weather', 'assets/images/weather.png', 1),
            _buildNavItem('SF', 'assets/images/coin.png', 2),
            _buildNavItem('Logout', 'assets/images/logout.png', 3),
          ],
        ),
      ),
    );
  }

  ImageProvider<Object> _buildPfpImageProvider() {
    if (_webImageBytes != null) {
      return MemoryImage(_webImageBytes!);
    } else if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else {
      return const AssetImage('assets/images/pfp.png');
    }
  }

  BottomNavigationBarItem _buildNavItem(String label, String iconPath, int index) {
    final bool isSelected = _selectedIndex == index;
    final double scale = isSelected ? 1.2 : 1.0;

    return BottomNavigationBarItem(
      icon: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: scale),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, child) =>
            Transform.scale(scale: value, child: child),
        child: ImageIcon(
          AssetImage(iconPath),
          size: 24,
          color: isSelected ? Colors.white : Colors.white70,
        ),
      ),
      label: label,
    );
  }
}
