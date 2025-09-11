// lib/screens/event_photo_detail_screen.dart

import 'package:anoopam_mission/models/event.dart'; // Import EventPhoto model
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'dart:io';

class EventPhotoDetailScreen extends StatelessWidget {
  final EventPhoto eventPhoto;
  final String heroTag;

  const EventPhotoDetailScreen({
    Key? key,
    required this.eventPhoto,
    required this.heroTag,
  }) : super(key: key);

  Future<void> _shareImage(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing image for sharing...')),
    );

    try {
      final response = await http.get(Uri.parse(eventPhoto.image));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${heroTag.hashCode}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: eventPhoto.caption.isNotEmpty ? eventPhoto.caption : null,
      );
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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Downloading image...')));

    try {
      await FileDownloader.downloadFile(
        url: eventPhoto.image,
        name: 'anoopam_event_${heroTag.hashCode}.jpg',
        onDownloadCompleted: (String path) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image downloaded successfully')),
          );
        },
        onDownloadError: (String error) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to download image: $error')),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadImage(context),
            tooltip: 'Download Image',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareImage(context),
            tooltip: 'Share Image',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Hero(
          tag: heroTag,
          child: Image.network(
            eventPhoto.image,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
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
                  value: loadingProgress.expectedTotalBytes != null
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
