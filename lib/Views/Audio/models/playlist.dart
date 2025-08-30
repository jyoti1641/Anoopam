// // lib/Views/Audio/models/playlist.dart
// import 'package:anoopam_mission/Views/Audio/models/song.dart';

// class Playlist {
//   final String name;
//   final List<AudioModel> songs;

//   Playlist({required this.name, required this.songs});

//   factory Playlist.fromJson(Map<String, dynamic> json) {
//     var songsList = json['songs'] as List;
//     List<AudioModel> parsedSongs =
//         songsList.map((songJson) => AudioModel.fromDetailsJson(songJson)).toList();
//     return Playlist(
//       name: json['name'],
//       songs: parsedSongs,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'songs': songs.map((song) => song.toJson()).toList(),
//     };
//   }
// }
// lib/Views/Audio/models/playlist_model.dart

import 'package:anoopam_mission/Views/Audio/models/song.dart';

class Playlist {
  String name;
  String? coverImageUrl;
  List<AudioModel> songs;

  Playlist({
    required this.name,
    this.coverImageUrl,
    required this.songs,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'coverImageUrl': coverImageUrl,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      songs: (json['songs'] as List<dynamic>)
          .map(
              (item) => AudioModel.fromStoredJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
