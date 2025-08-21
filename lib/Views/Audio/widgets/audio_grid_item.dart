// lib/Views/Audio/widgets/audio_grid_item.dart

import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
import 'package:flutter/material.dart';

class AudioGridItem extends StatelessWidget {
  const AudioGridItem({
    super.key,
    required this.album,
  });

  final AlbumModel album;

  @override
  Widget build(BuildContext) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          BuildContext,
          MaterialPageRoute(
            builder: (BuildContext) => AlbumDetailScreen(album: album),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            //  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                album.coverImage,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.album,
                        size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  );
                },
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  album.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // This could be used for artist name if available
              // Text(
              //   album.artist ?? 'Unknown Artist',
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: Colors.white.withOpacity(0.8),
              //   ),
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              // ),
            ],
          ),
          Positioned(
            bottom: 8.0,
            right: 8.0,
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                // Implement share functionality
                print('Share tapped for album: ${album.title}');
              },
            ),
          ),
        ],
      ),
    );
  }
}