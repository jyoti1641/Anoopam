import 'package:flutter/material.dart';
import '../models/photo.dart';

class PhotoCard extends StatelessWidget {
  final Photo photo;
  final VoidCallback onTap;

  const PhotoCard({Key? key, required this.photo, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              photo.imageUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
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
                  ),
                );
              },
            ),
            // Semi-transparent overlay to make text more readable, especially at the bottom
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(
                      0.0,
                    ), // Fades to transparent towards the top
                  ],
                  stops: const [0.0, 0.5], // Adjust stops for desired fade
                ),
              ),
            ),
            // Text positioned at the bottom
            // Positioned(
            //   bottom: 4.0,
            //   left: 4.0,
            //   right: 4.0,
            //   child: Text(
            //     photo.caption,
            //     style: const TextStyle(
            //       fontSize: 13,
            //       color: Colors.white,
            //       shadows: [
            //         Shadow(
            //           blurRadius: 3.0,
            //           color: Colors.black,
            //           offset: Offset(1.0, 1.0),
            //         ),
            //       ],
            //     ),
            //     textAlign: TextAlign.center,
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
