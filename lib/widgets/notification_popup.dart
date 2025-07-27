import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anoopam_mission/providers/theme_provider.dart';

class NotificationPopup extends StatelessWidget {
  const NotificationPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeProvider>(context).currentTheme == ThemeMode.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final popupWidth = (screenWidth * 0.9).clamp(300.0, 400.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: popupWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Thumbnail image
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/icons/brahmanirzar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Brahmanirzar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Monthly Newsletter',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Download/Open button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle download/open action
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Opening Brahmanirzar...'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Download/Open',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
