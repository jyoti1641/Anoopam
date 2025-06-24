import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';

class YouTubeService {
  final String apiKey;
  final String channelId;

  YouTubeService({required this.apiKey, required this.channelId});

  // Test network connectivity
  Future<bool> testNetworkConnection() async {
    try {
      print("Testing network connection...");
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(
        const Duration(seconds: 10),
      );
      print("Network test successful: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("Network test failed: $e");
      return false;
    }
  }

  // Fetch channel videos with pagination - returns Video objects
  Future<VideoResult> getVideos({
    int maxResults = 10,
    String? nextPageToken,
  }) async {
    print("=== YOUTUBE SERVICE DEBUG ===");
    print("API Key: ${apiKey.isNotEmpty ? 'Present' : 'MISSING'}");
    print("Channel ID: $channelId");
    
    // Test network first
    final hasNetwork = await testNetworkConnection();
    if (!hasNetwork) {
      throw Exception('No internet connection available');
    }
    
    final queryParams = {
      'part': 'snippet',
      'channelId': channelId,
      'maxResults': maxResults.toString(),
      'order': 'date',
      'type': 'video',
      'key': apiKey,
    };
    
    if (nextPageToken != null) {
      queryParams['pageToken'] = nextPageToken;
    }
    
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', queryParams);
    print("Making request to: $uri");
    print("============================");

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );
      print("Response status: ${response.statusCode}");
      print("Response body length: ${response.body.length}");

      if (response.statusCode == 200) {
        try {
          final body = jsonDecode(response.body);
          final items = body['items'] as List;
          final nextPageToken = body['nextPageToken'];
          print("Found ${items.length} items in response");

          final videos = items
              .where(
                (item) =>
                    item['id'] != null &&
                    item['id']['videoId'] != null &&
                    item['snippet'] != null,
              )
              .map((item) => Video.fromJson(item))
              .toList();
          
          print("Successfully parsed ${videos.length} videos");
          return VideoResult(
            videos: videos,
            nextPageToken: nextPageToken,
          );
        } catch (e) {
          print("JSON parsing error: $e");
          throw Exception('Failed to parse YouTube data: $e');
        }
      } else {
        print("HTTP Error: ${response.statusCode} - ${response.reasonPhrase}");
        print("Response body: ${response.body}");
        throw Exception(
          'Failed to fetch videos [${response.statusCode}]: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print("Network/HTTP error: $e");
      throw Exception('Network error: $e');
    }
  }

  // Search videos within the channel - returns Video objects
  Future<VideoResult> searchVideos({
    required String query,
    int maxResults = 10,
    String? nextPageToken,
  }) async {
    final queryParams = {
      'part': 'snippet',
      'channelId': channelId,
      'q': query,
      'maxResults': maxResults.toString(),
      'order': 'relevance',
      'type': 'video',
      'key': apiKey,
    };
    
    if (nextPageToken != null) {
      queryParams['pageToken'] = nextPageToken;
    }
    
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', queryParams);
    
    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final items = body['items'] as List;
        final nextPageToken = body['nextPageToken'];

        final videos = items
            .where(
              (item) =>
                  item['id'] != null &&
                  item['id']['videoId'] != null &&
                  item['snippet'] != null,
            )
            .map((item) => Video.fromJson(item))
            .toList();
        
        return VideoResult(
          videos: videos,
          nextPageToken: nextPageToken,
        );
      } else {
        throw Exception(
          'Failed to search videos [${response.statusCode}]: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  // Get detailed video information - returns Video object
  Future<Video> getVideoDetails(String videoId) async {
    final queryParams = {
      'part': 'snippet,statistics,contentDetails',
      'id': videoId,
      'key': apiKey,
    };
    
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', queryParams);
    
    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final items = body['items'] as List;
        
        if (items.isNotEmpty) {
          return Video.fromDetailedJson(items.first);
        } else {
          throw Exception('Video not found');
        }
      } else {
        throw Exception(
          'Failed to get video details [${response.statusCode}]: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Video details error: $e');
    }
  }

  // Get multiple video details - returns Video objects
  Future<List<Video>> getMultipleVideoDetails(List<String> videoIds) async {
    if (videoIds.isEmpty) return [];
    
    final queryParams = {
      'part': 'snippet,statistics,contentDetails',
      'id': videoIds.join(','),
      'key': apiKey,
    };
    
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', queryParams);
    
    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final items = body['items'] as List;
        
        return items.map((item) => Video.fromDetailedJson(item)).toList();
      } else {
        throw Exception(
          'Failed to get video details [${response.statusCode}]: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Video details error: $e');
    }
  }
}

// Result class for video operations
class VideoResult {
  final List<Video> videos;
  final String? nextPageToken;

  VideoResult({
    required this.videos,
    this.nextPageToken,
  });
}
