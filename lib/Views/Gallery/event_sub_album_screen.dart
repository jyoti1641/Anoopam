// lib/screens/event_sub_album_screen.dart

import 'package:anoopam_mission/Views/Gallery/event_photo_detail.dart';
import 'package:anoopam_mission/Views/Gallery/photo_grid_screen.dart';
import 'package:anoopam_mission/models/event.dart';
import 'package:flutter/material.dart';

class EventSubAlbumScreen extends StatelessWidget {
  final SubEvent subEvent;
  final String parentTitle;

  const EventSubAlbumScreen({
    Key? key,
    required this.subEvent,
    required this.parentTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subEvent.eventName),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 1,
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Column(
        children: [
          // A simple button to navigate to a linked gallery if it exists
          if (subEvent.galleryId != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Re-using the PhotoGridScreen for the gallery
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoGridScreen(
                        albumId: subEvent.galleryId!,
                        albumName: 'View Gallery: ${subEvent.eventName}',
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
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              padding: const EdgeInsets.all(16),
              itemCount: subEvent.photos.length,
              itemBuilder: (context, index) {
                final photo = subEvent.photos[index];
                final heroTag =
                    'subevent-${subEvent.eventName.hashCode}-photo-$index';
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
