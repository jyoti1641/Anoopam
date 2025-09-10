// lib/Views/Audio/screens/audio_player_screen.dart
import 'package:anoopam_mission/Views/Audio/screens/playlist_manager.dart';
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:anoopam_mission/Views/Audio/services/playlist_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart'; // For AudioPlayer, ProcessingState, LoopMode, ShuffleMode

// Assuming these models and services are correctly imported from their paths
import 'package:anoopam_mission/Views/Audio/models/song.dart'; // Your AudioModel

class AudioPlayerScreen extends StatefulWidget {
  final List<AudioModel> songs;
  final int initialIndex;

  const AudioPlayerScreen({
    super.key,
    required this.songs,
    this.initialIndex = 0,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  // Reference to your centralized audio service
  final AlbumServiceNew _audioService = AlbumServiceNew.instance;
  late AudioPlayer
      _audioPlayer; // Direct reference to just_audio player from the service
  final PlaylistService _playlistService = PlaylistService();

  // Playback state variables
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  int _currentSongIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off; // just_audio's loop mode enum

  @override
  void initState() {
    super.initState();
    _audioPlayer = _audioService.audioPlayer; // Get the player instance

    // Initialize current song index (if starting fresh or resuming playlist)
    _currentSongIndex = widget.initialIndex;

    _setupAudioPlayerListeners();
    _initializePlaylistAndPlay();
  }

  @override
  void dispose() {
    // No need to dispose _audioPlayer here, as it's managed by AlbumServiceNew.
    super.dispose();
  }

  // Method to parse "mm:ss" duration string into Duration object
  Duration _parseDuration(String durationString) {
    if (durationString.isEmpty) return Duration.zero;
    try {
      final parts = durationString.split(':');
      if (parts.length == 2) {
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return Duration(minutes: minutes, seconds: seconds);
      }
    } catch (e) {
      debugPrint('Error parsing duration string "$durationString": $e');
    }
    return Duration.zero;
  }

  // Method to format Duration object into "mm:ss" string
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Helper to create a MediaItem from an AudioModel for just_audio_background
  MediaItem _createMediaItem(AudioModel song) {
    final durationInMilliseconds =
        _parseDuration(song.audioDuration ?? '').inMilliseconds;

    return MediaItem(
      id: song.audioUrl,
      title: song.title,
      artist: song.artist,
      // Use tryParse for URLs that might be malformed
      album: song
          .artist, // Using artist as a fallback for album, as AudioModel doesn't have album title
      duration: Duration(milliseconds: durationInMilliseconds),
    );
  }

  void _setupAudioPlayerListeners() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          _isPlaying = playerState.playing;
          // You might want to react to playerState.processingState (loading, buffering, ready, etc.)
          // for more granular UI feedback like showing a loading spinner.
        });
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position ?? Duration.zero;
        });
      }
    });

    // Listen to total duration changes (might update when a new song loads)
    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      }
    });

    // Listen to current song index changes in the playlist
    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (mounted) {
        setState(() {
          if (sequenceState != null &&
              sequenceState.currentIndex != _currentSongIndex) {
            _currentSongIndex = sequenceState.currentIndex;
            // Optionally, update duration when a new song starts playing in the playlist
            if (widget.songs.isNotEmpty &&
                _currentSongIndex < widget.songs.length) {
              _totalDuration = _parseDuration(
                  widget.songs[_currentSongIndex].audioDuration ?? '');
              _playlistService.saveSong(
                widget.songs[_currentSongIndex],
                widget.songs[_currentSongIndex].albumCoverUrl!,
              );
            }
          }
        });
      }
    });

    // Listen to loop mode changes
    _audioPlayer.loopModeStream.listen((loopMode) {
      if (mounted) {
        setState(() {
          _loopMode = loopMode;
        });
      }
    });

    // Listen to shuffle mode changes
    _audioPlayer.shuffleModeEnabledStream.listen((isEnabled) {
      if (mounted) {
        setState(() {
          _isShuffleEnabled = isEnabled;
        });
      }
    });
  }

  void _initializePlaylistAndPlay() async {
    if (widget.songs.isEmpty) {
      debugPrint('No songs to initialize playlist.');
      return;
    }

    try {
      // Create an AudioSource for each song in the playlist, now with MediaItem tag
      final audioSources = widget.songs
          .map((song) => AudioSource.uri(
                Uri.parse(song.audioUrl),
                tag: _createMediaItem(
                    song), // Crucial fix: setting MediaItem tag
              ))
          .toList();

      final playlist = ConcatenatingAudioSource(children: audioSources);

      // Set the audio source for the player.
      // This will reset the player and load the new playlist.
      await _audioPlayer.setAudioSource(playlist,
          initialIndex: widget.initialIndex, initialPosition: Duration.zero);

      // If playing the "Play All" button, it should start immediately.
      // If coming from tapping a song in SongList, it also starts.
      _audioPlayer.play();
      _playlistService.saveSong(
        widget.songs[widget.initialIndex],
        widget.songs[widget.initialIndex].albumCoverUrl!,
      );

      // Update total duration for the initially loaded song
      if (widget.songs.isNotEmpty &&
          widget.initialIndex < widget.songs.length) {
        setState(() {
          _totalDuration = _parseDuration(
              widget.songs[widget.initialIndex].audioDuration ?? '');
        });
      }
    } catch (e) {
      debugPrint("Error loading audio source: $e");
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading audio: ${e.toString()}')),
      );
    }
  }

  void _togglePlayPause() async {
    if (_audioPlayer.playerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void _skipToNext() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    } else {
      // Handle end of playlist (e.g., loop back or stop)
      if (_loopMode == LoopMode.all) {
        await _audioPlayer.seek(Duration.zero, index: 0); // Loop to start
      } else if (_loopMode == LoopMode.off) {
        await _audioPlayer.stop(); // Stop playback
      }
    }
  }

  void _skipToPrevious() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    } else {
      // Handle start of playlist (e.g., loop back to end or stay)
      if (_loopMode == LoopMode.all) {
        await _audioPlayer.seek(Duration.zero,
            index: _audioPlayer.sequence!.length - 1); // Loop to end
      } else if (_loopMode == LoopMode.off) {
        await _audioPlayer.seek(Duration.zero); // Rewind current song
      }
    }
  }

  void _toggleShuffle() async {
    await _audioPlayer.setShuffleModeEnabled(!_isShuffleEnabled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shuffle: ${_isShuffleEnabled ? 'On' : 'Off'}')),
    );
  }

  void _addSongToPlaylist(AudioModel song, String coverimage) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistManagerPage(
          songsToAdd: [song],
          playlistService: _playlistService,
          onPlaylistsUpdated: () {},
          albumCoverUrl: coverimage,
        ),
      ),
    ).then((_) {
      // No need to call _initializeFavoriteStatus()
    });
  }

  void _toggleRepeat() async {
    // Cycle through LoopMode.off, LoopMode.all, LoopMode.one
    LoopMode newMode;
    if (_loopMode == LoopMode.off) {
      newMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      newMode = LoopMode.one;
    } else {
      newMode = LoopMode.off;
    }
    await _audioPlayer.setLoopMode(newMode);

    String message = '';
    if (newMode == LoopMode.off) message = 'Repeat: Off';
    if (newMode == LoopMode.all) message = 'Repeat: All';
    if (newMode == LoopMode.one) message = 'Repeat: One';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _shareSong() {
    final currentSong = widget.songs[_currentSongIndex];
    Share.share(
        'Check out the song "${currentSong.title}" by ${currentSong.artist} on AnoopaMission! ${currentSong.audioUrl}');
  }

  @override
  Widget build(BuildContext context) {
    final currentSong =
        widget.songs.isNotEmpty && _currentSongIndex < widget.songs.length
            ? widget.songs[_currentSongIndex]
            : null;

    // Determine if the player is currently loading/buffering.
    // This is useful for showing a spinner over the play/pause button.
    final bool isPlayerLoadingOrBuffering =
        _audioPlayer.playerState.processingState == ProcessingState.loading ||
            _audioPlayer.playerState.processingState ==
                ProcessingState.buffering;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xff034DA2),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Color(0xff034DA2),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: currentSong == null
          ? Center(
              child: Text(
                'No song selected or playlist is empty.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(
                      currentSong
                          .albumCoverUrl!, // Using imageUrl from AudioModel
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Icon(Icons.music_note,
                              size: 100,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Song Title and Artist
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  currentSong.artist ?? 'Unknown Artist',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  currentSong.audioDuration ?? '0.00',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Share button next to song info
                      GestureDetector(
                        child: SvgPicture.asset(
                          'assets/icons/circular_plus.svg',
                          height: 16,
                        ),
                        onTap: () {
                          _addSongToPlaylist(
                              currentSong, currentSong.albumCoverUrl!);
                        },
                      ),
                      // Share button next to song info
                      GestureDetector(
                        child: SvgPicture.asset(
                          'assets/icons/share_blue.svg',
                          height: 16,
                        ),
                        onTap: _shareSong,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Seek Bar
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.0,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5.0),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 5.0),
                          activeTrackColor: Color(0xff034DA2),
                          inactiveTrackColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          thumbColor: Color(0xff034DA2),
                          overlayColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _currentPosition.inSeconds.toDouble(),
                          min: 0.0,
                          max: _totalDuration.inSeconds.toDouble(),
                          onChanged: (value) {
                            // Seek to the new position
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Playback Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: SvgPicture.asset(
                            'assets/icons/playback.svg',
                            height: 20,
                            color: _loopMode != LoopMode.off
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          onTap: _toggleRepeat,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.skip_previous,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          iconSize: 40.0,
                          onPressed: _skipToPrevious,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff034DA2),
                        ),
                        child: isPlayerLoadingOrBuffering
                            ? const SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                iconSize: 50.0,
                                onPressed: _togglePlayPause,
                              ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.skip_next,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          iconSize: 40.0,
                          onPressed: _skipToNext,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: SvgPicture.asset(
                            'assets/icons/shuffle.svg',
                            height: 20,
                            color: _isShuffleEnabled
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          onTap: _toggleShuffle,
                        ),
                      ),
                    ],
                  ),
                  // Removed the bottom navigation bar here
                  const Spacer(), // Kept a spacer to push controls up if needed
                ],
              ),
            ),
    );
  }

  // The _buildNavItem method is no longer needed since the bottom navigation is removed.
  // Widget _buildNavItem(IconData icon, String label, int index, {bool isActive = false}) {
  //   return GestureDetector(
  //     onTap: () {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('$label tapped! (Navigation Placeholder)')),
  //       );
  //     },
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(
  //           icon,
  //           color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
  //         ),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
  //             fontSize: 12,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
