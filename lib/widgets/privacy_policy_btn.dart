import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyButton extends StatelessWidget {
  const PrivacyPolicyButton({super.key}); // Added super.key for best practice

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse('https://anoopam.org/privacy-policy-general/');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          // Handle the error, e.g., show a SnackBar or log the error
          print('Could not launch $url');
          // Optionally, show a user-friendly message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open privacy policy')),
          );
        }
      },
      child: const Text(
        "Privacy Policy",
        textAlign: TextAlign.start,
        overflow: TextOverflow.clip,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
          fontSize: 14,
          color: Colors.indigo,
        ),
      ),
    );
  }
}
