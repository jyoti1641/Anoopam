import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video.dart';

class FavoritesProvider with ChangeNotifier {
  List<Video> _favorites = [];
  bool _isLoading = false;

  List<Video> get favorites => _favorites;
  bool get isLoading => _isLoading;
  int get favoritesCount => _favorites.length;

  // Check if a video is favorited
  bool isFavorite(String videoId) {
    return _favorites.any((video) => video.videoId == videoId);
  }

  // Add video to favorites
  Future<void> addToFavorites(Video video) async {
    if (!isFavorite(video.videoId)) {
      _favorites.add(video);
      await _saveFavorites();
      notifyListeners();
    }
  }

  // Remove video from favorites
  Future<void> removeFromFavorites(String videoId) async {
    _favorites.removeWhere((video) => video.videoId == videoId);
    await _saveFavorites();
    notifyListeners();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Video video) async {
    if (isFavorite(video.videoId)) {
      await removeFromFavorites(video.videoId);
    } else {
      await addToFavorites(video);
    }
  }

  // Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorites') ?? [];
      
      _favorites = favoritesJson
          .map((json) => _videoFromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading favorites: $e');
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites
          .map((video) => jsonEncode(_videoToJson(video)))
          .toList();
      
      await prefs.setStringList('favorites', favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
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

  // Clear all favorites
  Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    notifyListeners();
  }
} 