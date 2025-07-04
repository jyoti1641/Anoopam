import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.indigo,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      height: 60, // Adjust height as needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            // Use the path to your custom icon
            iconPath: 'assets/icons/home_icon.png',
            label: 'navbar.home'.tr(),
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            iconPath: 'assets/icons/reading_icon.png',
            label: 'navbar.reading'.tr(),
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavBarItem(
            iconPath: 'assets/icons/audio_icon.png',
            label: 'navbar.audio'.tr(),
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavBarItem(
            iconPath: 'assets/icons/gallery_icon.png',
            label: 'navbar.gallery'.tr(),
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavBarItem(
            iconPath: 'assets/icons/more_icon.png',
            label: 'navbar.more'.tr(),
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String iconPath; // Changed from IconData to String
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.iconPath, // Changed from icon to iconPath
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : Colors.grey[400];

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              // Use Image.asset for custom icons
              iconPath,
              color: color, // Apply color tint to the image
              width: 24, // Set the desired width
              height: 24, // Set the desired height
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
