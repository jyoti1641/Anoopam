// lib/services/image_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:anoopam_mission/models/image_model.dart';

class ImageService {
  final String _apiUrl = 'https://anoopam.org/wp-json/mobile/v1/home/';

  Future<List<ImageModel>> fetchThakorjiDarshanImages() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> thakorjiDarshanJson = data['thakorji_darshan'];

        List<ImageModel> allImages = [];

        for (var item in thakorjiDarshanJson) {
          final String mainImage = item['mainImage'];
          final String templePlace = item['templePlace'];
          final String timestamp = item['Timestamp'];
          final List<dynamic> imagesJson = item['images'];

          // Add the main image
          allImages.add(ImageModel(
            id: 'main_${item['templeID']}',
            url: mainImage,
            locationName: templePlace,
            date: timestamp,
          ));

          // Add other images
          for (var imageItem in imagesJson) {
            allImages.add(ImageModel(
              id: imageItem['image'],
              url: imageItem['image'],
              locationName: templePlace,
              date: timestamp,
            ));
          }
        }

        return allImages;
      } else {
        print('Failed to load images: ${response.statusCode}');
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print('Error fetching images: $e');
      throw Exception('Error fetching images: $e');
    }
  }

  Future<List<ImageModel>> getMainCarouselImages() async {
    final List<ImageModel> allImages = await fetchThakorjiDarshanImages();
    final Map<String, ImageModel> mainImagesMap = {};

    // Filter to get one image per location
    for (var image in allImages) {
      if (!mainImagesMap.containsKey(image.locationName)) {
        mainImagesMap[image.locationName] = image;
      }
    }

    return mainImagesMap.values.toList();
  }

  Future<List<ImageModel>> getImagesByLocation(
      String targetLocationName) async {
    final List<ImageModel> allImages = await fetchThakorjiDarshanImages();
    return allImages
        .where((image) => image.locationName == targetLocationName)
        .toList();
  }
}
