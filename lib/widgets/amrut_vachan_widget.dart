import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart'; // Still good for temporary files, though not directly used for gallery save
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui; // Import for ui.Image and ImageByteFormat
import 'package:flutter/rendering.dart'; // Import for RenderRepaintBoundary
import 'dart:typed_data'; // Import for Uint8List

// Change this import
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class AmrutVachanWidget extends StatefulWidget {
  final String title;
  final String imagePath;
  final String text;
  final String textGujarati;

  const AmrutVachanWidget({
    super.key,
    required this.title,
    required this.imagePath,
    required this.text,
    required this.textGujarati,
  });

  @override
  State<AmrutVachanWidget> createState() => _AmrutVachanWidgetState();
}

class _AmrutVachanWidgetState extends State<AmrutVachanWidget> {
  bool isEnglish = true;
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // Key for RepaintBoundary

  // ✅ Share Functionality
  void _shareText() {
    final textToShare = isEnglish ? widget.text : widget.textGujarati;
    Share.share(textToShare, subject: widget.title);
  }

  // Modified: Download Widget as Image Functionality to save to Gallery
  Future<void> _downloadWidgetAsImage() async {
    PermissionStatus status;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      status = await Permission.photosAddOnly.request();
    } else {
      // Android
      final DeviceInfoPlugin info = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await info.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // Android 13 (Tiramisu) or higher
        // Request specific media permissions
        final PermissionStatus photosStatus = await Permission.photos.request();
        // Permission.photos covers images and videos
        // If you only need to add, you can use Permission.photosAddOnly for Android 13+ too,
        // but Permission.photos is generally more robust for saving.

        if (photosStatus.isGranted) {
          status = PermissionStatus.granted;
        } else if (photosStatus.isPermanentlyDenied) {
          status = PermissionStatus.permanentlyDenied;
        } else {
          status = PermissionStatus.denied;
        }
      } else {
        // Android 12 (S) or lower
        status = await Permission.storage.request();
      }
    }

    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "❌ ${Theme.of(context).platform == TargetPlatform.iOS ? 'Photos' : 'Media'} permission denied. Cannot save image.")),
        );
      }
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "${Theme.of(context).platform == TargetPlatform.iOS ? 'Photos' : 'Media'} permission permanently denied. Please enable from app settings."),
              action: SnackBarAction(
                label: "Settings",
                onPressed: () {
                  openAppSettings(); // Opens app settings
                },
              ),
            ),
          );
        }
      }
      return;
    }

    try {
      RenderRepaintBoundary? boundary = _repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Failed to find widget boundary.")),
          );
        }
        return;
      }

      ui.Image image = await boundary.toImage(
          pixelRatio: 3.0); // Adjust pixelRatio for quality
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("❌ Failed to convert image to bytes.")),
          );
        }
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final languageIdentifier = isEnglish ? 'en' : 'guj';
      final fileName =
          'AmrutVachan_${widget.title.replaceAll(' ', '_').toLowerCase()}_$languageIdentifier.png';

      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 90, // Image quality (0-100)
        name: fileName, // Filename in the gallery
      );

      // The filePath in ImageGallerySaverPlus result might not be a direct file path
      // that you can immediately check with `File(filePath).exists()`.
      // It's more of an identifier that the image was saved.
      // So, removing the `File(filePath).exists()` check as it often causes confusion.
      if (result['isSuccess']) {
        print('DEBUG: Image saved successfully. Result: $result');
      } else {
        print('DEBUG: Failed to save image. Result: $result');
      }

      if (context.mounted) {
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "✅ Image downloaded as '$fileName'! You can find it in your gallery."),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "❌ Failed to save image: ${result['errorMessage'] ?? 'Unknown error'}")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ An error occurred: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                widget.imagePath,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200, // Set a fixed height for the image
                    width: 200,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.album,
                        size: 60,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  );
                },
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // ✅ Blue Box (Figma Style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF005BBB), // Figma Blue Color
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ Language Toggle Buttons
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLangButton("Eng", true),
                        const SizedBox(width: 8),
                        _buildLangButton("ગુજ", false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ Quote Text
                  SizedBox(
                    height: 100,
                    child: Text(
                      isEnglish ? widget.text : widget.textGujarati,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ Share & Download Buttons (Right-aligned)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: _shareText,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed:
                            _downloadWidgetAsImage, // Call the new function
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Custom Language Button
  Widget _buildLangButton(String label, bool english) {
    final selected = isEnglish == english;
    return GestureDetector(
      onTap: () {
        setState(() {
          isEnglish = english;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
