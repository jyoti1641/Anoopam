import 'package:anoopam_mission/Views/Audio/models/song.dart';

class AlbumModel {
  final int id; // Change to int
  final String title;
  final String coverImage; // Change variable name to match API
  final String? artist;
  final String? albumDuration;
  final String? albumDate;
  final List<AudioModel>? songs;

  AlbumModel({
    required this.id,
    required this.title,
    required this.coverImage,
    this.artist,
    this.albumDuration,
    this.albumDate,
    this.songs,
  });

  // Add the toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverImage': coverImage,
      'artist': artist,
      'albumDuration': albumDuration,
      'albumDate': albumDate,
      'songs': songs?.map((song) => song.toJson()).toList(),
    };
  }

  // Add a factory constructor to create AlbumModel from JSON for storage retrieval
  factory AlbumModel.fromStoredJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as int,
      title: json['title'] as String,
      coverImage: json['coverImage'] as String,
      artist: json['artist'] as String?,
      albumDuration: json['albumDuration'] as String?,
      albumDate: json['albumDate'] as String?,
      songs: (json['songs'] as List?)
          ?.map((i) => AudioModel.fromStoredJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  // Factory constructor for the main audio screen API
  factory AlbumModel.fromLatestOrFeaturedJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as int,
      title: json['title'] as String,
      coverImage: json['cover_image'] as String,
    );
  }

  // Factory constructor for the audio details screen API
  factory AlbumModel.fromDetailsJson(Map<String, dynamic> json) {
    var songsList = json['audio_tracks'] as List? ?? [];
    List<AudioModel> parsedSongs = songsList
        .map((i) => AudioModel.fromDetailsJson(
              i as Map<String, dynamic>,
              json['id'] as int?,
              json['cover_image'] as String?,
            ))
        .toList();

    return AlbumModel(
      id: json['id'] as int,
      title: json['title'] as String,
      coverImage: json['cover_image'] as String,
      artist: json['artist'] as String?,
      albumDuration: json['album_duration'] as String?,
      albumDate: json['album_date'] as String?,
      songs: parsedSongs,
    );
  }
}
