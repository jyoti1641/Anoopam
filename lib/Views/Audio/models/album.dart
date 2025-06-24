// lib/models/album_model.dart
import 'package:anoopam_mission/Views/Audio/models/song.dart';

class AlbumModel {
  final String id;
  final String title; // Maps to albumName in your API
  final String albumArt; // Maps to albumCover in your API
  final String artist;
  final List<AudioModel> songs; // List of songs within this album

  AlbumModel({
    required this.id,
    required this.title,
    required this.albumArt,
    required this.artist,
    required this.songs,
  });

  // Factory constructor to create an AlbumModel from a JSON map
  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    // Parse the list of songs from the 'songs' array in JSON
    var songsList = json['songs'] as List;
    List<AudioModel> parsedSongs =
        songsList.map((i) => AudioModel.fromJson(i)).toList();

    return AlbumModel(
      id: json['id'] as String,
      title: json['albumName'] as String, // Map 'albumName' from API to 'title'
      albumArt: json['albumCover']
          as String, // Map 'albumCover' from API to 'albumArt'
      artist: json['artist'] as String,
      songs: parsedSongs,
    );
  }
}
