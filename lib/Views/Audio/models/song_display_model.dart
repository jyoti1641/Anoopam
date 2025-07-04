// anoopam_mission/lib/Views/Audio/models/song_display_model.dart
import 'package:anoopam_mission/Views/Audio/models/song.dart';

class SongDisplayModel {
  final AudioModel audioModel;
  bool isFavorite;
  // NEW: Property to indicate if this song is the one currently playing/paused
  bool isPlayingOrPaused;

  SongDisplayModel({
    required this.audioModel,
    this.isFavorite = false,
    this.isPlayingOrPaused = false, // Default to false
  });

  String get title => audioModel.title;
  String get songUrl => audioModel.songUrl;
  String get imageUrl => audioModel.imageUrl;
}
