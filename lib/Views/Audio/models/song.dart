// // lib/models/audio_model.dart
// class AudioModel {
//   final String title;
//   final String songUrl;
//   final String imageUrl; // Image specific to the song, from your API response

//   AudioModel({
//     required this.title,
//     required this.songUrl,
//     required this.imageUrl,
//   });

//   // Factory constructor to create an AudioModel from a JSON map
//   factory AudioModel.fromJson(Map<String, dynamic> json) {
//     return AudioModel(
//       title: json['title'] as String,
//       songUrl: json['songUrl'] as String,
//       imageUrl: json['imageUrl'] as String,
//     );
//   }
// }

// lib/Views/Audio/models/song.dart
// Or wherever your AudioModel is defined, ensure this path is consistent across your project.

class AudioModel {
  final String title;
  final String songUrl;
  final String imageUrl; // Image specific to the song, from your API response
  final String artist;
  final String
      duration; // Keeping as String "mm:ss" as per your API and original model

  AudioModel({
    required this.title,
    required this.songUrl,
    required this.imageUrl,
    required this.artist,
    required this.duration,
  });

  // Factory constructor to create an AudioModel from a JSON map
  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      // Use null-aware operator and provide a default empty string if the key is missing or value is null
      title: json['title'] as String? ?? 'Unknown Title',
      songUrl: json['songUrl'] as String? ?? '', // Fallback for song URL
      imageUrl: json['imageUrl'] as String? ??
          'https://placehold.co/150x150/CCCCCC/FFFFFF?text=No+Image', // Fallback image
      artist:
          json['artist'] as String? ?? 'Unknown Artist', // Safely get artist
      duration: json['duration'] as String? ??
          '00:00', // Safely get duration, default to 00:00
    );
  }

  // Method to convert an AudioModel object to a JSON map
  // This method is crucial for Playlist to serialize AudioModel objects.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'songUrl': songUrl,
      'imageUrl': imageUrl,
      'artist': artist,
      'duration': duration,
    };
  }
}
