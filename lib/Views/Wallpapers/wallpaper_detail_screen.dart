import 'package:flutter/material.dart';
import 'wallpaper_full_screen.dart';

class WallpaperDetailScreen extends StatelessWidget {
  final String month;
  const WallpaperDetailScreen({super.key, required this.month});

  final List<String> wallpaperPaths = const [
    'assets/wall1.jpg',
    'assets/wall1.jpg',
    'assets/wall1.jpg',
    'assets/wall1.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(month),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: wallpaperPaths.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WallpaperFullScreen(
                      wallpapers: wallpaperPaths,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(wallpaperPaths[index], fit: BoxFit.cover),
              ),
            );
          },
        ),
      ),
    );
  }
}
