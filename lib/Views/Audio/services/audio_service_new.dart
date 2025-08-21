// // lib/services/api_service.dart
// import 'dart:convert';
// import 'package:anoopam_mission/Views/Audio/models/album.dart';
// import 'package:anoopam_mission/Views/Audio/models/category_item.dart';
// import 'package:anoopam_mission/Views/Audio/models/song.dart';
// import 'package:http/http.dart' as http;

// class ApiService {
//   // Base URL for your mock API
//   final String baseUrl =
//       "https://6849602745f4c0f5ee712561.mockapi.io/api/v1/audio";

//   // Fetches a list of all albums from the API
//   Future<List<AlbumModel>> fetchAlbums() async {
//     try {
//       final response = await http.get(Uri.parse(baseUrl));

//       if (response.statusCode == 200) {
//         // Decode the JSON array from the response body
//         List<dynamic> body = json.decode(response.body);
//         // Map each item in the JSON array to an AlbumModel object
//         return body.map((dynamic item) => AlbumModel.fromJson(item)).toList();
//       } else {
//         // Throw an exception for non-200 status codes
//         throw Exception('Failed to load albums: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Catch any network or parsing errors
//       throw Exception('Failed to connect to API: $e');
//     }
//   }

//   // Fetches songs for a specific album by its ID.
//   // This assumes your backend has an endpoint like /audio/{id} that returns
//   // the album object including its songs. If not, you would filter the list
//   // obtained from `fetchAlbums()` instead.
//   Future<List<AudioModel>> getSongsByAlbum(String albumId) async {
//     try {
//       // Construct the URL for a single album
//       final response = await http.get(Uri.parse('$baseUrl/$albumId'));

//       if (response.statusCode == 200) {
//         // Decode the JSON object for the single album
//         Map<String, dynamic> body = json.decode(response.body);
//         // Parse the 'songs' list from the album data
//         var songsList = body['songs'] as List;
//         return songsList
//             .map((dynamic item) => AudioModel.fromJson(item))
//             .toList();
//       } else {
//         throw Exception(
//             'Failed to load songs for album $albumId: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch album songs: $e');
//     }
//   }

//   Future<List<CategoryItem>> fetchMainCategories() async {
//     try {
//       final response = await http.get(Uri.parse(
//           'https://api.anoopam.org/api/ams/v4_1/app-fetch-audio.php?device_channel=MOBILE&device_os_platform=IOS'));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         final List<dynamic> categoriesJson = data['categories'];

//         // Filter for categories where "mainCatID" is "0"
//         List<CategoryItem> mainCategories = categoriesJson
//             .where((json) => json['mainCatID'] == '0')
//             .map((json) => CategoryItem.fromJson(json))
//             .toList();

//         // Sort the categories alphabetically by catName
//         mainCategories.sort((a, b) => a.title.compareTo(b.title));

//         return mainCategories;
//       } else {
//         throw Exception(
//             'Failed to load categories: Status Code ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Failed to connect or parse API response: $e');
//     }
//   }
// }

// lib/services/api_service.dart
import 'dart:convert';
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/category_item.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
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
        throw Exception('Failed to load audio home data: ${response.statusCode}');
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
        throw Exception('Failed to load album details for ID $albumId: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch album details: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCategoryContent(int categoryId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/audio-category/$categoryId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // The API response for this endpoint is needed to complete this method.
        // I will wait for you to provide the JSON from this endpoint.
        // For now, I'll return a placeholder.
        return data; 
      } else {
        throw Exception('Failed to load category content for ID $categoryId: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch category content: $e');
    }
  }
}