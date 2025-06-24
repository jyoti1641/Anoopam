import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';

class PlaylistManagerPage extends StatefulWidget {
  final List<AudioModel>?
      songsToAdd; // Nullable, if coming from "add to playlist"
  final PlaylistService playlistService;
  final VoidCallback? onPlaylistsUpdated; // Callback for when playlists change

  const PlaylistManagerPage({
    super.key,
    this.songsToAdd,
    required this.playlistService,
    this.onPlaylistsUpdated,
  });

  @override
  State<PlaylistManagerPage> createState() => _PlaylistManagerPageState();
}

class _PlaylistManagerPageState extends State<PlaylistManagerPage> {
  List<Playlist> _userPlaylists = [];
  bool _isLoading = true;
  final TextEditingController _newPlaylistNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserPlaylists();
  }

  Future<void> _loadUserPlaylists() async {
    setState(() {
      _isLoading = true;
    });
    final allPlaylists = await widget.playlistService.loadPlaylists();
    setState(() {
      // Filter out the "Favorites" playlist
      _userPlaylists = allPlaylists
          .where((p) => p.name != PlaylistService.favoritesPlaylistName)
          .toList();
      _isLoading = false;
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _createNewPlaylist() async {
    String? newPlaylistName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Playlist'),
          content: TextField(
            controller: _newPlaylistNameController,
            decoration: const InputDecoration(
              hintText: 'Enter new playlist name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                Navigator.of(context).pop(_newPlaylistNameController.text);
              },
            ),
          ],
        );
      },
    );

    if (newPlaylistName != null && newPlaylistName.isNotEmpty) {
      if (_userPlaylists.any((p) => p.name == newPlaylistName)) {
        _showSnackBar('Playlist "$newPlaylistName" already exists.');
        return;
      }
      try {
        await widget.playlistService
            .addSongsToPlaylist(newPlaylistName, widget.songsToAdd ?? []);
        _newPlaylistNameController.clear();
        _showSnackBar('Playlist "$newPlaylistName" created!');
        widget.onPlaylistsUpdated?.call();
        _loadUserPlaylists();
      } catch (e) {
        _showSnackBar('Error creating playlist: $e');
      }
    }
  }

  Future<void> _addSongToExistingPlaylist(Playlist playlist) async {
    if (widget.songsToAdd != null) {
      try {
        await widget.playlistService.addSongsToPlaylist(
          playlist.name,
          widget.songsToAdd ?? [],
        );
        final songNames = widget.songsToAdd?.map((e) => e.title) ?? [];
        _showSnackBar('${songNames.join(', ')} added to ${playlist.name}!');
        widget.onPlaylistsUpdated?.call();
        Navigator.of(context).pop(); // Go back after adding
      } catch (e) {
        _showSnackBar('Error adding song to playlist: $e');
      }
    }
  }

  Future<void> _deletePlaylist(String playlistName) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Playlist?'),
          content: Text('Are you sure you want to delete "$playlistName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await widget.playlistService.deletePlaylist(playlistName);
        _loadUserPlaylists();
        _showSnackBar('Playlist "$playlistName" deleted!');
        widget.onPlaylistsUpdated?.call();
      } catch (e) {
        _showSnackBar('Error deleting playlist: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
            widget.songsToAdd != null ? 'Add to Playlist' : 'Manage Playlists'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _createNewPlaylist,
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Playlist'),
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(50), // Make button wider
                    ),
                  ),
                ),
                Expanded(
                  child: _userPlaylists.isEmpty
                      ? const Center(
                          child: Text(
                            'No custom playlists found. Create one above!',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _userPlaylists.length,
                          itemBuilder: (context, index) {
                            final playlist = _userPlaylists[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: Text(playlist.name),
                                subtitle:
                                    Text('${playlist.songs.length} songs'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.songsToAdd != null)
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () =>
                                            _addSongToExistingPlaylist(
                                                playlist),
                                        tooltip: 'Add song to this playlist',
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deletePlaylist(playlist.name),
                                      tooltip: 'Delete playlist',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
