import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'diary.dart';
import 'new_note.dart';
import 'weather.dart';
import 'sf.dart';
import 'logout.dart';

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

  // Flip history
  final List<Map<String, String>> _flipHistory = [];
  int _currentWeek = _getWeekNumber(DateTime.now());

  final List<Widget> _pages = [
    const DiaryPage(),
    const WeatherPage(),
    const SfPage(),
    const LogoutPage(),
  ];

  static int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysPassed = date.difference(firstDayOfYear).inDays;
    return (daysPassed / 7).floor();
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

  void _showFlipHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Flip History (This Week)"),
          content: _flipHistory.isEmpty
              ? const Text("No flips yet this week.")
              : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _flipHistory.length,
              itemBuilder: (context, index) {
                final entry = _flipHistory[index];
                return ListTile(
                  dense: true,
                  title: Text(
                      'On ${entry["day"]}, the result of the flip is ${entry["result"]}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _flipHistory.clear();
                });
                Navigator.pop(context);
              },
              child: const Text("Reset"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 70;
    PreferredSizeWidget? appBar;

    // AppBar logic
    if (_selectedIndex == 0 && _isWritingNote) {
      appBar = AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(radius: 16, backgroundImage: _buildPfpImageProvider()),
            const SizedBox(width: 8),
            const Text('Username',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              setState(() {
                _isWritingNote = false;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              setState(() {
                _isWritingNote = false;
              });
            },
          ),
        ],
      );
    } else if (_selectedIndex == 1 || _selectedIndex == 3) {
      // Weather or Logout: black AppBar
      appBar = AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: _buildPfpImageProvider()),
            const SizedBox(width: 8),
            const Text('Username',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    } else if (_selectedIndex == 2) {
      // SF page with history button
      appBar = AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: _buildPfpImageProvider()),
            const SizedBox(width: 8),
            const Text('Username',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _showFlipHistory,
          ),
        ],
      );
    } else {
      // Default AppBar
      appBar = AppBar(
        backgroundColor: const Color(0xFF007BFF),
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: _pfpRadius * 2 + 106,
        leading: Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 4.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: _pickImage,
              child: Row(
                children: [
                  CircleAvatar(
                      radius: _pfpRadius,
                      backgroundColor: Colors.white24,
                      backgroundImage: _buildPfpImageProvider()),
                  const SizedBox(width: 4),
                  const Flexible(
                    child: Text('Username',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF007BFF),
      appBar: appBar,
      body: _selectedIndex == -1
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Welcome',
                style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('to my',
                style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('NoteCast',
                style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      )
          : (_selectedIndex == 0
          ? (_isWritingNote ? const NewNotePage() : const DiaryPage())
          : _pages[_selectedIndex]),
      bottomNavigationBar: SizedBox(
        height: barHeight,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
          onTap: _onItemTapped,
          selectedFontSize: 14,
          unselectedFontSize: 14,
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

  BottomNavigationBarItem _buildNavItem(
      String label, String iconPath, int index) {
    final bool isSelected = _selectedIndex == index;
    final double scale = isSelected ? 1.2 : 1.0;

    return BottomNavigationBarItem(
      icon: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: scale),
        duration: const Duration(milliseconds: 200),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
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
