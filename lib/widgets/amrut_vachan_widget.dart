import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class AmrutVachanWidget extends StatefulWidget {
  final String title;
  final String imagePath;
  final String text;
  final String textGujarati;
  final ImageProvider backgroundImage;

  const AmrutVachanWidget({
    super.key,
    required this.title,
    required this.imagePath,
    required this.text,
    required this.textGujarati,
    required this.backgroundImage,
  });

  @override
  State<AmrutVachanWidget> createState() => _AmrutVachanWidgetState();
}

class _AmrutVachanWidgetState extends State<AmrutVachanWidget> {
  bool isEnglish = true;
  final GlobalKey _downloadableContentKey = GlobalKey(); // Key for image + text

  void _shareText() {
    final textToShare = isEnglish ? widget.text : widget.textGujarati;
    Share.share(textToShare, subject: widget.title);
  }

  Future<void> _downloadWidgetAsImage() async {
    PermissionStatus status;

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      status = await Permission.photosAddOnly.request();
    } else {
      final DeviceInfoPlugin info = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await info.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        final PermissionStatus photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) {
          status = PermissionStatus.granted;
        } else if (photosStatus.isPermanentlyDenied) {
          status = PermissionStatus.permanentlyDenied;
        } else {
          status = PermissionStatus.denied;
        }
      } else {
        status = await Permission.storage.request();
      }
    }

    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ ${Theme.of(context).platform == TargetPlatform.iOS ? 'Photos' : 'Media'} permission denied. Cannot save image.",
            ),
          ),
        );
      }
      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${Theme.of(context).platform == TargetPlatform.iOS ? 'Photos' : 'Media'} permission permanently denied. Please enable from app settings.",
              ),
              action: SnackBarAction(
                label: "Settings",
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }
      }
      return;
    }

    try {
      RenderRepaintBoundary? boundary = _downloadableContentKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Failed to find widget boundary.")),
          );
        }
        return;
      }

      // Ensure the boundary is laid out before converting to image
      // This might not be strictly necessary if the widget is already rendered,
      // but can help in edge cases, especially during initial load or if states change rapidly.
      await Future.delayed(
          Duration(milliseconds: 50)); // Small delay to ensure render

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
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
        quality: 90,
        name: fileName,
      );

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
                "✅ Image downloaded as '$fileName'! You can find it in your gallery.",
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "❌ Failed to save image: ${result['errorMessage'] ?? 'Unknown error'}",
              ),
            ),
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
    return SingleChildScrollView(
      child: Stack(
        // Use Stack here to layer elements
        alignment:
            Alignment.topCenter, // Align children to the top center initially
        children: [
          // Layer 0: The main content that will be downloaded (Image + Text + its original blue box layout)
          RepaintBoundary(
            key: _downloadableContentKey,
            child: Container(
              padding: EdgeInsets.zero,
              // The decoration of this container defines the overall shape/background of the captured image
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // Add a solid color here if you want a background behind the image and text area for the capture
                // color: Theme.of(context)
                //     .canvasColor, // Example: Use canvas color or white
              ),
              child: Column(
                // This column represents the content that gets captured
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
                          height: 245, // Match original image height
                          width: double.infinity,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Icon(Icons.album,
                              size: 60,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        );
                      },
                      height: 245,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),

                  // ✅ Blue Box (Figma Style) - Contains only the text
                  Container(
                    height: 270,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      // color: Color(0xFF005BBB), // Figma Blue Color
                      image: DecorationImage(
                        // This is where backgroundImage is used
                        image: widget
                            .backgroundImage, // Use the provided ImageProvider here
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.4),
                          BlendMode.darken,
                        ),
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: SizedBox(
                        height: 180, // Fixed height for text
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
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Layer 1: Language Toggle Buttons (positioned within the stack)
          // Position it over the blue box, towards the top center
          Positioned(
            top: 250 +
                16 -
                3, // Image height + top padding of blue box - half of toggle height (adjust as needed)
            // You might need to adjust 'top' to place it precisely within the blue box
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.2), // Original transparent white
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLangButton("Eng", true),
                  _buildLangButton("ગુજ", false),
                ],
              ),
            ),
          ),

          // Layer 2: Share & Download Buttons (positioned within the stack)
          // Position it at the bottom right of the blue box
          Positioned(
            bottom: 20, // From the bottom of the *Stack's* bounds
            right: 20, // From the right of the *Stack's* bounds
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .end, // Not strictly needed here, Positioned controls placement
              mainAxisSize: MainAxisSize.min, // Keep minimal size
              children: [
                GestureDetector(
                  onTap: _shareText,
                  child: SvgPicture.asset(
                    'assets/icons/share.svg',
                    color: Colors.white,
                    height: 16,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _downloadWidgetAsImage,
                  child: SvgPicture.asset(
                    'assets/icons/download.svg',
                    color: Colors.white,
                    height: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black54 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
