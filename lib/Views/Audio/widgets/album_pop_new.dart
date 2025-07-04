// // lib/widgets/album_popup.dart
// import 'package:anoopam_mission/Views/Audio/models/album.dart';
// import 'package:anoopam_mission/Views/Audio/models/song.dart';
// import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
// import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
// import 'package:flutter/material.dart';

// class AlbumPopup extends StatelessWidget {
//   final AlbumModel album;

//   const AlbumPopup({super.key, required this.album});

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       // Use a Dialog for the pop-up effect
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height *
//               0.8, // Max 80% of screen height
//         ),
//         child: Column(
//           mainAxisSize:
//               MainAxisSize.min, // Make column take minimum space vertically
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Album Header (Cover, Title, Artist)
//             Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.network(
//                     album.albumArt,
//                     width: 100,
//                     height: 100,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         width: 100,
//                         height: 100,
//                         color: Colors.grey[300],
//                         child: const Icon(Icons.album,
//                             size: 60, color: Colors.grey),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 16.0),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         album.title,
//                         style: const TextStyle(
//                           fontSize: 22.0,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4.0),
//                       Text(
//                         album.artist,
//                         style: TextStyle(
//                           fontSize: 16.0,
//                           color: Colors.grey[700],
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16.0),
//             // Songs Section Title
//             const Text(
//               'Songs in this Album',
//               style: TextStyle(
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8.0),
//             // Song List
//             Expanded(
//               child: FutureBuilder<List<AudioModel>>(
//                 // Directly instantiate ApiService here as Provider is not used
//                 future: ApiService().getSongsByAlbum(album.id),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Center(
//                         child: Text('No songs found in this album.'));
//                   }
//                   // Display the list of songs using the SongList widget
//                   return SongList(
//                     songs: snapshot.data!,
//                     showActionButtons:
//                         true, // Show play, favorite, download buttons
//                     showAlbumArt: true, // Show individual song art
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             // Close Button
//             Align(
//               alignment: Alignment.centerRight,
//               child: ElevatedButton(
//                 onPressed: () =>
//                     Navigator.of(context).pop(), // Close the dialog
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueGrey, // Button background color
//                   foregroundColor: Colors.white, // Button text color
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 ),
//                 child: const Text('Close'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// anoopam_mission/lib/Views/Audio/screens/album_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart'; // Import PlaylistService

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;

  // Define a GlobalKey for the SongList widget to help preserve its state
  final GlobalKey _songListKey = GlobalKey();
  // Instantiate PlaylistService here to pass to SongList
  final PlaylistService _playlistService = PlaylistService();

  AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(album.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    album.albumArt,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.album,
                            size: 80, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.title,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        album.artist,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Songs in this Album',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AudioModel>>(
              future: ApiService().getSongsByAlbum(album.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No songs found in this album.'));
                }
                return SongList(
                  // key: _songListKey,
                  songs: snapshot.data!,
                  showActionButtons: true,
                  showAlbumArt: true,
                  // Pass the playlist service and a callback for favorite updates
                  playlistService: _playlistService,
                  onFavoritesUpdated: () {
                    // This callback could be used to update a UI element in AlbumDetailScreen
                    // if it displayed favorite counts, but primarily it's for AlbumScreen
                    // to refresh its playlist list.
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
