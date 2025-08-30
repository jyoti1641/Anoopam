// lib/services/api_service.dart
import 'dart:convert';
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/category_item.dart';
// import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://anoopam.org/wp-json/mobile/v1';

  Future<Map<String, dynamic>> fetchAudioHomeData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/audio'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<AlbumModel> latestAudio = (data['latest_audio'] as List)
            .map((item) => AlbumModel.fromLatestOrFeaturedJson(item))
            .toList();
        // print(latestAudio);

        List<AlbumModel> featuredAudio = (data['featured_audio'] as List)
            .map((item) => AlbumModel.fromLatestOrFeaturedJson(item))
            .toList();
        // print(featuredAudio);

        List<CategoryItem> categories = (data['audio_categories'] as List)
            .map((item) => CategoryItem.fromJson(item))
            .toList();
        // print(categories);

        return {
          'latest': latestAudio,
          'featured': featuredAudio,
          'categories': categories,
        };
      } else {
        throw Exception(
            'Failed to load audio home data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<AlbumModel> fetchAlbumDetails(int albumId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/audio/$albumId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // print(data);
        return AlbumModel.fromDetailsJson(data);
      } else {
        throw Exception(
            'Failed to load album details for ID $albumId: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch album details: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCategoryContent(int categoryId) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/audio-category/$categoryId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // The API response for this endpoint is needed to complete this method.
        // I will wait for you to provide the JSON from this endpoint.
        // For now, I'll return a placeholder.
        return data;
      } else {
        throw Exception(
            'Failed to load category content for ID $categoryId: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch category content: $e');
    }
  }
}
