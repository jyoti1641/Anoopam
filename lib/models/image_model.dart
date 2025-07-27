// // lib/models/image_model.dart
class ImageModel {
  final String id;
  final String url;
  final String locationName;
  final String date;

  ImageModel({
    required this.id,
    required this.url,
    required this.locationName,
    required this.date,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json, String locationName) {
    return ImageModel(
      id: json['id'] ?? json['image'] ?? 'unknown',
      url: json['url'] ?? json['image'] ?? json['mainImage'] ?? '',
      locationName: locationName,
      date: json['date'] ?? json['Timestamp'] ?? 'Unknown Date',
    );
  }
}
