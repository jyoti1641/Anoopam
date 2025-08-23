// lib/models/sahebji_darshan_models.dart

class SahebjiDarshanAlbum {
  final int id;
  final String title;
  final String coverImage;
  final String date;

  SahebjiDarshanAlbum({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.date,
  });

  factory SahebjiDarshanAlbum.fromJson(Map<String, dynamic> json) {
    return SahebjiDarshanAlbum(
      id: json['id'] as int,
      title: json['title'] as String,
      coverImage: json['cover_image'] as String,
      date: json['date'] as String,
    );
  }
}

class SahebjiDarshanResponse {
  final List<SahebjiDarshanAlbum> data;
  final int currentPage;
  final int totalPages;
  final int total;

  SahebjiDarshanResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.total,
  });

  factory SahebjiDarshanResponse.fromJson(Map<String, dynamic> json) {
    return SahebjiDarshanResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) =>
              SahebjiDarshanAlbum.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      total: json['total'] as int,
    );
  }
}

class SahebjiDarshanImage {
  final String image;
  final String caption;

  SahebjiDarshanImage({
    required this.image,
    required this.caption,
  });

  factory SahebjiDarshanImage.fromJson(Map<String, dynamic> json) {
    return SahebjiDarshanImage(
      image: json['image'] as String,
      caption: json['caption'] as String,
    );
  }
}

class SahebjiDarshanDetails {
  final int id;
  final String title;
  final List<SahebjiDarshanImage> sahebjiDarshan;

  SahebjiDarshanDetails({
    required this.id,
    required this.title,
    required this.sahebjiDarshan,
  });

  factory SahebjiDarshanDetails.fromJson(Map<String, dynamic> json) {
    return SahebjiDarshanDetails(
      id: json['id'] as int,
      title: json['title'] as String,
      sahebjiDarshan: (json['sahebji_darshan'] as List<dynamic>)
          .map((item) =>
              SahebjiDarshanImage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
