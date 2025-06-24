import 'dart:convert';
// import 'dart:ffi';
import 'package:anoopam_mission/models/album.dart';
import 'package:anoopam_mission/models/photo.dart';
import 'package:http/http.dart' as http;

class PhotoApiService {
  static const String baseUrl =
      'https://api-creation-vercel.vercel.app'; // Replace with your API base URL

  static Future<List<Album>> getAlbums() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Album.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load albums');
    }
  }

  static Future<List<Photo>> getPhotosForAlbum(int albumId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments?postId=$albumId'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos for album $albumId');
    }
  }

  static Future<Photo> getPhotoById(int photoId) async {
    final response = await http.get(Uri.parse('$baseUrl/comments/$photoId'));
    if (response.statusCode == 200) {
      return Photo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load photo $photoId');
    }
  }
}
