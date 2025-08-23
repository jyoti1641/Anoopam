// lib/services/photo_api_service.dart

import 'dart:convert';
import 'package:anoopam_mission/models/album.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:anoopam_mission/models/sahebji_darshan_models.dart';
import 'package:anoopam_mission/models/sahebji_ocassions.dart';
import 'package:anoopam_mission/models/thakorji_models.dart';
import 'package:anoopam_mission/models/wallpaper_models.dart';
import 'package:http/http.dart' as http;

class PhotoApiService {
  static const String mainBaseUrl = 'https://api-creation-vercel.vercel.app';
  static const String anoopamBaseUrl = 'https://anoopam.org/wp-json/mobile/v1';

  // This method now only fetches albums from the provided API.
  static Future<List<Album>> getAlbums() async {
    final response = await http.get(Uri.parse('$mainBaseUrl/posts'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Album.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load albums');
    }
  }

  // This method will get photos for the standard albums based on their ID.
  static Future<List<Photo>> getPhotosForAlbum(int albumId) async {
    final response = await http.get(
      Uri.parse('$mainBaseUrl/comments?postId=$albumId'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos for album $albumId');
    }
  }

  // New API call for Sahebji Darshan.
  static Future<List<dynamic>> getSahebjiDarshanPhotos() async {
    final response =
        await http.get(Uri.parse('$anoopamBaseUrl/sahebji-darshan'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Sahebji Darshan photos');
    }
  }

  // New methods for Sahebji Darshan
  static Future<SahebjiDarshanResponse> getSahebjiDarshanAlbums({
    int page = 1,
    String? startDate,
    String? endDate,
  }) async {
    String url = '$anoopamBaseUrl/sahebji-darshan?page=$page';

    if (startDate != null && endDate != null) {
      url = '$anoopamBaseUrl/sahebji-darshan?start=$startDate&end=$endDate';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return SahebjiDarshanResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Sahebji Darshan albums');
    }
  }

  static Future<SahebjiDarshanDetails> getSahebjiDarshanDetails(int id) async {
    final response =
        await http.get(Uri.parse('$anoopamBaseUrl/sahebji-darshan/$id'));

    if (response.statusCode == 200) {
      return SahebjiDarshanDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Sahebji Darshan details for ID: $id');
    }
  }

  // === Thakorji Darshan Specific APIs ===

  static Future<List<Country>> getThakorjiCountries() async {
    final response = await http.get(Uri.parse('$anoopamBaseUrl/countries'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Country.fromJson(json)).toList();
    } else {
      print(response.body);
      throw Exception('Failed to load Thakorji Darshan countries');
    }
  }

  static Future<List<CenterModel>> getThakorjiCenters(int countryId) async {
    final response = await http
        .get(Uri.parse('$anoopamBaseUrl/centers?country_id=$countryId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CenterModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load Thakorji Darshan centers for country ID: $countryId');
    }
  }

  static Future<ThakorjiDarshanDetails> getThakorjiPhotos(int centerId,
      {String? date}) async {
    final url = date != null
        ? '$anoopamBaseUrl/thakorji?center_id=$centerId&date=$date'
        : '$anoopamBaseUrl/thakorji?center_id=$centerId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // The API returns a list for the 'centers' endpoint, but a single object for 'thakorji'
      // The response is a list with one item, so we take the first item.
      final dynamic data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        return ThakorjiDarshanDetails.fromJson(data[0]['thakorji']);
      } else if (data is Map<String, dynamic>) {
        return ThakorjiDarshanDetails.fromJson(data);
      } else {
        throw Exception(
            'No Thakorji darshan photos found for center ID: $centerId');
      }
    } else {
      throw Exception('Failed to load Thakorji Darshan photos');
    }
  }

  // New API call for Sahebji Gallery. This fetches the list of categories.
  static Future<List<SahebjiOccasion>> getSahebjiOccasions() async {
    final response =
        await http.get(Uri.parse('$anoopamBaseUrl/sahebji-gallery-categories'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => SahebjiOccasion.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Sahebji occasions');
    }
  }

  static Future<List<String>> getSahebjiGallery(
      {int? year, int? occasionId}) async {
    String url = '$anoopamBaseUrl/sahebji-gallery';

    // Construct the URL with filters
    if (year != null || occasionId != null) {
      final Map<String, dynamic> queryParams = {};
      if (year != null) {
        queryParams['year'] = year.toString();
      }
      if (occasionId != null) {
        queryParams['occation'] = occasionId.toString();
      }
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      url = uri.toString();
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return List<String>.from(jsonList.map((e) => e.toString()));
    } else {
      throw Exception('Failed to load Sahebji gallery photos');
    }
  }

  // You can keep your other methods for specific dynamic IDs if needed,
  // but they are not used in the new UI logic.
  static Future<List<Photo>> getsahebjiPhotos() async {
    final response = await http.get(
      Uri.parse('$mainBaseUrl/comments?postId=2'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos for album of sahebji');
    }
  }

// New methods for Wallpapers
  static Future<List<WallpaperAlbum>> getWallpapers({String? year}) async {
    String url = '$anoopamBaseUrl/wallpapers';
    if (year != null) {
      url += '?year=$year';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => WallpaperAlbum.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }

  static Future<WallpaperDetails> getWallpaperDetails(int id) async {
    final response =
        await http.get(Uri.parse('$anoopamBaseUrl/wallpapers/$id'));
    if (response.statusCode == 200) {
      return WallpaperDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load wallpaper details for ID: $id');
    }
  }

  static Future<List<Photo>> activities() async {
    final response = await http.get(
      Uri.parse('$mainBaseUrl/comments?postId=4'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos for album of sahebji');
    }
  }

  static Future<Photo> getPhotoById(int photoId) async {
    final response =
        await http.get(Uri.parse('$mainBaseUrl/comments/$photoId'));
    if (response.statusCode == 200) {
      return Photo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load photo $photoId');
    }
  }
}
