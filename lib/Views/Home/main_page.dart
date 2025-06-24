// import 'package:anoopam_mission/Views/Profile/profile_screen.dart';
import 'package:anoopam_mission/Views/Audio/audio_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/album_screen.dart';
import 'package:anoopam_mission/Views/Gallery/gallery_screen.dart';
import 'package:anoopam_mission/Views/Home/home_screen.dart';
import 'package:anoopam_mission/Views/Menu/menu_screen.dart';
import 'package:anoopam_mission/Views/Reading/reading_screen.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/widgets/bottom_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Tracks the currently selected tab

  // List of screens to display for each tab
  final List<Widget> _pages = [
    const HomeScreen(),
    const ReadingScreen(),
    const AlbumScreen(),
    const GalleryScreen(),
    const DummyMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the current page
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
