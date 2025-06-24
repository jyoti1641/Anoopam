import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video.dart';

class WatchHistoryProvider with ChangeNotifier {
  List<Video> _watchHistory = [];
  bool _isLoading = false;
  static const int _maxHistorySize = 50; // Limit history to 50 videos

  List<Video> get watchHistory => _watchHistory;
  bool get isLoading => _isLoading;
  int get historyCount => _watchHistory.length;

  // Add video to watch history
  Future<void> addToHistory(Video video) async {
    // Remove if already exists (to move to top)
    _watchHistory.removeWhere((v) => v.videoId == video.videoId);
    
    // Add to beginning of list
    _watchHistory.insert(0, video);
    
    // Limit history size
    if (_watchHistory.length > _maxHistorySize) {
      _watchHistory = _watchHistory.take(_maxHistorySize).toList();
    }
    
    await _saveHistory();
    notifyListeners();
  }

  // Remove video from history
  Future<void> removeFromHistory(String videoId) async {
    _watchHistory.removeWhere((video) => video.videoId == videoId);
    await _saveHistory();
    notifyListeners();
  }

  // Clear all history
  Future<void> clearHistory() async {
    _watchHistory.clear();
    await _saveHistory();
    notifyListeners();
  }

  // Get recent videos (last N videos)
  List<Video> getRecentVideos(int count) {
    return _watchHistory.take(count).toList();
  }

  // Check if video is in history
  bool isInHistory(String videoId) {
    return _watchHistory.any((video) => video.videoId == videoId);
  }

  // Load history from SharedPreferences
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('watch_history') ?? [];
      
      _watchHistory = historyJson
          .map((json) => _videoFromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading watch history: $e');
      _watchHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save history to SharedPreferences
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _watchHistory
          .map((video) => jsonEncode(_videoToJson(video)))
          .toList();
      
      await prefs.setStringList('watch_history', historyJson);
    } catch (e) {
      print('Error saving watch history: $e');
    }
  }

  // Convert video to JSON for storage
  Map<String, dynamic> _videoToJson(Video video) {
    return {
      'videoId': video.videoId,
      'title': video.title,
      'description': video.description,
      'thumbnailUrl': video.thumbnailUrl,
      'channelTitle': video.channelTitle,
      'publishedAt': video.publishedAt.toIso8601String(),
      'duration': video.duration,
      'viewCount': video.viewCount,
      'likeCount': video.likeCount,
    };
  }

  // Convert JSON to video
  Video _videoFromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json['videoId'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      channelTitle: json['channelTitle'],
      publishedAt: DateTime.parse(json['publishedAt']),
      duration: json['duration'],
      viewCount: json['viewCount'],
      likeCount: json['likeCount'],
    );
  }
} 