import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video.dart';

class SharedPrefs {
  static const _watchedKey = 'recently_watched';

  /// Saves a [Video] to the recently watched list
  static Future<void> saveWatchedVideo(Video video) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(_watchedKey) ?? [];

    // Avoid duplicates
    currentList.removeWhere((item) {
      final data = jsonDecode(item);
      return data['videoId'] == video.videoId;
    });

    // Add to beginning of the list
    currentList.insert(
      0,
      jsonEncode({
        'videoId': video.videoId,
        'title': video.title,
        'thumbnailUrl': video.thumbnailUrl,
        'publishedAt': video.publishedAt.toIso8601String(),
      }),
    );

    // Optional: limit history size
    if (currentList.length > 20) {
      currentList.removeLast();
    }

    await prefs.setStringList(_watchedKey, currentList);
  }

  /// Returns the list of recently watched [Video]s
  static Future<List<Video>> getWatchedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_watchedKey) ?? [];

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

  /// Clears the watched video history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_watchedKey);
  }
}
