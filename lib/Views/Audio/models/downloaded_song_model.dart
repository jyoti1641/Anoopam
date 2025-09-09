// lib/Views/Audio/models/downloaded_song_model.dart

class DownloadedSongModel {
  final int? id;
  final String title;
  final String? artist;
  final String? audioDuration;
  final String? albumCoverUrl;
  final String filePath; // The local path to the downloaded file

  DownloadedSongModel({
    this.id,
    required this.title,
    this.artist,
    this.audioDuration,
    this.albumCoverUrl,
    required this.filePath,
  });

  factory DownloadedSongModel.fromJson(Map<String, dynamic> json) {
    return DownloadedSongModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      audioDuration: json['audioDuration'] as String?,
      albumCoverUrl: json['albumCoverUrl'] as String?,
      filePath: json['filePath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audioDuration': audioDuration,
      'albumCoverUrl': albumCoverUrl,
      'filePath': filePath,
    };
  }
}
