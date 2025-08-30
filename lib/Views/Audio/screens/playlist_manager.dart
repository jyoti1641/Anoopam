import 'package:anoopam_mission/Views/Audio/screens/create_new_playlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:easy_localization/easy_localization.dart';

class PlaylistManagerPage extends StatefulWidget {
  final List<AudioModel>?
      songsToAdd; // Nullable, if coming from "add to playlist"
  final String? albumCoverUrl;
  final PlaylistService playlistService;
  final VoidCallback? onPlaylistsUpdated; // Callback for when playlists change

  const PlaylistManagerPage({
    super.key,
    this.songsToAdd,
    this.albumCoverUrl,
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
      // No longer need to filter out a "Favorites" playlist
      _userPlaylists = allPlaylists.toList();
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
    String? newPlaylistName = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateNewPlaylistScreen(),
      ),
    );

    if (newPlaylistName != null && newPlaylistName.isNotEmpty) {
      if (_userPlaylists.any((p) => p.name == newPlaylistName)) {
        _showSnackBar(
            'playlist.exists'.tr(namedArgs: {'name': newPlaylistName}));
        return;
      }
      try {
        await widget.playlistService.createPlaylist(newPlaylistName);

        if (widget.songsToAdd != null && widget.songsToAdd!.isNotEmpty) {
          await widget.playlistService.addSongsToPlaylist(
            newPlaylistName,
            widget.songsToAdd!,
            widget.albumCoverUrl!,
          );
        }
        _showSnackBar(
            'playlist.created'.tr(namedArgs: {'name': newPlaylistName}));
        await _loadUserPlaylists();
        widget.onPlaylistsUpdated?.call();
        if (widget.songsToAdd != null && widget.songsToAdd!.isNotEmpty) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        _showSnackBar(
            'playlist.errorCreating'.tr(namedArgs: {'error': e.toString()}));
      }
    }
  }

  Future<void> _addSongToExistingPlaylist(Playlist playlist) async {
    if (widget.songsToAdd != null && widget.songsToAdd!.isNotEmpty) {
      try {
        await widget.playlistService.addSongsToPlaylist(
          playlist.name,
          widget.songsToAdd!,
          widget.albumCoverUrl!,
        );
        final songTitles = widget.songsToAdd!.map((s) => s.title).join(', ');
        _showSnackBar('playlist.songsAdded'.tr(namedArgs: {
          'songs': songTitles,
          'playlistName': playlist.name,
        }));
        widget.onPlaylistsUpdated?.call();
        Navigator.of(context).pop();
      } catch (e) {
        _showSnackBar(
            'playlist.errorAdding'.tr(namedArgs: {'error': e.toString()}));
      }
    }
  }

  Future<void> _deletePlaylist(String playlistName) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('playlist.deleteTitle'.tr()),
          content: Text(
              'playlist.deleteConfirm'.tr(namedArgs: {'name': playlistName})),
          actions: <Widget>[
            TextButton(
              child: Text('playlist.cancel'.tr()),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('playlist.delete'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
        _showSnackBar('playlist.deleted'.tr(namedArgs: {'name': playlistName}));
        widget.onPlaylistsUpdated?.call();
      } catch (e) {
        _showSnackBar(
            'playlist.errorDeleting'.tr(namedArgs: {'error': e.toString()}));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          widget.songsToAdd != null
              ? 'playlist.addTo'.tr()
              : 'playlist.manage'.tr(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
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
                    label: Text('playlist.createNew'.tr()),
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(50), // Make button wider
                    ),
                  ),
                ),
                Expanded(
                  child: _userPlaylists.isEmpty
                      ? Center(
                          child: Text(
                            'playlist.noneFound'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
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
                                subtitle: Text('playlist.songCount'.tr(
                                    namedArgs: {
                                      'count': playlist.songs.length.toString()
                                    })),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.songsToAdd != null)
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () =>
                                            _addSongToExistingPlaylist(
                                                playlist),
                                        tooltip: 'playlist.addSongTooltip'.tr(),
                                      ),
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
                                      onPressed: () =>
                                          _deletePlaylist(playlist.name),
                                      tooltip: 'playlist.deleteTooltip'.tr(),
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
