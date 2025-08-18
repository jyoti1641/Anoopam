import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    // Get the status bar height to adjust padding
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AppBar(
      backgroundColor: Colors.transparent, // Keeps it transparent
      elevation: 0, // No shadow
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      // We will place all content within flexibleSpace now
      title: const SizedBox
          .shrink(), // Empty title since content is in flexibleSpace
      actions: const [], // Empty actions as buttons are in flexibleSpace

      flexibleSpace: Container(
        // This container will fill the entire preferredSize area
        // We add padding for the status bar at the top
        padding: EdgeInsets.only(
            top: statusBarHeight + 20.0,
            left: 16.0,
            right: 16.0,
            bottom: 10.0), // Adjust top/bottom padding as needed
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .end, // Align content to the bottom of the flexible space
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align row content to the start
          children: [
            // Your original Row content
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: logo,
                  radius: 20,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onSearchPressed,
                  child: SvgPicture.asset(
                    'assets/icons/search.svg',
                    color: Colors.white,
                    height: 20,
                  ),
                ),
                SizedBox(width: 16), // Space between icons
                GestureDetector(
                  onTap: onNotificationsPressed,
                  child: SvgPicture.asset(
                    'assets/icons/noti.svg',
                    color: Colors.white,
                    height: 20,
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: onProfilePressed,
                  child: SvgPicture.asset(
                    'assets/icons/profile.svg',
                    color: Colors.white,
                    height: 20,
                  ),
                ),
              ],
            ),
            // Add other widgets here if you want to fill the 300 height
            // For example, a large title or some text:
            // const SizedBox(height: 20), // Spacer
            // const Text(
            //   "Your App Title",
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 28,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // const Text(
            //   "Slogan or Subtitle here",
            //   style: TextStyle(
            //     color: Colors.white70,
            //     fontSize: 16,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(90.0); // Now this height will be fully utilized
}
