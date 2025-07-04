import 'package:flutter/material.dart';

class WallpaperFullScreen extends StatefulWidget {
  final List<String> wallpapers;
  final int initialIndex;

  const WallpaperFullScreen({
    super.key,
    required this.wallpapers,
    required this.initialIndex,
  });

  @override
  State<WallpaperFullScreen> createState() => _WallpaperFullScreenState();
}

class _WallpaperFullScreenState extends State<WallpaperFullScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.wallpapers.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.asset(
                    widget.wallpapers[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
