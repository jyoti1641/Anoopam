// // lib/screens/album_detail_screen.dart
// import 'package:anoopam_mission/Views/Audio/models/album.dart';
// import 'package:anoopam_mission/Views/Audio/models/song.dart';
// import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
// import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
// import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
// import 'package:flutter/material.dart';

// class AlbumDetailScreen extends StatelessWidget {
//   final AlbumModel album;

//   const AlbumDetailScreen({super.key, required this.album});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(album.title), // AppBar title is the album title
//         // No close button needed, standard back button handles navigation
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Album Header (Cover, Title, Artist)
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.network(
//                     album.albumArt,
//                     width: 120, // Larger image for a detail screen
//                     height: 120,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         width: 120,
//                         height: 120,
//                         color: Colors.grey[300],
//                         child: const Icon(Icons.album,
//                             size: 80, color: Colors.grey),
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
//                           fontSize: 24.0, // Larger font size for title
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8.0),
//                       Text(
//                         album.artist,
//                         style: TextStyle(
//                           fontSize: 18.0, // Larger font size for artist
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
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Text(
//               'Songs in this Album',
//               style: TextStyle(
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           // Song List
//           Expanded(
//             child: FutureBuilder<List<AudioModel>>(
//               future: ApiService().getSongsByAlbum(album.id),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                       child: Text('No songs found in this album.'));
//                 }
//                 // Display the list of songs using the SongList widget
//                 return SongList(
//                   songs: snapshot.data!,
//                   showActionButtons: true,
//                   showAlbumArt: true,
//                   playlistService: PlaylistService(),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // lib/screens/album_detail_screen.dart
// import 'package:anoopam_mission/Views/Audio/models/album.dart';
// import 'package:anoopam_mission/Views/Audio/models/song.dart';
// import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
// import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
// import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
// import 'package:flutter/material.dart';

// class AlbumDetailScreen extends StatelessWidget {
//   final AlbumModel album;

//   const AlbumDetailScreen({super.key, required this.album});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(album.title), // AppBar title is the album title
//         // No close button needed, standard back button handles navigation
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Album Header (Cover, Title, Artist)
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.network(
//                     album.albumArt,
//                     width: 120, // Larger image for a detail screen
//                     height: 120,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         width: 120,
//                         height: 120,
//                         color: Colors.grey[300],
//                         child: const Icon(Icons.album,
//                             size: 80, color: Colors.grey),
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
//                           fontSize: 24.0, // Larger font size for title
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8.0),
//                       Text(
//                         album.artist,
//                         style: TextStyle(
//                           fontSize: 18.0, // Larger font size for artist
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
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Text(
//               'Songs in this Album',
//               style: TextStyle(
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           // Song List
//           Expanded(
//             child: FutureBuilder<List<AudioModel>>(
//               future: ApiService().getSongsByAlbum(album.id),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                       child: Text('No songs found in this album.'));
//                 }
//                 // Display the list of songs using the SongList widget
//                 return SongList(
//                   songs: snapshot.data!,
//                   showActionButtons: true,
//                   showAlbumArt: true,
//                   playlistService: PlaylistService(),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:anoopam_mission/Views/Audio/models/album.dart';
// import 'package:anoopam_mission/Views/Audio/models/song.dart';
// import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
// import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart'; // Assume this service handles actual playback
// import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
// import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart'; // Import the share_plus package

// class AlbumDetailScreen extends StatelessWidget {
//   final AlbumModel album;

//   const AlbumDetailScreen({super.key, required this.album});

//   // Function for the "Play All" functionality
//   void _playAllSongs(BuildContext context, List<AudioModel> songs) {
//     if (songs.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No songs to play.')),
//       );
//       return;
//     }

//     // Call your actual audio player service to start playing the list.
//     // This assumes AudioServiceNew has a method like startPlaylist.
//     AlbumServiceNew.instance.startPlaylist(songs);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Starting playback for "${album.title}".')),
//     );
//     // You might want to navigate to a player screen here or show a persistent mini-player
//   }

//   // Function to show the album menu bottom sheet
//   void _showAlbumMenu(BuildContext context, List<AudioModel> songs) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return _buildAlbumBottomSheet(context, songs);
//       },
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
//       ),
//       isScrollControlled:
//           true, // Allows the bottom sheet to be full screen if content needs it
//     );
//   }

//   // Widget to build the content of the album bottom sheet
//   Widget _buildAlbumBottomSheet(BuildContext context, List<AudioModel> songs) {
//     // You can also add a "Play All" button directly in the bottom sheet if desired
//     return SingleChildScrollView(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.network(
//                     album.albumArt,
//                     width: 80,
//                     height: 80,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         width: 80,
//                         height: 80,
//                         color: Colors.grey[300],
//                         child: const Icon(Icons.album,
//                             size: 50, color: Colors.grey),
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
//                           fontSize: 20.0,
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
//           ),
//           const Divider(),
//           // New "Play All" button in the bottom sheet
//           ListTile(
//             leading: const Icon(Icons.play_arrow),
//             title: const Text('Play All Songs'),
//             onTap: () {
//               Navigator.pop(context); // Close the bottom sheet
//               _playAllSongs(
//                   context, songs); // Call the existing play all function
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.download),
//             title: const Text('Download Album'),
//             onTap: () {
//               Navigator.pop(context); // Close the bottom sheet
//               // Implement download logic here
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                     content: Text(
//                         'Downloading album "${album.title}"... (Placeholder)')),
//               );
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.playlist_add),
//             title: const Text('Add to a Playlist'), // Changed text for clarity
//             onTap: () {
//               Navigator.pop(context); // Close the bottom sheet
//               // Implement add to playlist logic here (e.g., show another dialog to select playlist)
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                     content: Text(
//                         'Please select a playlist to add songs from "${album.title}" (Placeholder)')),
//               );
//               // Example: Assuming PlaylistService has a method to add multiple songs
//               // PlaylistService().addSongsToPlaylist(songs);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.share),
//             title: const Text('Share Album'),
//             onTap: () {
//               Navigator.pop(context); // Close the bottom sheet
//               // Actual share logic using share_plus
//               Share.share(
//                   'Check out the album "${album.title}" by ${album.artist}!');
//             },
//           ),
//           const SizedBox(height: 20), // Add some bottom padding
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           album.title,
//           style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
//         ),
//         centerTitle: true,
//         actions: [
//           Icon(Icons.search),
//         ],
//         actionsPadding: EdgeInsets.all(20),
//       ),
//       body: FutureBuilder<List<AudioModel>>(
//         future: ApiService().getSongsByAlbum(album.id),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No songs found in this album.'));
//           }

//           final songs = snapshot.data!;

//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Album Header Layout
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15.0),
//                     child: Image.network(
//                       album.albumArt,
//                       width: double.infinity,
//                       height: 250, // Adjust height as needed
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           width: double.infinity,
//                           height: 250,
//                           color: Colors.grey[300],
//                           child: const Icon(Icons.album,
//                               size: 150, color: Colors.grey),
//                         );
//                       },
//                     ),
//                   ),
//                 ),

//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 5.0, horizontal: 17),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           album.title,
//                           style: const TextStyle(
//                             fontSize: 20.0,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       // Action Buttons on the right
//                       Row(
//                         children: [
//                           // Menu Button (opens bottom sheet)
//                           IconButton(
//                             icon: const Icon(Icons.more_vert),
//                             iconSize: 28.0,
//                             onPressed: () => _showAlbumMenu(context, songs),
//                           ),
//                           // Play All Button (visible directly on the screen)
//                           IconButton(
//                             icon: const Icon(Icons.play_circle_fill),
//                             color: Theme.of(context).primaryColor,
//                             iconSize: 40.0,
//                             onPressed: () => _playAllSongs(context, songs),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Song List
//                 SongList(
//                   songs: songs,
//                   showActionButtons: true,
//                   showAlbumArt: true,
//                   playlistService: PlaylistService(),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// lib/Views/Audio/screens/album_detail_screen.dart (Modified for consolidated AudioPlayerScreen)
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
// Import the single consolidated file that contains AudioPlayerScreen and all its dependencies.
import 'package:anoopam_mission/Views/Audio/screens/audio_player_screen.dart';

// Note: AlbumModel, AudioModel, ApiService, AudioServiceNew, AlbumServiceNew, PlaylistService, and SongList
// are now assumed to be defined within 'audio_player_screen.dart' for a single-file setup,
// or should be imported from their respective original locations if you prefer separate files.
// For this modification, we assume they are accessible via the audio_player_screen.dart import.

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  // Function for the "Play All" functionality
  void _playAllSongs(BuildContext context, List<AudioModel> songs) {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No songs to play.')),
      );
      return;
    }

    // Call your actual audio player service to start playing the list.
    // This assumes AlbumServiceNew.instance.startPlaylist(songs) would internally
    // trigger playback in AudioServiceNew. For navigation, we directly go to the player.
    // AlbumServiceNew.instance.startPlaylist(songs); // This would be the actual playback initiation

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting playback for "${album.title}".')),
    );

    // Navigate to the new AudioPlayerScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(songs: songs, initialIndex: 0),
      ),
    );
  }

  // Function to show the album menu bottom sheet
  void _showAlbumMenu(BuildContext context, List<AudioModel> songs) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildAlbumBottomSheet(context, songs);
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled:
          true, // Allows the bottom sheet to be full screen if content needs it
    );
  }

  // Widget to build the content of the album bottom sheet
  Widget _buildAlbumBottomSheet(BuildContext context, List<AudioModel> songs) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    album.albumArt,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.album,
                            size: 50, color: Colors.grey),
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
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        album.artist,
                        style: TextStyle(
                          fontSize: 16.0,
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
          const Divider(),
          // New "Play All" button in the bottom sheet
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Play All Songs'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              _playAllSongs(
                  context, songs); // Call the existing play all function
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download Album'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              // Implement download logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Downloading album "${album.title}"... (Placeholder)')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to a Playlist'), // Changed text for clarity
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              // Implement add to playlist logic here (e.g., show another dialog to select playlist)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Please select a playlist to add songs from "${album.title}" (Placeholder)')),
              );
              // Example: Assuming PlaylistService has a method to add multiple songs
              // PlaylistService().addSongsToPlaylist(songs);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Album'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              // Actual share logic using share_plus
              Share.share(
                  'Check out the album "${album.title}" by ${album.artist}!');
            },
          ),
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          album.title,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          Icon(Icons.search),
        ],
        actionsPadding: EdgeInsets.all(20),
      ),
      body: FutureBuilder<List<AudioModel>>(
        future: ApiService().getSongsByAlbum(album
            .id), // Assuming ApiService exists (now from consolidated file)
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No songs found in this album.'));
          }

          final songs = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album Header Layout
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      album.albumArt,
                      width: double.infinity,
                      height: 250, // Adjust height as needed
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[300],
                          child: const Icon(Icons.album,
                              size: 150, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5.0, horizontal: 17),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          album.title,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Action Buttons on the right
                      Row(
                        children: [
                          // Menu Button (opens bottom sheet)
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            iconSize: 28.0,
                            onPressed: () => _showAlbumMenu(context, songs),
                          ),
                          // Play All Button (visible directly on the screen)
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill),
                            color: Theme.of(context).primaryColor,
                            iconSize: 40.0,
                            onPressed: () => _playAllSongs(context, songs),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Song List
                SongList(
                  // SongList is now also assumed to be defined/imported from audio_player_screen.dart
                  songs: songs,
                  showActionButtons: true,
                  showAlbumArt: true,
                  playlistService:
                      PlaylistService(), // PlaylistService also from consolidated file
                  // When a song is tapped in SongList, navigate to AudioPlayerScreen
                  onSongTap: (int tappedIndex) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayerScreen(
                          songs: songs,
                          initialIndex: tappedIndex,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
