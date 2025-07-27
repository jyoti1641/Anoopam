class AudioTrack {
  final String title;
  final String songUrl;
  final String imageUrl;
  final String artist;
  final String duration;

  AudioTrack({
    required this.title,
    required this.songUrl,
    required this.imageUrl,
    required this.artist,
    required this.duration,
  });

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    return AudioTrack(
      title: json['title'],
      songUrl: json['songUrl'],
      imageUrl: json['imageUrl'],
      artist: json['artist'],
      duration: json['duration'],
    );
  }
}
