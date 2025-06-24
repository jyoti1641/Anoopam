import 'package:anoopam_mission/models/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import 'dart:io'; // For File operations, though not directly used for saving to gallery, useful for temporary files if needed.

class PhotoDetailScreen extends StatelessWidget {
  final Photo photo;

  const PhotoDetailScreen({Key? key, required this.photo}) : super(key: key);
  static const platform = MethodChannel('com.example.galleryapp/gallerysaver');

  Future<void> _shareImage(BuildContext context) async {
    // Show a loading indicator while the image is being prepared for sharing

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing image for sharing...')),
    );

    try {
      // 1. Download the image
      final response = await http.get(Uri.parse(photo.imageUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      // 2. Get a temporary directory

      final directory = await getTemporaryDirectory();

      final filePath =
          '${directory.path}/${photo.id}.jpg'; // Save as JPEG for simplicity

      // 3. Write image bytes to a temporary file

      final file = File(filePath);

      await file.writeAsBytes(response.bodyBytes);

      // 4. Share the image file

      await Share.shareXFiles([XFile(filePath)]);

      // Dismiss the loading indicator

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } catch (e) {
      print('Error sharing image: $e');

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share image: ${e.toString()}')),
      );
    }
  }

  Future<void> _downloadImage(BuildContext context) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading image...')));

    try {
      await FileDownloader.downloadFile(
        url: photo.imageUrl,
        name: '${photo.id}.jpg',
        onDownloadCompleted: (String path) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image downloaded successfully')),
          );
        },
      );
    } catch (e) {
      print('Error downloading image: $e');
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(
        //   photo.caption.isNotEmpty ? photo.caption : 'Photo Detail',
        //   style: const TextStyle(color: Colors.white),
        // ),
        backgroundColor: Colors.black.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Download Icon
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadImage(context),
            tooltip: 'Download Image',
          ),
          // Share Icon
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareImage(context),
            tooltip: 'Share Image',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Hero(
          tag: photo.id,
          child: Image.network(
            photo.imageUrl,
            fit: BoxFit.contain,
            errorBuilder:
                (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
