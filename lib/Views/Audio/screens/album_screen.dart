// // lib/screens/album_screen.dart
// import 'package:anoopam_mission/Views/Audio/models/album.dart';
// import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
// import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
// import 'package:anoopam_mission/Views/Audio/widgets/album_pop_new.dart';
// import 'package:flutter/material.dart';

// class AlbumScreen extends StatefulWidget {
//   const AlbumScreen({super.key});

//   @override
//   State<AlbumScreen> createState() => _AlbumScreenState();
// }

// class _AlbumScreenState extends State<AlbumScreen> {
//   // Declare a Future to hold the result of fetching albums
//   late Future<List<AlbumModel>> _albumsFuture;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the future by calling the API service
//     _albumsFuture = ApiService().fetchAlbums();
//   }

//   // Method to refresh the album list, called by RefreshIndicator
//   Future<void> _refreshAlbums() async {
//     setState(() {
//       _albumsFuture = ApiService().fetchAlbums(); // Re-fetch data
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // FutureBuilder rebuilds its UI based on the state of the Future
//     return FutureBuilder<List<AlbumModel>>(
//       future: _albumsFuture,
//       builder: (context, snapshot) {
//         // --- Handle Loading State ---
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // --- Handle Error State ---
//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Error: ${snapshot.error!}',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.red, fontSize: 16)),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _refreshAlbums, // Retry fetching on button press
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         }

//         // --- Handle Empty Albums State ---
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(
//             child: RefreshIndicator(
//               onRefresh: _refreshAlbums,
//               child: ListView(
//                 // Use ListView to make RefreshIndicator work on empty content
//                 physics:
//                     const AlwaysScrollableScrollPhysics(), // Always allow pull-to-refresh
//                 children: const [
//                   SizedBox(height: 100), // Add some spacing for visual appeal
//                   Center(
//                     child: Text(
//                       'No albums found. Pull down to refresh or check your connection.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey, fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // --- Display Albums in a Grid ---
//         // RefreshIndicator allows pull-to-refresh functionality
//         return Scaffold(
//           appBar: PreferredSize(
//             preferredSize: Size.fromHeight(kToolbarHeight),
//             child: AppBar(
//               title: Text('Audio'),
//               backgroundColor: Colors.white,
//               elevation: 1,
//               surfaceTintColor: Colors.white,
//             ),
//           ),
//           body: RefreshIndicator(
//             onRefresh: _refreshAlbums, // Trigger album fetch on pull
//             child: GridView.builder(
//               padding: const EdgeInsets.all(16),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, // Two columns for albums
//                 childAspectRatio:
//                     0.8, // Aspect ratio of each album card (height slightly taller than width)
//                 crossAxisSpacing: 16, // Horizontal space between cards
//                 mainAxisSpacing: 16, // Vertical space between cards
//               ),
//               itemCount: snapshot.data!.length, // Use data from snapshot
//               itemBuilder: (context, index) {
//                 final album = snapshot.data![index];
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AlbumDetailScreen(album: album),
//                       ),
//                     );
//                   },
//                   child: Card(
//                     clipBehavior: Clip
//                         .antiAlias, // Ensures content is clipped to card shape
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(
//                           12.0), // Rounded corners for the card
//                     ),
//                     elevation: 4.0, // Shadow effect
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment
//                           .stretch, // Stretch children horizontally
//                       children: [
//                         Expanded(
//                           child: Image.network(
//                             album.albumArt, // Album cover image URL
//                             fit: BoxFit.cover, // Cover the entire space
//                             errorBuilder: (context, error, stackTrace) {
//                               // Placeholder for image loading errors or broken URLs
//                               return Container(
//                                 color: Colors.grey[
//                                     300], // Grey background for placeholder
//                                 child: const Icon(Icons.album,
//                                     size: 60, color: Colors.grey), // Album icon
//                               );
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment
//                                 .start, // Align text to the start
//                             children: [
//                               Text(
//                                 album.title, // Album title
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow
//                                     .ellipsis, // Truncate long titles with "..."
//                               ),
//                               const SizedBox(height: 4), // Small vertical space
//                               Text(
//                                 album.artist, // Artist name
//                                 style: TextStyle(
//                                   color: Colors.grey[
//                                       600], // Lighter grey for artist name
//                                   fontSize: 14,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow
//                                     .ellipsis, // Truncate long artist names
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // anoopam_mission/lib/Views/Audio/screens/album_screen.dart
// import 'package:flutter/material.dart';
// import 'package:anoopam_mission/Views/Audio/models/album.dart'; // From your path: AlbumModel
// import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart'; // Import the new AlbumDetailScreen
// import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart'; // From your path: ApiService

// class AlbumScreen extends StatefulWidget {
//   const AlbumScreen({super.key});

//   @override
//   State<AlbumScreen> createState() => _AlbumScreenState();
// }

// class _AlbumScreenState extends State<AlbumScreen> {
//   // Declare a Future to hold the result of fetching albums
//   late Future<List<AlbumModel>> _albumsFuture;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the future by calling the API service
//     _albumsFuture = ApiService().fetchAlbums();
//   }

//   // Method to refresh the album list, called by RefreshIndicator
//   Future<void> _refreshAlbums() async {
//     setState(() {
//       _albumsFuture = ApiService().fetchAlbums(); // Re-fetch data
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // FutureBuilder rebuilds its UI based on the state of the Future
//     return FutureBuilder<List<AlbumModel>>(
//       future: _albumsFuture,
//       builder: (context, snapshot) {
//         // --- Handle Loading State ---
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // --- Handle Error State ---
//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Error: ${snapshot.error!}',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.red, fontSize: 16)),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _refreshAlbums, // Retry fetching on button press
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         }

//         // --- Handle Empty Albums State ---
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(
//             child: RefreshIndicator(
//               onRefresh: _refreshAlbums,
//               child: ListView(
//                 // Use ListView to make RefreshIndicator work on empty content
//                 physics:
//                     const AlwaysScrollableScrollPhysics(), // Always allow pull-to-refresh
//                 children: const [
//                   SizedBox(height: 100), // Add some spacing for visual appeal
//                   Center(
//                     child: Text(
//                       'No albums found. Pull down to refresh or check your connection.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey, fontSize: 16),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         // --- Display Albums in a Grid ---
//         // RefreshIndicator allows pull-to-refresh functionality
//         return RefreshIndicator(
//           onRefresh: _refreshAlbums, // Trigger album fetch on pull
//           child: GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2, // Two columns for albums
//               childAspectRatio:
//                   0.8, // Aspect ratio of each album card (height slightly taller than width)
//               crossAxisSpacing: 16, // Horizontal space between cards
//               mainAxisSpacing: 16, // Vertical space between cards
//             ),
//             itemCount: snapshot.data!.length, // Use data from snapshot
//             itemBuilder: (context, index) {
//               final album = snapshot.data![index];
//               return GestureDetector(
//                 onTap: () {
//                   // Navigate to the new AlbumDetailScreen when an album card is tapped
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AlbumDetailScreen(album: album),
//                     ),
//                   );
//                 },
//                 child: Card(
//                   clipBehavior: Clip
//                       .antiAlias, // Ensures content is clipped to card shape
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(
//                         12.0), // Rounded corners for the card
//                   ),
//                   elevation: 4.0, // Shadow effect
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment
//                         .stretch, // Stretch children horizontally
//                     children: [
//                       Expanded(
//                         child: Image.network(
//                           album.albumArt, // Album cover image URL
//                           fit: BoxFit.cover, // Cover the entire space
//                           errorBuilder: (context, error, stackTrace) {
//                             // Placeholder for image loading errors or broken URLs
//                             return Container(
//                               color: Colors
//                                   .grey[300], // Grey background for placeholder
//                               child: const Icon(Icons.album,
//                                   size: 60, color: Colors.grey), // Album icon
//                             );
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment
//                               .start, // Align text to the start
//                           children: [
//                             Text(
//                               album.title, // Album title
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow
//                                   .ellipsis, // Truncate long titles with "..."
//                             ),
//                             const SizedBox(height: 4), // Small vertical space
//                             Text(
//                               album.artist, // Artist name
//                               style: TextStyle(
//                                 color: Colors
//                                     .grey[600], // Lighter grey for artist name
//                                 fontSize: 14,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow
//                                   .ellipsis, // Truncate long artist names
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// anoopam_mission/lib/Views/Audio/screens/album_screen.dart
// import 'package:anoopam_mission/Views/Audio/screens/playlist_detail_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:anoopam_mission/Views/Audio/models/album.dart'; // AlbumModel
// import 'package:anoopam_mission/Views/Audio/models/playlist.dart'; // Import PlaylistModel
// import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
// import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart'; // ApiService
// import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart'; // Import PlaylistService
// import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart'; // To show songs in playlist detail

// class AlbumScreen extends StatefulWidget {
//   const AlbumScreen({super.key});

//   @override
//   State<AlbumScreen> createState() => _AlbumScreenState();
// }

// class _AlbumScreenState extends State<AlbumScreen> {
//   late Future<List<AlbumModel>> _albumsFuture;
//   late Future<List<Playlist>> _playlistsFuture; // Future for user playlists
//   final PlaylistService _playlistService =
//       PlaylistService(); // PlaylistService instance

//   @override
//   void initState() {
//     super.initState();
//     _fetchData(); // Call a method to fetch both albums and playlists
//   }

//   // Method to fetch both albums and playlists
//   Future<void> _fetchData() async {
//     setState(() {
//       _albumsFuture = ApiService().fetchAlbums();
//       _playlistsFuture = _playlistService.loadPlaylists();
//     });
//   }

//   // Method to refresh all data, called by RefreshIndicator
//   Future<void> _refreshAllData() async {
//     await _fetchData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _refreshAllData, // Refresh all data
//       child: ListView(
//         physics:
//             const AlwaysScrollableScrollPhysics(), // Always allow pull-to-refresh
//         children: [
//           // Albums Section
//           FutureBuilder<List<AlbumModel>>(
//             future: _albumsFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError) {
//                 return Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text('Error loading albums: ${snapshot.error!}',
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                                 color: Colors.red, fontSize: 16)),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _refreshAllData,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blueGrey,
//                             foregroundColor: Colors.white,
//                           ),
//                           child: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }
//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Center(
//                     child: Text(
//                       'No albums found. Pull down to refresh or check your connection.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey, fontSize: 16),
//                     ),
//                   ),
//                 );
//               }

//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Text(
//                       'Albums',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics:
//                         const NeverScrollableScrollPhysics(), // Prevent nested scrolling
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 0.8,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                     ),
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       final album = snapshot.data![index];
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   AlbumDetailScreen(album: album),
//                             ),
//                           );
//                         },
//                         child: Card(
//                           clipBehavior: Clip.antiAlias,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0),
//                           ),
//                           elevation: 4.0,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Expanded(
//                                 child: Image.network(
//                                   album.albumArt,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       color: Colors.grey[300],
//                                       child: const Icon(Icons.album,
//                                           size: 60, color: Colors.grey),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       album.title,
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       album.artist,
//                                       style: TextStyle(
//                                         color: Colors.grey[600],
//                                         fontSize: 14,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               );
//             },
//           ),
//           const SizedBox(height: 24), // Spacer between Albums and Playlists
//           const Divider(), // Optional: A divider for visual separation
//           const SizedBox(height: 16),

//           // User Playlists Section
//           FutureBuilder<List<Playlist>>(
//             future: _playlistsFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError) {
//                 return Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Text('Error loading playlists: ${snapshot.error!}',
//                         textAlign: TextAlign.center,
//                         style:
//                             const TextStyle(color: Colors.red, fontSize: 16)),
//                   ),
//                 );
//               }
//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Center(
//                     child: Text(
//                       'No custom playlists found. Add songs to create one!',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey, fontSize: 16),
//                     ),
//                   ),
//                 );
//               }

//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Text(
//                       'Your Playlists',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics:
//                         const NeverScrollableScrollPhysics(), // Prevents nested scrolling
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2, // Two columns for playlists
//                       childAspectRatio: 0.8,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                     ),
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       final playlist = snapshot.data![index];
//                       // Display Playlist card, similar to Album card
//                       return GestureDetector(
//                         onTap: () {
//                           // Navigate to a playlist detail screen (similar to AlbumDetailScreen)
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PlaylistDetailScreen(
//                                   playlist: playlist,
//                                   onPlaylistUpdated:
//                                       _refreshAllData), // Pass callback
//                             ),
//                           );
//                         },
//                         child: Card(
//                           clipBehavior: Clip.antiAlias,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.0),
//                           ),
//                           elevation: 4.0,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   color:
//                                       Colors.blueGrey[100], // Placeholder color
//                                   child: playlist.songs.isNotEmpty
//                                       ? Image.network(
//                                           playlist.songs.first
//                                               .imageUrl, // Show first song's image
//                                           fit: BoxFit.cover,
//                                           errorBuilder:
//                                               (context, error, stackTrace) {
//                                             return Icon(Icons.queue_music,
//                                                 size: 60,
//                                                 color: Colors.blueGrey[400]);
//                                           },
//                                         )
//                                       : Icon(Icons.queue_music,
//                                           size: 60,
//                                           color: Colors.blueGrey[400]),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       playlist.name,
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       '${playlist.songs.length} songs',
//                                       style: TextStyle(
//                                         color: Colors.grey[600],
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

//good one
// anoopam_mission/lib/Views/Audio/screens/album_screen.dart
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
import 'package:flutter/material.dart';

import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_detail_screen.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late Future<List<AlbumModel>> _albumsFuture;
  late Future<List<Playlist>> _playlistsFuture;
  final PlaylistService _playlistService = PlaylistService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _albumsFuture = ApiService().fetchAlbums();
      // Ensure Favorites playlist exists and is loaded with others
      _playlistsFuture =
          _playlistService.loadPlaylists().then((allPlaylists) async {
        final favoritesPlaylist =
            await _playlistService.getOrCreateFavoritesPlaylist();
        // Ensure favoritesPlaylist is in the list, if not already
        if (!allPlaylists
            .any((p) => p.name == PlaylistService.favoritesPlaylistName)) {
          allPlaylists.add(favoritesPlaylist);
        }
        // Sort playlists to ensure "Favorites" is first, then by name
        allPlaylists.sort((a, b) {
          if (a.name == PlaylistService.favoritesPlaylistName) return -1;
          if (b.name == PlaylistService.favoritesPlaylistName) return 1;
          return a.name.compareTo(b.name);
        });
        return allPlaylists;
      });
    });
  }

  Future<void> _refreshAllData() async {
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshAllData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          FutureBuilder<List<AlbumModel>>(
            future: _albumsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error loading albums: ${snapshot.error!}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshAllData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No albums found. Pull down to refresh or check your connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Albums',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final album = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumDetailScreen(
                                album: album,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Image.network(
                                  album.albumArt,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.album,
                                          size: 60, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      album.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      album.artist,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
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
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // User Playlists Section
          FutureBuilder<List<Playlist>>(
            future: _playlistsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error loading playlists: ${snapshot.error!}',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No custom playlists found. Add songs to create one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Your Playlists',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final playlist = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaylistDetailScreen(
                                  // playlistService: PlaylistService(),
                                  playlist: playlist,
                                  onPlaylistUpdated: _refreshAllData),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  color: Colors.blueGrey[100],
                                  child: playlist.songs.isNotEmpty
                                      ? Image.network(
                                          playlist.songs.first.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(Icons.queue_music,
                                                size: 60,
                                                color: Colors.blueGrey[400]);
                                          },
                                        )
                                      : Icon(Icons.queue_music,
                                          size: 60,
                                          color: Colors.blueGrey[400]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      playlist.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${playlist.songs.length} songs',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
