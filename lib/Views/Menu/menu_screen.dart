import 'package:anoopam_mission/Views/Audio/screens/album_screen.dart';
import 'package:anoopam_mission/Views/Video/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Audio/audio_screen.dart';
import 'package:anoopam_mission/Views/Wallpapers/wallpapers_screen.dart'; // <-- Import this
import 'package:anoopam_mission/Views/video/video_home_screen.dart';
import 'package:anoopam_mission/Views/Gallery/gallery_screen.dart';
import 'package:anoopam_mission/Views/Menu/settings_screen.dart';

class DummyMoreScreen extends StatelessWidget {
  const DummyMoreScreen({super.key});

  final List<_MenuItem> menuItems = const [
    _MenuItem(icon: Icons.home, label: 'Home'),
    _MenuItem(icon: Icons.music_note, label: 'Audio'),
    _MenuItem(icon: Icons.play_circle_outline, label: 'Video'),
    _MenuItem(icon: Icons.live_tv, label: 'Live Event'),
    _MenuItem(icon: Icons.image, label: 'Wallpapers'),
    _MenuItem(icon: Icons.star_border, label: 'Sadhana Tracker'),
    _MenuItem(icon: Icons.photo_album, label: 'Gallery'),
    _MenuItem(icon: Icons.format_quote, label: 'Daily Quotes'),
    _MenuItem(icon: Icons.chat_bubble_outline, label: 'Amrutvachan'),
    _MenuItem(icon: Icons.spa, label: 'Thakorji Darshan'),
    _MenuItem(icon: Icons.edit, label: 'Mantralekhan'),
    _MenuItem(icon: Icons.menu_book, label: 'Reading'),
    _MenuItem(icon: Icons.calendar_today, label: 'Calendar'),
    _MenuItem(icon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Options'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item.icon, color: Colors.blue),
            title: Text(item.label),
            onTap: () {
              if (item.label == 'Audio') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlbumScreen()),
                );
              } else if (item.label == 'Wallpapers') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WallpapersScreen()),
                );
              } else if (item.label == 'Video') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              } else if (item.label == 'Gallery') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GalleryScreen()),
                );
              } else if (item.label == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              } else {
                debugPrint('Tapped on: ${item.label}');
              }
            },
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});
}
