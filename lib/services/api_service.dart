import 'package:flutter/foundation.dart';
import 'package:anoopam_mission/models/audio_item.dart';

class ApiService {
  Future<List<AudioItem>> fetchAudioItems() async {
    try {
      // Since we're using Spotify only, return empty list or mock data
      // You can implement Spotify API calls here if needed
      return [];
    } catch (e) {
      throw Exception('Failed to connect to the API: $e');
    }
  }
}
