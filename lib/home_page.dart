import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:quinez/diary.dart';
import 'package:quinez/weather.dart';
import 'package:quinez/sf.dart';
import 'package:quinez/logout.dart';

import 'dart:io' show File, Platform;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Initial selected index set to 0 to select Diary page on start
  int _selectedIndex = 0;

  File? _imageFile;
  Uint8List? _webImageBytes;

  final double _pfpRadius = 40;

  static const List<Widget> _pages = <Widget>[
    DiaryPage(),
    WeatherPage(),
    SfPage(),
    LogoutPage(),
  ];

  final ImagePicker _picker = ImagePicker();

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = -1; // Optional: allows deselecting tab
      } else {
        _selectedIndex = index;
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _webImageBytes = result.files.single.bytes!;
            _imageFile = null;
          });
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
            _webImageBytes = null;
          });
        }
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (result != null && result.files.single.path != null) {
          setState(() {
            _imageFile = File(result.files.single.path!);
            _webImageBytes = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 60;

    return Scaffold(
      backgroundColor: const Color(0xFF007BFF),
      appBar: AppBar(
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
                    backgroundImage: _buildPfpImageProvider(),
                  ),
                  const SizedBox(width: 4), // smaller gap here
                  const Flexible(
                    child: Text(
                      'Username',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _selectedIndex == -1
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'to my',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'NoteCast',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : _pages[_selectedIndex],
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
    String label,
    String iconPath,
    int index,
  ) {
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
