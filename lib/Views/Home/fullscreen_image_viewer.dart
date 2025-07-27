import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:anoopam_mission/models/image_model.dart';
import 'package:anoopam_mission/widgets/fullscreen_image_appbar.dart'; // Import the new app bar widget

class FullScreenImageViewer extends StatefulWidget {
  final List<ImageModel> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late int _currentImageIndex;

  @override
  void initState() {
    super.initState();
    _currentImageIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: FullScreenImageAppBar(
        // title: widget.images.isNotEmpty
        //     ? widget.images[_currentImageIndex].name
        //     : 'Image',
        imageUrl: widget.images.isNotEmpty
            ? widget.images[_currentImageIndex].url
            : '', // Pass the current image URL
      ),
      body: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: widget.images.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) {
              final image = widget.images[itemIndex];
              return Center(
                child: Hero(
                  tag:
                      'image_${image.id}', // Match the tag from MainImageCarousel
                  child: Image.network(
                    image.url, // Use image.url for full screen
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 100),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
              initialPage: widget.initialIndex,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
          ),
          // Page Indicators at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? Colors.white.withAlpha((255 * 0.9).round())
                          : Colors.white.withAlpha((255 * 0.4).round()),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
