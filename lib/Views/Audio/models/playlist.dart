// lib/Views/Audio/models/playlist.dart
import 'package:anoopam_mission/Views/Audio/models/song.dart'; // Ensure this path is correct for AudioModel

class Playlist {
  final String name;
  List<AudioModel> songs; // Made this non-final to allow adding/removing songs

  Playlist({required this.name, required this.songs});

  // Convert a Playlist object to a JSON map
  Map<String, dynamic> toJson() => {
        'name': name,
        // Ensure AudioModel's toJson is correctly called here
        'songs': songs.map((song) => song.toJson()).toList(),
      };

  // Create a Playlist object from a JSON map
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'] as String,
      songs: (json['songs'] as List)
          .map((item) => AudioModel.fromJson(
              item as Map<String, dynamic>)) // Explicit cast for item
          .toList(),
    );
  }
}
