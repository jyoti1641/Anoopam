// lib/models/wallpaper_models.dart

class WallpaperAlbum {
  final int id;
  final String title;
  final String year;
  final String month;
  final String wallpaperUrl;

  WallpaperAlbum({
    required this.id,
    required this.title,
    required this.year,
    required this.month,
    required this.wallpaperUrl,
  });

  factory WallpaperAlbum.fromJson(Map<String, dynamic> json) {
    return WallpaperAlbum(
      id: json['id'] as int,
      title: json['title'] as String,
      year: json['year'] as String,
      month: json['month'] as String,
      wallpaperUrl: json['wallpaper'] as String,
    );
  }
}

class WallpaperDetails {
  final int id;
  final String title;
  final String year;
  final String month;
  final String coverImageUrl;
  final List<String> desktopImages;
  final List<String> mobileImages;

  WallpaperDetails({
    required this.id,
    required this.title,
    required this.year,
    required this.month,
    required this.coverImageUrl,
    required this.desktopImages,
    required this.mobileImages,
  });

  factory WallpaperDetails.fromJson(Map<String, dynamic> json) {
    return WallpaperDetails(
      id: json['id'] as int,
      title: json['title'] as String,
      year: json['year'] as String,
      month: json['month'] as String,
      coverImageUrl: json['cover_image'] as String,
      desktopImages: List<String>.from(json['desktop']),
      mobileImages: List<String>.from(json['mobile']),
    );
  }
}
