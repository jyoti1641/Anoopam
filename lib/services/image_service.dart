// lib/services/image_service.dart
import 'dart:convert';
import 'package:anoopam_mission/data/dummy_api_data.dart'; // Import your new dummy API
import 'package:anoopam_mission/models/image_model.dart';

class ImageService {
  // Fetches all images from the new locationsData structure
  List<ImageModel> fetchAllLocationImages() {
    final Map<String, dynamic> data = json.decode(dummyApiResponse);
    final List<dynamic> locationsJson = data['locationsData'] as List<dynamic>;

    final List<ImageModel> allImages = [];

    for (var locationJson in locationsJson) {
      final String locationName = locationJson['locationName'] as String;
      final List<dynamic> imagesListJson = locationJson['images'] as List<dynamic>;

      for (var imageJson in imagesListJson) {
        allImages.add(ImageModel.fromJson(imageJson as Map<String, dynamic>, locationName));
      }
    }
    return allImages;
  }

  // Gets images for the main carousel (one image per location)
  List<ImageModel> getMainCarouselImages() {
    final Map<String, dynamic> data = json.decode(dummyApiResponse);
    final List<dynamic> locationsJson = data['locationsData'] as List<dynamic>;

    final List<ImageModel> mainImages = [];
    for (var locationJson in locationsJson) {
      final String locationName = locationJson['locationName'] as String;
      final List<dynamic> imagesListJson = locationJson['images'] as List<dynamic>;

      // For the main carousel, we'll pick one image per location.
      // You might want to pick the latest, or a specific "hero" image.
      // Here, we'll just pick the first image from each location's list.
      if (imagesListJson.isNotEmpty) {
        mainImages.add(ImageModel.fromJson(imagesListJson[0] as Map<String, dynamic>, locationName));
      }
    }
    return mainImages;
  }

  // Gets all images for a specific location
  List<ImageModel> getImagesByLocation(String targetLocationName) {
    final Map<String, dynamic> data = json.decode(dummyApiResponse);
    final List<dynamic> locationsJson = data['locationsData'] as List<dynamic>;

    List<ImageModel> relatedImages = [];

    for (var locationJson in locationsJson) {
      final String locationName = locationJson['locationName'] as String;
      if (locationName == targetLocationName) {
        final List<dynamic> imagesListJson = locationJson['images'] as List<dynamic>;
        for (var imageJson in imagesListJson) {
          relatedImages.add(ImageModel.fromJson(imageJson as Map<String, dynamic>, locationName));
        }
        // Assuming location names are unique, we can break after finding
        break;
      }
    }
    return relatedImages;
  }
}

// // services/image_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:anoopam_mission/models/image_model.dart'; // Ensure this path is correct

// class ImageService {
//   final String _apiUrl = 'https://api.anoopam.org/api/ams/v4_1/app-fetch-audio.php';

//   Future<List<ImageModel>> fetchAllCategoriesAndImages() async {
//     try {
//       final response = await http.get(Uri.parse(_apiUrl));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> categoriesJson = data['categories'];

//         // Convert raw JSON categories to ImageModel list
//         List<ImageModel> allImages = categoriesJson.map((json) => ImageModel.fromJson(json)).toList();
//         return allImages;
//       } else {
//         // Handle non-200 status codes
//         print('Failed to load images: ${response.statusCode}');
//         throw Exception('Failed to load images');
//       }
//     } catch (e) {
//       // Handle network errors or JSON parsing errors
//       print('Error fetching image categories: $e');
//       throw Exception('Error fetching image categories: $e');
//     }
//   }
// }
