// lib/models/event.dart

class EventAlbum {
  final int id;
  final String title;
  final String coverImage;
  final String date;

  EventAlbum({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.date,
  });

  factory EventAlbum.fromJson(Map<String, dynamic> json) {
    return EventAlbum(
      id: json['id'],
      title: json['title'],
      coverImage: json['cover_image'],
      date: json['date'],
    );
  }
}

class EventDetails {
  final int id;
  final String title;
  final String content;
  final String date;
  final bool hasSubEvent;
  final dynamic data; // Change type to dynamic to handle both List and Map
  final int? galleryId;
  final List<dynamic> videos;

  EventDetails({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.hasSubEvent,
    required this.data,
    this.galleryId,
    required this.videos,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      date: json['date'],
      hasSubEvent: json['has_sub_event'],
      data: json['data'], // Parse data as dynamic
      galleryId: json['data'] is Map<String, dynamic> &&
              json['data']['gallery_id'] is int
          ? json['data']['gallery_id']
          : null,
      videos:
          json['data'] is Map<String, dynamic> && json['data']['videos'] is List
              ? json['data']['videos']
              : [],
    );
  }
}

class SubEvent {
  final String eventName;
  final String coverImage;
  final String eventDate;
  final String description;
  final List<EventPhoto> photos;
  final int? galleryId;
  final List<dynamic> videos;

  SubEvent({
    required this.eventName,
    required this.coverImage,
    required this.eventDate,
    required this.description,
    required this.photos,
    this.galleryId,
    required this.videos,
  });

  factory SubEvent.fromJson(Map<String, dynamic> json) {
    return SubEvent(
      eventName: json['event_name'],
      coverImage: json['cover_image'],
      eventDate: json['event_date'],
      description: json['discreption'],
      photos:
          (json['photos'] as List).map((p) => EventPhoto.fromJson(p)).toList(),
      galleryId: json['gallery_id'] is int ? json['gallery_id'] : null,
      videos: json['videos'] ?? [],
    );
  }
}

class EventPhoto {
  final String image;
  final String caption;

  EventPhoto({required this.image, required this.caption});

  factory EventPhoto.fromJson(Map<String, dynamic> json) {
    return EventPhoto(
      image: json['image'],
      caption: json['caption'],
    );
  }
}
