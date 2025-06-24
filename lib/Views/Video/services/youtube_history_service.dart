import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video.dart'; // Use the shared model

class YouTubeHistoryService {
  static Future<List<Video>> getWatchedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('recently_watched') ?? [];

    return history.map((jsonStr) {
      final data = jsonDecode(jsonStr);
      return Video(
        videoId: data['videoId'],
        title: data['title'],
        thumbnailUrl: data['thumbnailUrl'],
        publishedAt: DateTime.parse(data['publishedAt']),
        description: '',
        channelTitle: '',
      );
    }).toList();
  }

  static Future<void> addToHistory(Video video) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('recently_watched') ?? [];

    // Avoid duplicates based on videoId
    history.removeWhere((item) => jsonDecode(item)['videoId'] == video.videoId);

    // Add new video to the top
    history.insert(
      0,
      jsonEncode({
        'videoId': video.videoId,
        'title': video.title,
        'thumbnailUrl': video.thumbnailUrl,
        'publishedAt': video.publishedAt.toIso8601String(),
      }),
    );

    // Limit to 10 most recent videos
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }

    await prefs.setStringList('recently_watched', history);
  }
}
