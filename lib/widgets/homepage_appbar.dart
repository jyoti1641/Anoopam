import 'package:flutter/material.dart';

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onProfilePressed;
  final ImageProvider logo; // You can pass your logo as an ImageProvider

  const HomePageAppBar({
    super.key,
    required this.onSearchPressed,
    required this.onNotificationsPressed,
    required this.onProfilePressed,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Or your desired background color
      elevation: 0, // No shadow
      titleSpacing: 0, // Remove default title spacing
      automaticallyImplyLeading: false, // Don't show the default back button
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // Logo
            CircleAvatar(
              backgroundImage: logo,
              radius: 20, // Adjust size as needed
            ),
            const Spacer(), // Pushes the buttons to the right

            // Search Button
            IconButton(
              icon: const Icon(Icons.search, color: Colors.indigo),
              onPressed: onSearchPressed,
            ),
            const SizedBox(width: 8), // Space between buttons

            // Notifications Button
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.indigo),
              onPressed: onNotificationsPressed,
            ),
            const SizedBox(width: 8), // Space between buttons

            // Profile Button
            IconButton(
              icon: const Icon(Icons.person, color: Colors.indigo),
              onPressed: onProfilePressed,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
