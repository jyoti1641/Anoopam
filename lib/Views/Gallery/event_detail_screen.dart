// lib/screens/event_detail_screen.dart

import 'package:anoopam_mission/Views/Gallery/event_photo_detail.dart';
import 'package:anoopam_mission/Views/Gallery/event_sub_album_screen.dart';
import 'package:anoopam_mission/Views/Gallery/photo_detail_screen.dart';
import 'package:anoopam_mission/data/photo_service.dart';
import 'package:anoopam_mission/models/event.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import 'photo_grid_screen.dart'; // Re-use the existing photo grid for gallery

class EventDetailScreen extends StatefulWidget {
  final int eventId;
  final String eventTitle;

  const EventDetailScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final PhotoApiService _eventsRepository = PhotoApiService();

  EventDetails? _eventDetails;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await _eventsRepository.getEventDetails(widget.eventId);
      if (!mounted) return;
      setState(() {
        _eventDetails = details;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // A helper function to build the main content based on the event details
  Widget _buildContent(EventDetails details) {
    if (details.hasSubEvent) {
      // If there are sub-events, show a grid of them
      final subEvents =
          (details.data as List).map((e) => SubEvent.fromJson(e)).toList();
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: subEvents.length,
        itemBuilder: (context, index) {
          final subEvent = subEvents[index];
          return GestureDetector(
            onTap: () {
              // Navigate to a new screen to show sub-event photos
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventSubAlbumScreen(
                    subEvent: subEvent,
                    parentTitle: details.title,
                  ),
                ),
              );
            },
            child: AlbumCard(
              albumName: subEvent.eventName,
              thumbnailUrl: subEvent.coverImage,
              showDate: true,
              date: subEvent.eventDate,
            ),
          );
        },
      );
    } else {
      // If no sub-events, show the photos directly
      final photos =
          (details.data as Map<String, dynamic>)['photos'] as List? ?? [];
      final eventPhotos = photos.map((p) => EventPhoto.fromJson(p)).toList();

      return Column(
        children: [
          // Show a "View Gallery" button if a galleryId exists
          if (details.galleryId != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the photo grid for the linked gallery
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoGridScreen(
                        albumId: details.galleryId!,
                        albumName: 'View Gallery: ${details.title}',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('View Linked Gallery'),
              ),
            ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              padding: const EdgeInsets.all(16),
              itemCount: eventPhotos.length,
              itemBuilder: (context, index) {
                final photo = eventPhotos[index];
                final heroTag = 'event-${details.id}-photo-$index';
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventPhotoDetailScreen(
                            eventPhoto: photo, heroTag: heroTag),
                      ),
                    );
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Hero(
                        tag: heroTag,
                        child: Image.network(
                          photo.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      )),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.eventTitle,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 1,
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _eventDetails == null
                  ? const Center(child: Text('Event details not found.'))
                  : _buildContent(_eventDetails!),
    );
  }
}

// Re-using the existing AlbumCard widget is a good practice.
// If you don't have it, here's a basic implementation:
class AlbumCard extends StatelessWidget {
  final String albumName;
  final String thumbnailUrl;
  final bool showDate;
  final String? date;

  const AlbumCard({
    Key? key,
    required this.albumName,
    required this.thumbnailUrl,
    this.showDate = false,
    this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.currentTheme == ThemeMode.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                  child:
                      Icon(Icons.broken_image, size: 50, color: Colors.grey)),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDate)
                      Container(
                        decoration: BoxDecoration(
                          border:
                              BoxBorder.all(color: Colors.white70, width: 1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2),
                          child: Text(
                            date ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      albumName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        // shadows: [
                        //   Shadow(
                        //     blurRadius: 3.0,
                        //     color: Colors.black,
                        //     offset: Offset(1.0, 1.0),
                        //   ),
                        // ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
