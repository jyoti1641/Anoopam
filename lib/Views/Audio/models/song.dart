// lib/Views/Audio/models/song.dart

class AudioModel {
  final int? id;
  final String title;
  final String audioUrl;
  final String? audioDuration;
  final String? artist;
  final int? albumId; // New field to link to the album
  final String? albumCoverUrl; // New field to store the album art

  AudioModel({
    this.id,
    required this.title,
    required this.audioUrl,
    this.audioDuration,
    this.artist,
    this.albumId, // Include in constructor
    this.albumCoverUrl, // Include in constructor
  });

  factory AudioModel.fromDetailsJson(
      Map<String, dynamic> json, int? albumId, String? albumCoverUrl) {
    return AudioModel(
      id: json['id'] as int?,
      title: json['audio_name'] as String,
      audioUrl: json['audio_file'] as String,
      audioDuration: json['duration'] as String?,
      artist: json['artist'] as String?,
      albumId: albumId,
      albumCoverUrl: albumCoverUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audio_name': title,
      'audio_file': audioUrl,
      'duration': audioDuration,
      'artist': artist,
      'albumId': albumId,
      'albumCoverUrl': albumCoverUrl,
    };
  }

  factory AudioModel.fromStoredJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['id'] as int?,
      title: json['audio_name'] as String,
      audioUrl: json['audio_file'] as String,
      audioDuration: json['duration'] as String?,
      artist: json['artist'] as String?,
      albumId: json['albumId'] as int?,
      albumCoverUrl: json['albumCoverUrl'] as String?,
    );
  }

  factory AudioModel.fromApiJson(Map<String, dynamic> json) {
    return AudioModel(
      id: json['media_id'] as int,
      title: json['audio_name'] as String,
      audioUrl: json['audio_file'] as String,
      artist: json['artist'] as String?,
      audioDuration: json['duration'] as String?,
      // The API response doesn't contain a cover image URL, so we leave it as null.
      albumCoverUrl: null,
    );
  }
}
