// import 'dart:ffi';

import 'package:anoopam_mission/data/photo_service.dart';

import '../models/album.dart';
import '../models/photo.dart';

// class PhotoRepository {
//   // --- Placeholder Data (Replace with API calls later) ---
//   static final List<Album> _albums = [
//     Album(
//       id: 'a1',
//       name: 'Vacation 2023',
//       thumbnailUrl: 'https://picsum.photos/seed/beach_sunset/600/400',
//     ),
//     Album(
//       id: 'a2',
//       name: 'Family Events',
//       thumbnailUrl: 'https://picsum.photos/seed/birthday_party/600/400',
//     ),
//     Album(
//       id: 'a3',
//       name: 'Nature Shots',
//       thumbnailUrl: 'https://picsum.photos/seed/forest_trail/600/400',
//     ),
//   ];

//   static final List<Photo> _photos = [
//     Photo(
//       id: 'p1',
//       albumId: 'a1',
//       imageUrl: 'https://picsum.photos/seed/beach_sunset/600/400',
//       caption: 'Beach sunset',
//       country: 'USA',
//       state: 'California',
//       lastUpdated: DateTime(2023, 7, 15, 10, 30),
//     ),
//     Photo(
//       id: 'p2',
//       albumId: 'a1',
//       imageUrl: 'https://picsum.photos/seed/mountain_view/600/400',
//       caption: 'Mountain hike',
//       country: 'Canada',
//       state: 'Alberta',
//       lastUpdated: DateTime(2023, 7, 16, 14, 0),
//     ),
//     Photo(
//       id: 'p3',
//       albumId: 'a2',
//       imageUrl: 'https://picsum.photos/seed/city_lights/600/400',
//       caption: 'Birthday party',
//       country: 'India',
//       state: 'Gujarat',
//       lastUpdated: DateTime(2024, 1, 10, 18, 0),
//     ),
//     Photo(
//       id: 'p4',
//       albumId: 'a2',
//       imageUrl: 'https://picsum.photos/seed/wedding_celebration/600/400',
//       caption: 'Wedding ceremony',
//       country: 'India',
//       state: 'Rajasthan',
//       lastUpdated: DateTime(2024, 3, 5, 11, 45),
//     ),
//     Photo(
//       id: 'p5',
//       albumId: 'a3',
//       imageUrl: 'https://picsum.photos/seed/river_flow/600/400',
//       caption: 'Forest trail',
//       country: 'New Zealand',
//       state: 'South Island',
//       lastUpdated: DateTime(2023, 11, 20, 9, 0),
//     ),
//     Photo(
//       id: 'p6',
//       albumId: 'a1',
//       imageUrl: 'https://picsum.photos/seed/flowers_bloom/600/400',
//       caption: 'City lights',
//       country: 'USA',
//       state: 'New York',
//       lastUpdated: DateTime(2023, 8, 1, 20, 0),
//     ),
//   ];
//   // --------------------------------------------------------

//   Future<List<Album>> getAlbums() async {
//     // In a real app, this would be an API call:
//     // final response = await PhotoApiService.get('/albums');
//     // return (response.data as List).map((json) => Album.fromJson(json)).toList();
//     await Future.delayed(
//       const Duration(milliseconds: 500),
//     ); // Simulate network delay
//     return _albums;
//   }

//   Future<List<Photo>> getPhotosForAlbum(String albumId) async {
//     // In a real app, this would be an API call:
//     // final response = await PhotoApiService.get('/albums/$albumId/photos');
//     // return (response.data as List).map((json) => Photo.fromJson(json)).toList();
//     await Future.delayed(
//       const Duration(milliseconds: 500),
//     ); // Simulate network delay
//     return _photos.where((photo) => photo.albumId == albumId).toList();
//   }

//   Future<Photo> getPhotoById(String photoId) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return _photos.firstWhere((photo) => photo.id == photoId);
//   }
// }

class PhotoRepository {
  Future<List<Album>> getAlbums() async {
    return await PhotoApiService.getAlbums();
  }

  Future<List<Photo>> getPhotosForAlbum(int albumId) async {
    return await PhotoApiService.getPhotosForAlbum(albumId);
  }

  Future<List<Photo>> getsahebjiPhotos() async {
    return await PhotoApiService.getsahebjiPhotos();
  }

  Future<List<Photo>> getwallpaperPhotos() async {
    return await PhotoApiService.getwallpaperPhotos();
  }

  Future<List<Photo>> activities() async {
    return await PhotoApiService.activities();
  }

  Future<Photo> getPhotoById(int photoId) async {
    return await PhotoApiService.getPhotoById(photoId);
  }
}
