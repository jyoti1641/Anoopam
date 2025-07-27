import 'package:flutter/material.dart';
import 'dart:typed_data'; // Required for Uint8List for image_gallery_saver_plus
import 'package:http/http.dart' as http; // Required for making HTTP requests
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:easy_localization/easy_localization.dart';

class FullScreenImageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  // final String title;
  final String imageUrl;

  const FullScreenImageAppBar({
    super.key,
    // required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // Semi-transparent black
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.indigo),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      // title: Text(
      //   title,
      //   style: const TextStyle(color: Colors.white, fontSize: 16),
      // ),
      // centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.download, color: Colors.indigo),
          onPressed: () => _downloadImage(context, imageUrl),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _downloadImage(BuildContext context, String url) async {
    try {
      _showSnackBar(context, 'fullscreenImage.downloading'.tr(),
          Colors.blue); // Provide immediate feedback
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final result =
            await ImageGallerySaverPlus.saveImage(bytes, quality: 100);

        if (result['isSuccess']) {
          _showSnackBar(
              context, 'fullscreenImage.downloaded'.tr(), Colors.green);
        } else {
          _showSnackBar(
              context,
              'fullscreenImage.failedToSave'.tr(namedArgs: {
                'error': result['errorMessage']?.toString() ?? 'Unknown error'
              }),
              Colors.red);
        }
      } else {
        _showSnackBar(
            context,
            'fullscreenImage.failedToDownload'
                .tr(namedArgs: {'status': response.statusCode.toString()}),
            Colors.red);
      }
    } catch (e) {
      _showSnackBar(
          context,
          'fullscreenImage.errorDownloading'
              .tr(namedArgs: {'error': e.toString()}),
          Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
