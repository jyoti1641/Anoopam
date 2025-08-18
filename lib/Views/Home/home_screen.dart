import 'package:anoopam_mission/Views/Profile/profile_screen.dart';
import 'package:anoopam_mission/Views/Search/search_screen.dart';
import 'package:anoopam_mission/Views/Notification/notification_screen.dart';
import 'package:anoopam_mission/widgets/activities_section.dart';
import 'package:anoopam_mission/widgets/amrut_vachan_section.dart';
import 'package:anoopam_mission/widgets/latest_audio_section.dart';
import 'package:anoopam_mission/widgets/sahebji_videos.dart';
import 'package:anoopam_mission/widgets/vandan_sahebji_section.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/widgets/homepage_appbar.dart';
import 'package:anoopam_mission/widgets/home_action_button.dart';
import 'package:anoopam_mission/widgets/sahebjji_ma_bole_section.dart';
import 'package:anoopam_mission/widgets/donate_now_button.dart';
import 'package:anoopam_mission/widgets/notification_popup.dart';

// Imports required for carousel logic
import 'package:carousel_slider/carousel_slider.dart';
import 'package:anoopam_mission/models/image_model.dart'; // Assuming ImageModel path
import 'package:anoopam_mission/services/image_service.dart'; // Assuming ImageService path
import 'package:anoopam_mission/Views/Home/fullscreen_image_viewer.dart'; // Assuming FullScreenImageViewer path
import 'package:easy_localization/easy_localization.dart'; // For internationalization

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownPopup = false;

  final ImageService _imageService = ImageService();
  List<ImageModel> _mainCarouselImages = [];
  bool _isLoadingCarousel = true;
  // Removed _currentImageIndex as it's not needed without dots.
  // int _currentImageIndex = 0; // To get current image data for overlay - this logic will be slightly adjusted.

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // New variable to store the ImageModel of the currently displayed image for the overlay
  // ImageModel? _currentDisplayedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownPopup) {
        setState(() {
          _hasShownPopup = true;
        });
        showDialog(
          context: context,
          builder: (_) => const NotificationPopup(),
        );
      }
    });
    _fetchMainCarouselImages();
  }

  Future<void> _fetchMainCarouselImages() async {
    try {
      final fetchedImages = await _imageService.getMainCarouselImages();
      setState(() {
        _mainCarouselImages = fetchedImages;
        _isLoadingCarousel = false;
        // Set the initial displayed image
        // if (_mainCarouselImages.isNotEmpty) {
        //   _currentDisplayedImage = _mainCarouselImages[0];
        // }
      });
    } catch (e) {
      print('Error fetching main carousel images: $e');
      setState(() {
        _isLoadingCarousel = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('mainCarousel.failedToLoad'
              .tr(namedArgs: {'error': e.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carousel at the top of the body
            Stack(children: [
              SizedBox(
                height: 400, // Fixed height for the carousel
                child: _isLoadingCarousel
                    ? const Center(child: CircularProgressIndicator())
                    : _mainCarouselImages.isEmpty
                        ? Center(child: Text('mainCarousel.noImages'.tr()))
                        : CarouselSlider.builder(
                            carouselController: _carouselController,
                            itemCount: _mainCarouselImages.length,
                            itemBuilder: (BuildContext context, int itemIndex,
                                int pageViewIndex) {
                              final image = _mainCarouselImages[itemIndex];
                              return GestureDetector(
                                onTap: () async {
                                  final List<ImageModel> relatedImages =
                                      await _imageService.getImagesByLocation(
                                          image.locationName);
                                  int initialRelatedIndex = relatedImages
                                      .indexWhere((img) => img.id == image.id);
                                  if (initialRelatedIndex == -1 &&
                                      relatedImages.isNotEmpty) {
                                    initialRelatedIndex = 0;
                                  } else if (relatedImages.isEmpty) {
                                    initialRelatedIndex = 0;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FullScreenImageViewer(
                                        initialIndex: initialRelatedIndex,
                                        images: relatedImages,
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      // Keep borderRadius if you want rounded corners at screen edges
                                      // Set to BorderRadius.zero if you want sharp corners for a seamless fill
                                      // borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        image.url,
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: double
                                            .infinity, // Fill the SizedBox height
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Container(
                                                color: Colors.grey[300],
                                                child: const Center(
                                                    child: Icon(
                                                        Icons.broken_image,
                                                        color: Colors.red))),
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned.fill(
                                      // Make it fill the entire image area
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            stops: const [
                                              0.0,
                                              0.1,
                                              0.8,
                                              1.0
                                            ], // Stops define where colors are at
                                            colors: [
                                              Colors.black.withOpacity(
                                                  0.7), // Top shade
                                              Colors.black.withOpacity(
                                                  0.5), // Transparent in the middle
                                              Colors
                                                  .transparent, // Transparent in the middle
                                              Colors.black.withOpacity(
                                                  0.7), // Bottom shade (slightly stronger)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Location and Date Overlay - positioned absolutely within the Stack
                                    Positioned(
                                      bottom: 16,
                                      left: 0,
                                      right: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            image
                                                .locationName, // Dynamically from ImageModel
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  // blurRadius: 4.0,
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                  offset: Offset(0.5, 0.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            image
                                                .date, // Dynamically from ImageModel
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              shadows: [
                                                Shadow(
                                                  // blurRadius: 4.0,
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                  offset: Offset(0.5, 0.5),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 400.0, // Match the SizedBox height
                              enlargeCenterPage:
                                  false, // Set to false to remove enlargement
                              autoPlay: true,
                              aspectRatio: 16 / 9,
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enableInfiniteScroll: true,
                              autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                              autoPlayInterval: const Duration(seconds: 5),
                              viewportFraction:
                                  1.0, // Set to 1.0 for no space between images
                              onPageChanged: (index, reason) {
                                // This onPageChanged is not strictly needed for the overlay text
                                // as it's inside the itemBuilder's scope.
                                // Keeping it empty here as a placeholder if future logic needs it.
                              },
                            ),
                          ),
              ),
              HomePageAppBar(
                logo: const AssetImage('assets/logos/Mission.png'),
                onSearchPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                onNotificationsPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()),
                  );
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
            ]),

            // The row of circular action buttons
            const HomeActionButtons(),
            const SizedBox(height: 30),

            SahebjjiMaBoleSection(),
            const SizedBox(height: 16),

            const VandanSahebjiSection(),
            const SizedBox(height: 16),

            const SahebjiVideosSection(),
            const SizedBox(height: 16),

            const AmrutVachanSection(),
            const SizedBox(height: 16),

            const LatestAudioSection(),
            const SizedBox(height: 16),

            const ActivitiesSection(),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                    child: DonateNowButton(),
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
