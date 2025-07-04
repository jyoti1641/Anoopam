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
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: logo,
              radius: 20,
            ),
            const Spacer(),
            IconButton(
              icon:
                  Icon(Icons.search, color: Theme.of(context).iconTheme.color),
              onPressed: onSearchPressed,
            ),
            IconButton(
              icon: Icon(Icons.notifications,
                  color: Theme.of(context).iconTheme.color),
              onPressed: onNotificationsPressed,
            ),
            IconButton(
              icon: Icon(Icons.account_circle,
                  color: Theme.of(context).iconTheme.color),
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
