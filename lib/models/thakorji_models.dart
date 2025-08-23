// lib/models/thakorji_models.dart

class Country {
  final int id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
    );
  }
}

class CenterModel {
  final int id;
  final String title;

  CenterModel({required this.id, required this.title});

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      id: json['id'],
      title: json['title'],
    );
  }
}

class ThakorjiDarshanDetails {
  final int id;
  final String title;
  final String mainImage;
  final String timestamp;
  final List<String> images;

  ThakorjiDarshanDetails({
    required this.id,
    required this.title,
    required this.mainImage,
    required this.timestamp,
    required this.images,
  });

  factory ThakorjiDarshanDetails.fromJson(Map<String, dynamic> json) {
    return ThakorjiDarshanDetails(
      id: json['id'],
      title: json['title'],
      mainImage: json['main_image'],
      timestamp: json['Timestamp'],
      images: List<String>.from(json['images']),
    );
  }
}
