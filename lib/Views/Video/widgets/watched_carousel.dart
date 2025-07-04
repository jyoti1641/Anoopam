import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video.dart';
import '../screens/video_player_screen.dart';

class WatchedCarousel extends StatefulWidget {
  const WatchedCarousel({super.key});

  @override
  State<WatchedCarousel> createState() => _WatchedCarouselState();
}

class _WatchedCarouselState extends State<WatchedCarousel> {
  List<Video> _watchedVideos = [];

  @override
  void initState() {
    super.initState();
    _loadWatchedVideos();
  }

  Future<void> _loadWatchedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('recently_watched') ?? [];

    setState(() {
      _watchedVideos = history.map((item) {
        final data = jsonDecode(item);
        return Video(
          videoId: data['videoId'],
          title: data['title'],
          thumbnailUrl: data['thumbnailUrl'],
          publishedAt: DateTime.parse(data['publishedAt']),
          description: '',
          channelTitle: '',
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_watchedVideos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'Recently Watched',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _watchedVideos.length,
            itemBuilder: (context, index) {
              final video = _watchedVideos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(video: video),
                    ),
                  );
                },
                child: Container(
                  width: 280,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 12 : 8,
                    right: index == _watchedVideos.length - 1 ? 12 : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          video.thumbnailUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black.withOpacity(0.6),
                            child: Text(
                              video.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
