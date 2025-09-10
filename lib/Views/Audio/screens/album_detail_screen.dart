// lib/Views/Audio/screens/album_detail_screen.dart

import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:anoopam_mission/Views/Audio/services/audio_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/widgets/song_list_new.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:anoopam_mission/Views/Audio/screens/audio_player_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _playAllSongs(BuildContext context, List<AudioModel> songs) {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No songs to play.')),
      );
      return;
    }
    AlbumServiceNew.instance.startPlaylist(songs);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting playback for "${widget.album.title}".')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(songs: songs, initialIndex: 0),
      ),
    );
  }

  void _showAlbumMenu(
      BuildContext context, List<AudioModel> songs, AlbumModel albumDetails) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildAlbumBottomSheet(context, songs, albumDetails);
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: true,
    );
  }

  void _addSongsToPlaylist(List<AudioModel> songs) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistManagerPage(
          songsToAdd: songs,
          playlistService: PlaylistService(),
          onPlaylistsUpdated: () {
            // Handle the updated playlists
          },
          albumCoverUrl: widget.album.coverImage,
        ),
      ),
    );
    if (result == true) {
      // Pop this screen and pass a 'true' result to the previous screen.
      Navigator.of(context).pop(true);
    }
  }

  void _downloadAlbum(List<AudioModel> songs) async {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No songs to download.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading album...')),
    );

    final PlaylistService playlistService = PlaylistService();

    for (var song in songs) {
      try {
        await playlistService.downloadAndSaveSong(song);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${song.title}" downloaded.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading "${song.title}": $e')),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Album download complete.')),
    );
  }

  Widget _buildAlbumBottomSheet(
      BuildContext context, List<AudioModel> songs, AlbumModel albumDetails) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                albumDetails.coverImage,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.album, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            title: Text(
              albumDetails.title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              (albumDetails.categories != null &&
                      albumDetails.categories!.isNotEmpty)
                  ? albumDetails.categories!.first
                  : 'Bhajan',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download Album'),
            onTap: () {
              Navigator.pop(context);
              _downloadAlbum(songs);
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to a Playlist'),
            onTap: () {
              Navigator.pop(context);
              _addSongsToPlaylist(songs);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Album'),
            onTap: () {
              Navigator.pop(context);
              var text =
                  'Check out the album "${widget.album.title}" by ${widget.album.artist}!\n\n';
              for (var song in songs) {
                text += '\n${song.title}\n${song.audioUrl}\n';
              }
              Share.share(text);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: MaterialButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_rounded),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black, fontSize: 17),
                decoration: InputDecoration(
                  hintText: 'Search songs...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(
                widget.album.title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder<AlbumModel>(
        future: ApiService().fetchAlbumDetails(widget.album.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text('Failed to load album details.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Album details not found.'));
          }

          AlbumModel albumDetails = snapshot.data!;
          List<AudioModel> songs = albumDetails.songs ?? [];

          if (_isSearching && _searchQuery.isNotEmpty) {
            songs = songs
                .where((song) =>
                    (song.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase())) ||
                    ((song.artist
                            ?.toLowerCase()
                            .contains(_searchQuery.toLowerCase())) ??
                        false))
                .toList();
            if (songs.isEmpty) {
              return Center(
                child: Text(
                  'No songs found matching "${_searchQuery}".',
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }
          }

          return ListView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 45),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    albumDetails.coverImage,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 300,
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
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        albumDetails.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          iconSize: 28.0,
                          onPressed: () =>
                              _showAlbumMenu(context, songs, albumDetails),
                        ),
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
              SizedBox(
                height: 5,
              ),
              Divider(
                height: 1, // You can adjust the height of the divider
                color:
                    Colors.grey.shade300, // Customize the color of the divider
                indent: 20, // Optional: add a leading space
                endIndent: 25, // Optional: add a trailing space
              ),
              SizedBox(
                height: 8,
              ),
              SongList(
                songs: songs,
                showActionButtons: true,
                showAlbumArt: true,
                playlistService: PlaylistService(),
                onSongTap: (int tappedIndex) {
                  PlaylistService()
                      .saveSong(songs[tappedIndex], albumDetails.coverImage);
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
                albumCoverUrl: albumDetails.coverImage,
              ),
            ],
          );
        },
      ),
    );
  }
}
