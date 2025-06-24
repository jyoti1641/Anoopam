// lib/services/api_service.dart
import 'dart:convert';
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for your mock API
  final String baseUrl =
      "https://6849602745f4c0f5ee712561.mockapi.io/api/v1/audio";

  // Fetches a list of all albums from the API
  Future<List<AlbumModel>> fetchAlbums() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        // Decode the JSON array from the response body
        List<dynamic> body = json.decode(response.body);
        // Map each item in the JSON array to an AlbumModel object
        return body.map((dynamic item) => AlbumModel.fromJson(item)).toList();
      } else {
        // Throw an exception for non-200 status codes
        throw Exception('Failed to load albums: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any network or parsing errors
      throw Exception('Failed to connect to API: $e');
    }
  }

  // Fetches songs for a specific album by its ID.
  // This assumes your backend has an endpoint like /audio/{id} that returns
  // the album object including its songs. If not, you would filter the list
  // obtained from `fetchAlbums()` instead.
  Future<List<AudioModel>> getSongsByAlbum(String albumId) async {
    try {
      // Construct the URL for a single album
      final response = await http.get(Uri.parse('$baseUrl/$albumId'));

      if (response.statusCode == 200) {
        // Decode the JSON object for the single album
        Map<String, dynamic> body = json.decode(response.body);
        // Parse the 'songs' list from the album data
        var songsList = body['songs'] as List;
        return songsList
            .map((dynamic item) => AudioModel.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'Failed to load songs for album $albumId: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch album songs: $e');
    }
  }
}
