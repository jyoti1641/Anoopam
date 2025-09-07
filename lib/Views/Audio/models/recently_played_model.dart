// lib/Views/Audio/models/recently_played_song_model.dart

class RecentlyPlayedSongModel {
  final int? id;
  final String title;
  final String? artist;
  final String? audioDuration;
  final String? albumCoverUrl;
  final String audioUrl; // Now required for actions

  RecentlyPlayedSongModel({
    this.id,
    required this.title,
    this.artist,
    this.audioDuration,
    this.albumCoverUrl,
    required this.audioUrl,
  });

  factory RecentlyPlayedSongModel.fromJson(Map<String, dynamic> json) {
    return RecentlyPlayedSongModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      audioDuration: json['audioDuration'] as String?,
      albumCoverUrl: json['albumCoverUrl'] as String?,
      audioUrl: json['audioUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audioDuration': audioDuration,
      'albumCoverUrl': albumCoverUrl,
      'audioUrl': audioUrl,
    };
  }
}
