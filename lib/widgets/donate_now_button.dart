// lib/widgets/donate_now_button.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Required for launching URLs
import 'package:easy_localization/easy_localization.dart';

class DonateNowButton extends StatelessWidget {
  // You can optionally add parameters here if you want *some* customization
  // for this specific Donate Now button, e.g., final String? customText;
  const DonateNowButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly return the MaterialButton with all its properties
    return MaterialButton(
      onPressed: () async {
        final Uri url = Uri.parse('https://anoopam.org/donatenow/');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          // Fallback if the URL cannot be launched
          print('Could not launch $url');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('donateNow.couldNotOpenLink'.tr())),
          );
        }
      },
      color: const Color(0xff3a57e8), // Specific color for this button
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Specific border radius
      ),
      padding: const EdgeInsets.all(16), // Specific padding
      textColor: const Color(0xffffffff), // Specific text color
      height: 40, // Specific height
      minWidth: 140, // Specific min width
      child: Text(
        'donateNow.button'.tr(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }
}
