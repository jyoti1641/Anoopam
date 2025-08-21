// lib/Views/Audio/models/playlist.dart
import 'package:anoopam_mission/Views/Audio/models/song.dart';

class Playlist {
  final String name;
  final List<AudioModel> songs;

  Playlist({required this.name, required this.songs});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    var songsList = json['songs'] as List;
    List<AudioModel> parsedSongs =
        songsList.map((songJson) => AudioModel.fromDetailsJson(songJson)).toList();
    return Playlist(
      name: json['name'],
      songs: parsedSongs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }
}
