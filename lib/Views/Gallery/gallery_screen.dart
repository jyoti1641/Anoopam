// import 'package:anoopam_mission/data/photo_repository.dart';
// import 'package:anoopam_mission/models/album.dart';
// import 'package:anoopam_mission/widgets/album_card.dart';
// import 'package:flutter/material.dart';

// import 'photo_grid_screen.dart';

// class GalleryScreen extends StatefulWidget {
//   const GalleryScreen({Key? key}) : super(key: key);

//   @override
//   State<GalleryScreen> createState() => GalleryScreenState();
// }

// class GalleryScreenState extends State<GalleryScreen> {
//   List<Album> _albums = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//   final PhotoRepository _repository =
//       PhotoRepository(); // Instantiate repository

//   @override
//   void initState() {
//     super.initState();
//     _fetchAlbums();
//   }

//   Future<void> _fetchAlbums() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final fetchedAlbums = await _repository.getAlbums();
//       setState(() {
//         _albums = fetchedAlbums;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: AppBar(
//           title: Text('Gallery'),
//           backgroundColor: Colors.white,
//           elevation: 1,
//           surfaceTintColor: Colors.white,
//         ),
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : _errorMessage != null
//               ? Center(child: Text('Error: $_errorMessage'))
//               : _albums.isEmpty
//               ? const Center(child: Text('No albums found.'))
//               : GridView.builder(
//                 padding: const EdgeInsets.all(8.0),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 8.0,
//                   mainAxisSpacing: 8.0,
//                   childAspectRatio: 0.8,
//                 ),
//                 itemCount: _albums.length,
//                 itemBuilder: (context, index) {
//                   final album = _albums[index];
//                   return AlbumCard(
//                     album: album,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) => PhotoGridScreen(
//                                 albumId: album.id,
//                                 albumName: album.name,
//                               ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//     );
//   }
// }
import 'package:anoopam_mission/data/photo_repository.dart';
import 'package:anoopam_mission/models/album.dart';
import 'package:anoopam_mission/widgets/album_card.dart';
import 'package:flutter/material.dart';

import 'photo_grid_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  List<Album> _albums = [];
  List<Album> _filteredAlbums = []; // New list to hold filtered albums
  bool _isLoading = false;
  String? _errorMessage;
  final PhotoRepository _repository =
      PhotoRepository(); // Instantiate repository
  TextEditingController _searchController =
      TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
    // Add a listener to the search controller to filter albums as the user types
    _searchController.addListener(_filterAlbums);
  }

  @override
  void dispose() {
    _searchController.removeListener(
        _filterAlbums); // Remove listener to prevent memory leaks
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  Future<void> _fetchAlbums() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedAlbums = await _repository.getAlbums();
      setState(() {
        _albums = fetchedAlbums;
        _filteredAlbums =
            fetchedAlbums; // Initialize filtered albums with all albums
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to filter albums based on search query
  void _filterAlbums() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAlbums = _albums.where((album) {
        return album.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Now a standard AppBar
        title: const Text('Gallery'),
        backgroundColor: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.white,
      ),
      body: Column(
        // Use Column for vertical arrangement in the body
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0), // Padding for the search bar
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search albums...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear(); // Clear search text
                          _filterAlbums(); // Trigger filter to show all albums
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
            ),
          ),
          Expanded(
            // Expanded to allow GridView to take remaining space
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : _filteredAlbums.isEmpty &&
                            _searchController.text.isNotEmpty
                        ? const Center(child: Text('No matching albums found.'))
                        : _albums.isEmpty
                            ? const Center(child: Text('No albums found.'))
                            : GridView.builder(
                                padding: const EdgeInsets.all(8.0),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: _filteredAlbums
                                    .length, // Use filteredAlbums here
                                itemBuilder: (context, index) {
                                  final album = _filteredAlbums[
                                      index]; // Use filteredAlbums here
                                  return AlbumCard(
                                    album: album,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PhotoGridScreen(
                                            albumId: album.id,
                                            albumName: album.name,
                                          ),
                                        ),
                                      );
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
