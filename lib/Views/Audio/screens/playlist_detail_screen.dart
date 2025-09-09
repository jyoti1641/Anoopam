// lib/Views/Audio/screens/playlist_detail_screen.dart

import 'dart:io';

import 'package:anoopam_mission/Views/Audio/models/song.dart';
import 'package:anoopam_mission/Views/Audio/screens/audio_player_screen.dart';
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:anoopam_mission/Views/Audio/widgets/playlist_song_list.dart';
import 'package:flutter/material.dart';
import 'package:anoopam_mission/Views/Audio/models/playlist.dart';
import 'package:easy_localization/easy_localization.dart';
// Assuming `AlbumDetailScreen` needs to be imported to handle navigation
import 'package:anoopam_mission/Views/Audio/screens/album_detail_screen.dart';
import 'package:anoopam_mission/Views/Audio/models/album.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  final VoidCallback onPlaylistUpdated;

  const PlaylistDetailScreen({
    super.key,
    required this.playlist,
    required this.onPlaylistUpdated,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  // Use a nullable Playlist to show a loading indicator initially
  Playlist? _currentPlaylist;
  final PlaylistService _playlistService = PlaylistService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isEditMode = false;
  bool _isSaving = false;
  File? _newImageFile;
  bool _hasDescription = false;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
    _nameController.text = widget.playlist.name;
    _descriptionController.text = widget.playlist.description ?? '';
    _hasDescription = widget.playlist.description != null &&
        widget.playlist.description!.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // This method fetches the latest playlist data from the service.
  Future<void> _loadPlaylist() async {
    final updatedPlaylist =
        await _playlistService.getPlaylist(widget.playlist.name);
    setState(() {
      _currentPlaylist = updatedPlaylist;
    });
    // This callback is for the parent screen (PlaylistManagerPage).
    widget.onPlaylistUpdated();
  }

  // This method will be called to trigger a rebuild when the song list changes.
  void _onSongsChanged() {
    _loadPlaylist(); // Re-fetch the playlist to get the updated list
  }

  void _playAllSongs(BuildContext context, List<AudioModel> songs) {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('album.noSongsToPlay'.tr())),
      );
      return;
    }
    AlbumServiceNew.instance.startPlaylist(songs);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('album.startingPlayback'
              .tr(namedArgs: {'title': widget.playlist.name}))),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(songs: songs, initialIndex: 0),
      ),
    );
  }

  void _showPlaylistMenu(BuildContext context) {
    if (_currentPlaylist == null) return;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with playlist image and title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      _currentPlaylist!.coverImageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.music_note, size: 50),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPlaylist!.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_currentPlaylist!.songs.length} songs',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Download option
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () async {
                Navigator.pop(context);
                await _downloadPlaylist();
              },
            ),
            // Add to Other Playlist option
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Other Playlist'),
              onTap: () {
                Navigator.pop(context);
                _addSongsToPlaylist(_currentPlaylist!.songs);
              },
            ),
            // Edit Playlist option
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Playlist'),
              onTap: () {
                Navigator.pop(context);
                // Call a new method to handle editing
                _editPlaylist();
              },
            ),
            // Delete Playlist option
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Playlist'),
              onTap: () async {
                Navigator.pop(context);
                await _deletePlaylist(_currentPlaylist!.name);
              },
            ),
            // Share option
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _sharePlaylist(_currentPlaylist!.songs);
              },
            ),
          ],
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: true,
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      // Reset controllers when exiting edit mode without saving
      if (!_isEditMode) {
        _nameController.text = _currentPlaylist!.name;
        _descriptionController.text = _currentPlaylist!.description ?? '';
        _newImageFile = null; // Clear the selected image
        _hasDescription = _currentPlaylist!.description != null &&
            _currentPlaylist!.description!.isNotEmpty;
      }
    });
  }

  // Method to handle playlist editing. This navigates to a new screen.
  void _editPlaylist() {
    _toggleEditMode();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newImageFile = File(image.path);
      });
    }
  }

  void _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Playlist name cannot be empty.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? newCoverImageUrl = _currentPlaylist!.coverImageUrl;

      // Check if a new image file has been selected
      if (_newImageFile != null) {
        // Save the new image locally and get its file path
        final savedImagePath =
            await _playlistService.saveImageLocally(_newImageFile!);
        if (savedImagePath != null) {
          newCoverImageUrl = savedImagePath;
        }
      }
      final updatedPlaylist = Playlist(
        name: _nameController.text.trim(),
        songs: _currentPlaylist!.songs,
        coverImageUrl: newCoverImageUrl,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      // Call the updated service method with the old name and the new image file.
      await _playlistService.updatePlaylist(
        oldName: widget.playlist.name,
        newPlaylist: updatedPlaylist,
        newImageFile: _newImageFile,
      );

      // After a successful save, update the state and reload the data.
      if (mounted) {
        _showSnackBar('Playlist updated successfully!');

        // We are no longer in edit mode and saving is complete.
        setState(() {
          _isEditMode = false;
          _isSaving = false;
          _newImageFile = null; // Clear the new image file after saving
        });

        Navigator.of(context).pop(true);

        widget.onPlaylistUpdated();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update playlist: $e');
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deletePlaylist(String playlistName) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Playlist'),
          content: Text('Are you sure you want to delete "$playlistName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      await _playlistService.deletePlaylist(playlistName);
      widget.onPlaylistUpdated();
      Navigator.of(context).pop(true);
    }
  }

  void _addSongsToPlaylist(List<AudioModel> songs) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistManagerPage(
          songsToAdd: songs,
          playlistService: _playlistService,
          onPlaylistsUpdated: () {
            // This callback is crucial for refreshing both parent screens
            _loadPlaylist();
            widget.onPlaylistUpdated();
          },
          albumCoverUrl: _currentPlaylist?.coverImageUrl,
        ),
      ),
    );
    if (result == true) {
      _loadPlaylist(); // Refresh when we come back
    }
  }

  Future<void> _downloadPlaylist() async {
    if (_currentPlaylist == null || _currentPlaylist!.songs.isEmpty) {
      _showSnackBar('No songs to download.');
      return;
    }
    var status = await Permission.storage.request();
    if (status.isDenied) {
      _showSnackBar('Storage permission is required.');
      return;
    }
    _showSnackBar('Downloading playlist...');

    for (var song in _currentPlaylist!.songs) {
      try {
        await _playlistService.downloadAndSaveSong(song);
        _showSnackBar('"${song.title}" downloaded.');
      } catch (e) {
        _showSnackBar('Error downloading "${song.title}": $e');
      }
    }
    _showSnackBar('All songs finished downloading.');
    // You should also reload your downloads screen after this
  }

  void _sharePlaylist(List<AudioModel> songs) {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot share an empty playlist.')),
      );
      return;
    }

    final String playlistName = _currentPlaylist!.name;
    String shareText = 'Playlist "$playlistName" shared with you!\n\n';

    shareText += 'Songs included:\n\n';

    // Add each song's title and URL to the message
    for (int i = 0; i < songs.length; i++) {
      shareText += '${i + 1}. ${songs[i].title}\n';
      shareText += '${songs[i].audioUrl}\n\n';
    }

    // Use the share_plus package to open the native share sheet
    Share.share(shareText,
        subject: 'Anoopam Mission Playlist: "$playlistName"');
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if the playlist data hasn't been fetched yet
    if (_currentPlaylist == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    ImageProvider<Object>? currentImageProvider;
    if (_newImageFile != null) {
      currentImageProvider = FileImage(_newImageFile!);
    } else if (_currentPlaylist!.coverImageUrl != null &&
        _currentPlaylist!.coverImageUrl!.isNotEmpty) {
      // Check if the URL is a local file path
      if (_currentPlaylist!.coverImageUrl!.startsWith('http') == false) {
        currentImageProvider =
            FileImage(File(_currentPlaylist!.coverImageUrl!));
      } else {
        currentImageProvider = NetworkImage(_currentPlaylist!.coverImageUrl!);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: _isEditMode ? const Text('Edit Playlist') : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isEditMode) {
              _toggleEditMode();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (_isEditMode)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[500],
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 14),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5)),
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Playlist'),
                      content: Text(
                          'Are you sure you want to delete "${widget.playlist.name}"?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
                if (confirmDelete == true) {
                  await _playlistService.deletePlaylist(widget.playlist.name);
                  widget.onPlaylistUpdated();
                  Navigator.of(context).pop(true); // pop with a result
                }
              },
            ),
        ],
      ),
      body: _currentPlaylist!.songs.isEmpty
          ? Center(
              child: Text(
                'This playlist is empty. Add some songs!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          : RefreshIndicator(
              // Added RefreshIndicator here
              onRefresh: _loadPlaylist,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 10),
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: currentImageProvider != null
                            ? DecorationImage(
                                image: currentImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: currentImageProvider == null
                            ? Theme.of(context).colorScheme.surfaceVariant
                            : null,
                      ),
                      child: currentImageProvider == null
                          ? Center(
                              child: Icon(
                                Icons.audiotrack,
                                size: 50,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            )
                          : null,
                    ),
                  ),
                  // const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 17),
                    child: _isEditMode
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const SizedBox(height: 20),
                              Center(
                                child: TextButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.indigo,
                                  ),
                                  label: const Text(
                                    'Change Image',
                                    style: TextStyle(color: Colors.indigo),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   height: 10,
                              // ),
                              Center(
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: _nameController,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: _hasDescription
                                    ? TextField(
                                        controller: _descriptionController,
                                        decoration: const InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 5, horizontal: 5),
                                          hintText: 'Playlist Description',
                                          border: UnderlineInputBorder(),
                                        ),
                                        // maxLines: 2,
                                      )
                                    : Center(
                                        child: TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                OutlinedBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.0),
                                                  side: BorderSide(
                                                      color: Colors.indigo)),
                                            ),
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _hasDescription = true;
                                            });
                                          },
                                          child: const Text(
                                            'Add Description',
                                            style:
                                                TextStyle(color: Colors.indigo),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _currentPlaylist!.description != null
                                  ? Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _currentPlaylist!.name,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            _currentPlaylist!.description!,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              // fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    )
                                  : Expanded(
                                      child: Text(
                                        _currentPlaylist!.name,
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.more_vert_outlined),
                                    color: Colors.black,
                                    iconSize: 30.0,
                                    onPressed: () {
                                      _showPlaylistMenu(context);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_fill),
                                    color: Colors.indigo,
                                    iconSize: 40.0,
                                    onPressed: () => _playAllSongs(
                                        context, _currentPlaylist!.songs),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  PlaylistSongList(
                    songs: _currentPlaylist!.songs,
                    playlistService: _playlistService,
                    playlist: _currentPlaylist!,
                    onFavoritesUpdated: _onSongsChanged,
                    onSongTap: (int tappedIndex) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioPlayerScreen(
                            songs: _currentPlaylist!.songs,
                            initialIndex: tappedIndex,
                          ),
                        ),
                      );
                    },
                    isEditMode: _isEditMode,
                  ),
                ],
              ),
            ),
    );
  }

  void _showSnackBar(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
