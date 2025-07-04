import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video.dart';
import '../providers/favorites_provider.dart';
import '../providers/watch_history_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../screens/video_player_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final Widget? trailing;

  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.showFavoriteButton = true,
    this.trailing,
  });

  Future<void> _markAsWatched() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('recently_watched') ?? [];

    // Remove duplicates
    history.removeWhere((item) => jsonDecode(item)['videoId'] == video.videoId);

    // Insert latest watched video at the beginning
    history.insert(
      0,
      jsonEncode({
        'videoId': video.videoId,
        'title': video.title,
        'thumbnailUrl': video.thumbnailUrl,
        'publishedAt': video.publishedAt.toIso8601String(),
      }),
    );

    // Keep only the last 10 watched videos
    if (history.length > 10) history.removeLast();

    await prefs.setStringList('recently_watched', history);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () => _navigateToVideoPlayer(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with duration overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    video.thumbnailUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // Duration overlay
                if (video.formattedDuration.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                // Play button overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Video info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Channel and stats
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.channelTitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (video.formattedViewCount.isNotEmpty) ...[
                                  Flexible(
                                    child: Text(
                                      video.formattedViewCount,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Text(
                                    video.formattedPublishedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showFavoriteButton) ...[
                            Consumer<FavoritesProvider>(
                              builder: (context, favoritesProvider, child) {
                                final isFavorite =
                                    favoritesProvider.isFavorite(video.videoId);
                                return IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      favoritesProvider.toggleFavorite(video),
                                  tooltip: isFavorite
                                      ? 'Remove from favorites'
                                      : 'Add to favorites',
                                );
                              },
                            ),
                          ],
                          IconButton(
                            icon: Icon(
                              Icons.share,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: () => _shareVideo(context),
                            tooltip: 'Share video',
                          ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToVideoPlayer(BuildContext context) {
    try {
      if (video.videoId.isNotEmpty) {
        _addToWatchHistory(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(video: video),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('videoCard.invalidId'.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error navigating to video player: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('videoCard.failedToOpen'.tr()),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addToWatchHistory(BuildContext context) {
    try {
      // Add to watch history using Provider
      if (context.mounted) {
        context.read<WatchHistoryProvider>().addToHistory(video);
      }
    } catch (e) {
      print('Error adding to watch history: $e');
    }
  }

  void _shareVideo(BuildContext context) {
    Share.share(
      video.youtubeUrl,
      subject: video.title,
    );
  }
}
