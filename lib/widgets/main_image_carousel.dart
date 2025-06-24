// main_image_carousel.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:anoopam_mission/models/image_model.dart';
import 'package:anoopam_mission/services/image_service.dart';
import 'package:anoopam_mission/Views/Home/fullscreen_image_viewer.dart';

class MainImageCarousel extends StatefulWidget {
  const MainImageCarousel({super.key});

  @override
  State<MainImageCarousel> createState() => _MainImageCarouselState();
}

class _MainImageCarouselState extends State<MainImageCarousel> {
  final ImageService _imageService = ImageService();
  List<ImageModel> _mainCarouselImages = []; // Stores one image per location
  bool _isLoading = true;
  int _currentImageIndex = 0; // For page indicator

  @override
  void initState() {
    super.initState();
    _fetchMainCarouselImages();
  }

  Future<void> _fetchMainCarouselImages() async {
    try {
      final fetchedImages = _imageService.getMainCarouselImages();
      setState(() {
        _mainCarouselImages = fetchedImages;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching main carousel images: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mainCarouselImages.isEmpty) {
      return const Center(child: Text('No main images available.'));
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _mainCarouselImages.length,
          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
            final image = _mainCarouselImages[itemIndex];
            return GestureDetector(
              onTap: () {
                // Fetch all images related to the tapped image's location
                final List<ImageModel> relatedImages = _imageService.getImagesByLocation(image.locationName);

                // Find the index of the tapped image within the relatedImages list
                int initialRelatedIndex = relatedImages.indexWhere((img) => img.id == image.id);
                if (initialRelatedIndex == -1 && relatedImages.isNotEmpty) {
                  initialRelatedIndex = 0; // Fallback if not found
                } else if (relatedImages.isEmpty) {
                   initialRelatedIndex = 0; // Handle empty case
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      initialIndex: initialRelatedIndex,
                      images: relatedImages, // Pass the filtered list of related images for the location
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Hero(
                    tag: 'image_${image.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        image.url,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.broken_image, color: Colors.red)),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((255 * 0.4).round()),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            image.locationName, // Display the location name
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                           Text(
                            image.date, // Display the date
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: 250.0,
            enlargeCenterPage: true,
            autoPlay: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _mainCarouselImages.asMap().entries.map((entry) {
            final Color baseColor = Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black;

            final double opacity = _currentImageIndex == entry.key ? 0.9 : 0.4;
            final int alpha = (255 * opacity).round();

            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: baseColor.withAlpha(alpha),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}


// // main_image_carousel.dart
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:anoopam_mission/models/image_model.dart';
// import 'package:anoopam_mission/services/image_service.dart'; // Use the updated service
// import 'package:anoopam_mission/Views/Home/fullscreen_image_viewer.dart';

// class MainImageCarousel extends StatefulWidget {
//   const MainImageCarousel({super.key});

//   @override
//   State<MainImageCarousel> createState() => _MainImageCarouselState();
// }

// class _MainImageCarouselState extends State<MainImageCarousel> {
//   final ImageService _imageService = ImageService();
//   List<ImageModel> _allImages = []; // Stores all fetched images
//   List<ImageModel> _mainCarouselImages = []; // Stores only main category images
//   bool _isLoading = true;
//   int _currentImageIndex = 0; // For page indicator

//   @override
//   void initState() {
//     super.initState();
//     _fetchAndFilterImages();
//   }

//   Future<void> _fetchAndFilterImages() async {
//     try {
//       final fetchedImages = await _imageService.fetchAllCategoriesAndImages();
//       setState(() {
//         _allImages = fetchedImages;
//         // Filter for main carousel: only items where mainCatID is "0"
//         _mainCarouselImages = fetchedImages
//             .where((image) => image.mainCatID == "0")
//             .toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching images: $e');
//       setState(() {
//         _isLoading = false;
//       });
//       // Optionally show a user-friendly error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to load images: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // // Helper to get all images for a specific mainCatID
//   // List<ImageModel> _getRelatedImages(String mainCatID) {
//   //   if (mainCatID == "0") {
//   //     // If it's a main category (mainCatID="0"), only show that single image
//   //     // Or, if you want to show all images for that mainCatID "0" (which typically represents the top level),
//   //     // you might need a different logic or if there are no subcategories.
//   //     // For now, let's assume tapping a mainCatID="0" image shows only itself if it has no sub-images.
//   //     // If you want ALL images with catID matching this mainCatID (e.g., if mainCatID="0" implies a top level category),
//   //     // then you'd filter differently here.
//   //     // Let's assume you want to show all images where its mainCatID matches the catID of the tapped main carousel image.
//   //     final tappedCatID = _mainCarouselImages.firstWhere((img) => img.mainCatID == mainCatID, orElse: () => _mainCarouselImages[0]).catID;
//   //     return _allImages.where((image) => image.mainCatID == tappedCatID || image.catID == tappedCatID).toList();
//   //   } else {
//   //     // If it's a sub-category image (which won't be in the main carousel here),
//   //     // this method should still return images related to its mainCatID.
//   //     return _allImages
//   //         .where((image) => image.mainCatID == mainCatID || image.catID == mainCatID)
//   //         .toList();
//   //   }
//   // }


//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_mainCarouselImages.isEmpty) {
//       return const Center(child: Text('No main images available.'));
//     }

//     return Column(
//       children: [
//         CarouselSlider.builder(
//           itemCount: _mainCarouselImages.length, // Use _mainCarouselImages
//           itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
//             final image = _mainCarouselImages[itemIndex]; // Use image from main carousel list
//             return GestureDetector(
//               onTap: () {
//                 // Get all related images for this specific main category
//                 final List<ImageModel> relatedImages = _allImages
//                     .where((img) => img.mainCatID == image.catID || img.catID == image.catID) // Match by category ID of the tapped image
//                     .toList();

//                 // Find the index of the tapped image within the relatedImages list
//                 int initialRelatedIndex = relatedImages.indexWhere((img) => img.id == image.id);
//                 if (initialRelatedIndex == -1 && relatedImages.isNotEmpty) {
//                   initialRelatedIndex = 0; // Fallback if not found (shouldn't happen if logic is correct)
//                 } else if (relatedImages.isEmpty) {
//                    initialRelatedIndex = 0; // Handle empty case
//                 }

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => FullScreenImageViewer(
//                       initialIndex: initialRelatedIndex,
//                       images: relatedImages, // Pass the filtered list of related images
//                     ),
//                   ),
//                 );
//               },
//               child: Stack(
//                 children: [
//                   Hero(
//                     tag: 'image_${image.id}',
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8.0),
//                       child: Image.network(
//                         image.thumbnailUrl, // Use thumbnailUrl from ImageModel
//                         fit: BoxFit.cover,
//                         width: MediaQuery.of(context).size.width,
//                         errorBuilder: (context, error, stackTrace) =>
//                             const Center(child: Icon(Icons.broken_image, color: Colors.red)),
//                         loadingBuilder: (context, child, loadingProgress) {
//                           if (loadingProgress == null) return child;
//                           return Center(
//                             child: CircularProgressIndicator(
//                               value: loadingProgress.expectedTotalBytes != null
//                                   ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                   : null,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withAlpha((255 * 0.4).round()),
//                         borderRadius: const BorderRadius.only(
//                           bottomLeft: Radius.circular(8.0),
//                           bottomRight: Radius.circular(8.0),
//                         ),
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
//                         children: [
//                           Text(
//                             image.title, // Display the category name as title
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             maxLines: 1, // Prevent long titles from wrapping excessively
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           // Removed static "Mogri, IN" and "Dec 03, 2024"
//                           // If you have date/location data in your API for each image, you'd add it here dynamically.
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//           options: CarouselOptions(
//             height: 250.0,
//             enlargeCenterPage: true,
//             autoPlay: true,
//             aspectRatio: 16 / 9,
//             autoPlayCurve: Curves.fastOutSlowIn,
//             enableInfiniteScroll: true,
//             autoPlayAnimationDuration: const Duration(milliseconds: 800),
//             viewportFraction: 0.8,
//             onPageChanged: (index, reason) {
//               setState(() {
//                 _currentImageIndex = index;
//               });
//             },
//           ),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: _mainCarouselImages.asMap().entries.map((entry) { // Use _mainCarouselImages here too
//             final Color baseColor = Theme.of(context).brightness == Brightness.dark
//                 ? Colors.white
//                 : Colors.black;

//             final double opacity = _currentImageIndex == entry.key ? 0.9 : 0.4;
//             final int alpha = (255 * opacity).round();

//             return Container(
//               width: 8.0,
//               height: 8.0,
//               margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: baseColor.withAlpha(alpha),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }
