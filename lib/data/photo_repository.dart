// import 'dart:ffi';

import 'dart:convert';
import 'dart:io';

import 'package:anoopam_mission/data/photo_service.dart';
import 'package:anoopam_mission/models/wallpaper_models.dart';
import 'package:http/http.dart' as http;

import '../models/album.dart';
import '../models/photo.dart';

class PhotoRepository {
  final http.Client _client = http.Client();
  Future<List<Album>> getAlbums() async {
    return await PhotoApiService.getAlbums();
  }

  Future<List<Photo>> getPhotosForAlbum(int albumId) async {
    final url = Uri.parse(
        'https://api-creation-vercel.vercel.app/comments?postId=$albumId');
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 2); // 2-second delay

    for (int i = 0; i < maxRetries; i++) {
      try {
        print('Fetching photos for album $albumId (Attempt ${i + 1})');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> json = jsonDecode(response.body);
          return json.map((data) => Photo.fromJson(data)).toList();
        } else {
          // For non-200 responses, throw an error immediately
          throw Exception(
              'Failed to load photos for album $albumId: ${response.statusCode}');
        }
      } on SocketException catch (e) {
        print('SocketException on attempt ${i + 1}: $e');
        if (i < maxRetries - 1) {
          await Future.delayed(retryDelay);
        } else {
          rethrow; // Re-throw if it's the last attempt
        }
      } on http.ClientException catch (e) {
        print('ClientException on attempt ${i + 1}: $e');
        if (i < maxRetries - 1) {
          await Future.delayed(retryDelay);
        } else {
          rethrow; // Re-throw if it's the last attempt
        }
      } catch (e) {
        // Catch any other unexpected errors and re-throw
        rethrow;
      }
    }
    // This part should technically not be reached if maxRetries is > 0
    throw Exception('Failed to fetch photos after $maxRetries attempts.');
  }

  void dispose() {
    _client.close(); // Important: Close the client when no longer needed
  }

  Future<List<Photo>> getsahebjiPhotos() async {
    return await PhotoApiService.getsahebjiPhotos();
  }

  Future<List<WallpaperAlbum>> getWallpaperPhotos() async {
    return await PhotoApiService.getWallpapers();
  }

  Future<List<Photo>> activities() async {
    return await PhotoApiService.activities();
  }

  Future<Photo> getPhotoById(int photoId) async {
    return await PhotoApiService.getPhotoById(photoId);
  }
}
