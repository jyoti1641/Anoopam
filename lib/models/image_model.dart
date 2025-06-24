// lib/models/image_model.dart
class ImageModel {
  final String id; // This will now be imageID
  final String name; // This will be imageName
  final String url; // This will be imageURL (can be used for both thumbnail and full)
  final String date; // This will be imageDate
  final String locationName; // New field to link to the location

  ImageModel({
    required this.id,
    required this.name,
    required this.url,
    required this.date,
    required this.locationName,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json, String locationName) {
    return ImageModel(
      id: json['imageID'] as String,
      name: json['imageName'] as String,
      url: json['imageURL'] as String,
      date: json['imageDate'] as String,
      locationName: locationName, // Pass locationName from the parent object
    );
  }
}


// // models/image_model.dart
// class ImageModel {
//   final String id;
//   final String catID; // Add this
//   final String mainCatID; // Add this
//   final String title;
//   final String thumbnailUrl; // This will be `catImage` from the API
//   final String fullImageUrl; // For simplicity, we'll use `catImage` for both thumbnail and full image in this scenario.

//   ImageModel({
//     required this.id,
//     required this.catID, // Add this
//     required this.mainCatID, // Add this
//     required this.title,
//     required this.thumbnailUrl,
//     required this.fullImageUrl,
//   });

//   factory ImageModel.fromJson(Map<String, dynamic> json) {
//     return ImageModel(
//       id: json['catID'] ?? '', // Use catID as the unique ID for images
//       catID: json['catID'] ?? '', // Map catID
//       mainCatID: json['mainCatID'] ?? '', // Map mainCatID
//       title: json['catName'] ?? 'No Title', // Map catName to title
//       thumbnailUrl: json['catImage'] ?? '', // Map catImage to thumbnailUrl
//       fullImageUrl: json['catImage'] ?? '', // Map catImage to fullImageUrl
//     );
//   }
// }
