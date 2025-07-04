import 'package:anoopam_mission/Views/Profile/profile_screen.dart';
import 'package:anoopam_mission/widgets/activities_section.dart';
import 'package:anoopam_mission/widgets/amrut_vachan_section.dart';
import 'package:anoopam_mission/widgets/latest_audio_section.dart';
import 'package:anoopam_mission/widgets/sahebji_videos.dart';
import 'package:anoopam_mission/widgets/vandan_sahebji_section.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/widgets/homepage_appbar.dart';
import 'package:anoopam_mission/widgets/main_image_carousel.dart';
import 'package:anoopam_mission/widgets/home_action_button.dart'; // Make sure this import matches your file name (singular 'button')
import 'package:anoopam_mission/widgets/sahebjji_ma_bole_section.dart';
import 'package:anoopam_mission/widgets/donate_now_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: HomePageAppBar(
        logo: const AssetImage('assets/logos/Mission.png'),
        onSearchPressed: () {
          print('Search icon pressed!');
        },
        onNotificationsPressed: () {
          print('Notifications icon pressed!');
        },
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Your main image carousel (now includes location/date overlay)
            const SizedBox(
              height: 290, // Fixed height for the carousel
              child: MainImageCarousel(),
            ),

            // The row of circular action buttons
            const HomeActionButtons(),
            const SizedBox(height: 16),

            // The "Sahebjji Ma Bole Shree Hari Re" section
            const SahebjjiMaBoleSection(),
            const SizedBox(height: 16),

            // The "Vandan Sahebjji" section
            const VandanSahebjiSection(),
            const SizedBox(height: 16),

            // The "Sahebjji Videos" section
            const SahebjiVideosSection(),
            const SizedBox(height: 16),

            // The "Amrut Vachan" section
            const AmrutVachanSection(),
            const SizedBox(height: 16),

            // The "Latest Audio" section
            const LatestAudioSection(),
            const SizedBox(height: 16),

            // The "Activities" section
            const ActivitiesSection(),
            const SizedBox(height: 16),

            // //Donate Now Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: const DonateNowButton(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
