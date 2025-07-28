import 'package:anoopam_mission/Views/Audio/screens/album_screen.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Wallpapers/wallpapers_screen.dart'; // <-- Import this
import 'package:anoopam_mission/Views/Video/video_home_screen.dart';
import 'package:anoopam_mission/Views/Gallery/gallery_screen.dart';
import 'package:anoopam_mission/Views/Menu/settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class DummyMoreScreen extends StatelessWidget {
  DummyMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create menu items dynamically to respond to locale changes
    final List<_MenuItem> menuItems = [
      _MenuItem(icon: Icons.home, label: 'menu.home'.tr()),
      _MenuItem(icon: Icons.music_note, label: 'menu.audio'.tr()),
      _MenuItem(icon: Icons.play_circle_outline, label: 'menu.video'.tr()),
      _MenuItem(icon: Icons.live_tv, label: 'menu.liveEvent'.tr()),
      _MenuItem(icon: Icons.image, label: 'menu.wallpapers'.tr()),
      _MenuItem(icon: Icons.star_border, label: 'menu.sadhanaTracker'.tr()),
      _MenuItem(icon: Icons.photo_album, label: 'menu.gallery'.tr()),
      _MenuItem(icon: Icons.format_quote, label: 'menu.dailyQuotes'.tr()),
      _MenuItem(
          icon: Icons.chat_bubble_outline, label: 'menu.amrutvachan'.tr()),
      _MenuItem(icon: Icons.spa, label: 'menu.thakorjiDarshan'.tr()),
      _MenuItem(icon: Icons.edit, label: 'menu.mantralekhan'.tr()),
      _MenuItem(icon: Icons.menu_book, label: 'menu.reading'.tr()),
      _MenuItem(icon: Icons.calendar_today, label: 'menu.calendar'.tr()),
      _MenuItem(icon: Icons.settings, label: 'menu.settings'.tr()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('menu.moreOptions'.tr()),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading:
                Icon(item.icon, color: Theme.of(context).colorScheme.primary),
            title: Text(
              item.label,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: () {
              if (item.label == 'menu.audio'.tr()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlbumScreen()),
                );
              } else if (item.label == 'menu.wallpapers'.tr()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WallpapersScreen()),
                );
              } else if (item.label == 'menu.video'.tr()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VideoHomeScreen()),
                );
              } else if (item.label == 'menu.gallery'.tr()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GalleryScreen()),
                );
              } else if (item.label == 'menu.settings'.tr()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              } else {
                debugPrint('Tapped on: \\${item.label}');
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
