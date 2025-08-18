import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:easy_localization/easy_localization.dart';

class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildActionButton(
              context,
              imagePath: 'assets/icons/mantralekhan.png', // Your image path
              label: 'menu.mantralekhan'.tr(),
              onTap: () {
                print('Mantralekhan tapped!');
                // Navigate to Mantralekhan screen
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              imagePath: 'assets/icons/events.png',
              label: 'menu.events'.tr(),
              onTap: () {
                print('Events tapped!');
                // Navigate to Events screen
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              imagePath: 'assets/icons/brahmanirzar.png',
              label: 'menu.brahmanirzar'.tr(),
              onTap: () {
                print('Brahmanirzar tapped!');
                // Navigate to Brahmanirzar screen
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              imagePath: 'assets/icons/activities.png',
              label: 'menu.activities'.tr(),
              onTap: () {
                print('Activities tapped!');
                // Navigate to Activities screen
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              imagePath:
                  'assets/icons/donation.png', //Change this to a Donation icon
              label: 'menu.donation'.tr(),
              onTap: () async {
                // Make onTap async
                final Uri url = Uri.parse('https://anoopam.org/donatenow/');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  print('Could not launch $url');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('homeAction.couldNotOpenDonate'.tr())),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(
                10.0), // Padding inside the circular button
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              imagePath,
              width: 55, // Adjust image size as needed, original was 30
              height: 55, // Adjust image size as needed, original was 30
              errorBuilder: (context, error, stackTrace) {
                print('Error loading asset image $imagePath: $error');
                return const Icon(Icons.error,
                    color: Colors.red, size: 30); // Shows a red error icon
              },
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onBackground, // Changed to white70 for dark background, matching your design
            fontSize: 14, // Adjusted font size to 12 as per your image
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
