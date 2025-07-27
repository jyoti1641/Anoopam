import 'dart:convert';

import 'package:anoopam_mission/models/audio_item.dart';
import 'package:anoopam_mission/models/audio_track.dart';
import 'package:http/http.dart' as http;

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

Future<List<AudioTrack>> fetchAudioTracks() async {
  final response = await http.get(
      Uri.parse('http://687e0618c07d1a878c30e84b.mockapi.io/api/v1/Audio'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    return body.map((dynamic item) => AudioTrack.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load audio tracks');
  }
}
