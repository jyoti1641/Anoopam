class AudioItem {
  final String catID;
  final String audioID;
  final String audioTitle;
  final String audioURL;
  final String duration;
  final String artist;
  final String imageUrl;

  AudioItem({
    required this.catID,
    required this.audioID,
    required this.audioTitle,
    required this.audioURL,
    required this.duration,
    required this.artist,
    required this.imageUrl,
  });

  factory AudioItem.fromJson(Map<String, dynamic> json, String defaultImageUrl) {
    return AudioItem(
      catID: json['catID'],
      audioID: json['audioID'],
      audioTitle: json['audioTitle'],
      audioURL: json['audioURL'],
      duration: json['duration'],
      artist: json['artist'],
      imageUrl: defaultImageUrl,
    );
  }
}
