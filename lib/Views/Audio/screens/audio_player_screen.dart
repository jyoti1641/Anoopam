// // lib/Views/Audio/screens/audio_player_screen.dart (Consolidated)
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';

// // --- Mock Model Classes (Replace with your actual models) ---
// class AlbumModels {
//   final String id;
//   final String title;
//   final String artist;
//   final String albumArt;

//   AlbumModels({
//     required this.id,
//     required this.title,
//     required this.artist,
//     required this.albumArt,
//   });
// }

// class AudioModel {
//   final String id;
//   final String title;
//   final String artist;
//   final String audioUrl;
//   final String albumArt;
//   final int? durationInSeconds; // Add duration for better mock

//   AudioModel({
//     required this.id,
//     required this.title,
//     required this.artist,
//     required this.audioUrl,
//     required this.albumArt,
//     this.durationInSeconds,
//   });
// }

// // --- Mock Service Classes (Replace with your actual services) ---
// class ApiService {
//   Future<List<AudioModel>> getSongsByAlbum(String albumId) async {
//     // Mock API call - replace with actual data fetching from your backend
//     await Future.delayed(const Duration(seconds: 1));
//     return [
//       AudioModel(
//           id: 's1',
//           title: 'Aavahan Stuti Shlok',
//           artist: 'Sadguru Sant Pujya Achintbhai',
//           audioUrl: 'http://example.com/audio1.mp3',
//           albumArt:
//               'https://placehold.co/400x400/FF5733/FFFFFF?text=Album+Art+1',
//           durationInSeconds: 280),
//       AudioModel(
//           id: 's2',
//           title: 'Song 2 from Album',
//           artist: 'Album Artist',
//           audioUrl: 'http://example.com/audio2.mp3',
//           albumArt:
//               'https://placehold.co/400x400/33FF57/FFFFFF?text=Album+Art+2',
//           durationInSeconds: 200),
//       AudioModel(
//           id: 's3',
//           title: 'Another Song Title',
//           artist: 'Album Artist',
//           audioUrl: 'http://example.com/audio3.mp3',
//           albumArt:
//               'https://placehold.co/400x400/3357FF/FFFFFF?text=Album+Art+3',
//           durationInSeconds: 320),
//       // Add more mock songs as needed
//     ];
//   }
// }

// class AudioServiceNew {
//   // Singleton pattern
//   static final AudioServiceNew _instance = AudioServiceNew._internal();
//   factory AudioServiceNew() => _instance;
//   AudioServiceNew._internal();

//   static AudioServiceNew get instance => _instance;

//   // This method would typically load and play audio from a URL.
//   // In a real app, you'd use a package like 'just_audio'.
//   void playUri(String audioUrl) {
//     print('AudioServiceNew: Playing song from URL: $audioUrl');
//     // Example with 'just_audio':
//     // _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
//     // _audioPlayer.play();
//   }

//   void pause() {
//     print('AudioServiceNew: Pausing audio');
//     // _audioPlayer.pause();
//   }

//   void resume() {
//     print('AudioServiceNew: Resuming audio');
//     // _audioPlayer.play();
//   }

//   void seek(Duration position) {
//     print('AudioServiceNew: Seeking to $position');
//     // _audioPlayer.seek(position);
//   }

//   // In a real audio service, you would expose streams for playback state,
//   // current position, and total duration.
//   // Example for 'just_audio':
//   // Stream<Duration?> get durationStream => _audioPlayer.durationStream;
//   // Stream<Duration> get positionStream => _audioPlayer.positionStream;
//   // Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
// }

// class AlbumServiceNew {
//   // Singleton pattern
//   static final AlbumServiceNew _instance = AlbumServiceNew._internal();
//   factory AlbumServiceNew() => _instance;
//   AlbumServiceNew._internal();

//   static AlbumServiceNew get instance => _instance;

//   void startPlaylist(List<AudioModel> songs) {
//     print('AlbumServiceNew: Starting playlist with ${songs.length} songs');
//     // In a real app, this would delegate to AudioServiceNew
//     if (songs.isNotEmpty) {
//       AudioServiceNew.instance.playUri(songs.first.audioUrl);
//     }
//   }
// }

// class PlaylistService {
//   void addSongsToPlaylist(List<AudioModel> songs) {
//     print('PlaylistService: Adding ${songs.length} songs to playlist');
//   }
// }

// // --- Main AudioPlayerScreen Widget ---
// class AudioPlayerScreen extends StatefulWidget {
//   final List<AudioModel> songs;
//   final int initialIndex;

//   const AudioPlayerScreen({
//     super.key,
//     required this.songs,
//     this.initialIndex = 0,
//   });

//   @override
//   State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   late int _currentSongIndex;
//   bool _isPlaying = false;
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration.zero;
//   bool _isShuffle = false;
//   bool _isRepeat = false;

//   final AudioServiceNew _audioService = AudioServiceNew.instance;

//   @override
//   void initState() {
//     super.initState();
//     _currentSongIndex = widget.initialIndex;
//     _loadSong();
//     _listenToAudioService();
//   }

//   @override
//   void dispose() {
//     // In a real app, you would dispose of audio service listeners here.
//     super.dispose();
//   }

//   void _listenToAudioService() {
//     // This method would subscribe to streams from your actual AudioServiceNew
//     // to get real-time updates on playback position, duration, and state.
//     // The current implementation uses a mock Future.delayed for demonstration.

//     // Example of how you would listen to duration (if AudioServiceNew provided it):
//     // _audioService.durationStream.listen((duration) {
//     //   if (mounted && duration != null) {
//     //     setState(() {
//     //       _totalDuration = duration;
//     //     });
//     //   }
//     // });

//     // Example of how you would listen to current position:
//     // _audioService.positionStream.listen((position) {
//     //   if (mounted) {
//     //     setState(() {
//     //       _currentPosition = position;
//     //     });
//     //   }
//     // });

//     // Example of how you would listen to playback state:
//     // _audioService.playerStateStream.listen((playerState) {
//     //   if (mounted) {
//     //     setState(() {
//     //       _isPlaying = playerState.playing; // Assuming 'playing' property exists
//     //     });
//     //   }
//     // });

//     // Mock duration and progress for demonstration
//     if (widget.songs.isNotEmpty) {
//       final currentSong = widget.songs[_currentSongIndex];
//       _totalDuration =
//           Duration(seconds: (currentSong.durationInSeconds ?? 280));
//     }
//     _simulatePlaybackProgress();
//   }

//   void _loadSong() {
//     if (widget.songs.isNotEmpty) {
//       final currentSong = widget.songs[_currentSongIndex];
//       _audioService.playUri(currentSong.audioUrl);

//       setState(() {
//         _isPlaying = true;
//         _currentPosition = Duration.zero;
//         _totalDuration =
//             Duration(seconds: (currentSong.durationInSeconds ?? 280));
//       });
//       // Restart simulation of playback progress for the new song
//       _simulatePlaybackProgress();
//     } else {
//       setState(() {
//         _isPlaying = false;
//         _currentPosition = Duration.zero;
//         _totalDuration = Duration.zero;
//       });
//     }
//   }

//   void _simulatePlaybackProgress() async {
//     // This is a simplified mock. In a real app, your AudioServiceNew
//     // would handle the actual audio playback and expose its progress.
//     while (_isPlaying && _currentPosition < _totalDuration) {
//       await Future.delayed(const Duration(seconds: 1));
//       if (mounted && _isPlaying) {
//         setState(() {
//           _currentPosition += const Duration(seconds: 1);
//           if (_currentPosition >= _totalDuration) {
//             _currentPosition = _totalDuration; // Cap at total duration
//             _isPlaying = false; // Stop playback
//             _playNextSong(); // Automatically advance to the next song
//           }
//         });
//       }
//     }
//   }

//   void _togglePlayPause() {
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//     if (_isPlaying) {
//       _audioService.resume();
//       _simulatePlaybackProgress(); // Continue simulation if playing
//     } else {
//       _audioService.pause();
//     }
//   }

//   void _playNextSong() {
//     if (widget.songs.isEmpty) return;

//     if (_isRepeat) {
//       _loadSong(); // Replay current song
//     } else {
//       setState(() {
//         _currentSongIndex = (_currentSongIndex + 1) % widget.songs.length;
//       });
//       _loadSong();
//     }
//   }

//   void _playPreviousSong() {
//     if (widget.songs.isEmpty) return;
//     setState(() {
//       _currentSongIndex =
//           (_currentSongIndex - 1 + widget.songs.length) % widget.songs.length;
//     });
//     _loadSong();
//   }

//   void _toggleShuffle() {
//     setState(() {
//       _isShuffle = !_isShuffle;
//       // In a real app, you would reorder the playlist in your audio service
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Shuffle: ${_isShuffle ? 'On' : 'Off'}')),
//       );
//     });
//   }

//   void _toggleRepeat() {
//     setState(() {
//       _isRepeat = !_isRepeat;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Repeat: ${_isRepeat ? 'On' : 'Off'}')),
//       );
//     });
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }

//   void _shareSong() {
//     final currentSong = widget.songs[_currentSongIndex];
//     Share.share(
//         'Listening to "${currentSong.title}" by ${currentSong.artist} on AnoopaMission!');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentSong =
//         widget.songs.isNotEmpty ? widget.songs[_currentSongIndex] : null;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Audio Playing Full View'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert),
//             onPressed: () {
//               // Implement more options menu (e.g., add to playlist, download)
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('More options coming soon!')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: currentSong == null
//           ? const Center(child: Text('No song selected.'))
//           : Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: 20,
//                   ),
//                   // Album Art
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(15.0),
//                     child: Image.network(
//                       currentSong.albumArt,
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       height: MediaQuery.of(context).size.width * 0.85,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           width: MediaQuery.of(context).size.width * 0.85,
//                           height: MediaQuery.of(context).size.width * 0.85,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(15.0),
//                           ),
//                           child: const Icon(Icons.album,
//                               size: 100, color: Colors.grey),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   // Song Title and Artist
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 currentSong.title,
//                                 style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 textAlign: TextAlign.left,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 currentSong.artist,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[700],
//                                 ),
//                                 textAlign: TextAlign.left,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Share button next to song info
//                         IconButton(
//                           icon: const Icon(Icons.share, size: 28),
//                           onPressed: _shareSong,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   // Seek Bar
//                   Column(
//                     children: [
//                       SliderTheme(
//                         data: SliderTheme.of(context).copyWith(
//                           trackHeight: 4.0,
//                           thumbShape: const RoundSliderThumbShape(
//                               enabledThumbRadius: 8.0),
//                           overlayShape: const RoundSliderOverlayShape(
//                               overlayRadius: 16.0),
//                           activeTrackColor: Theme.of(context).primaryColor,
//                           inactiveTrackColor: Colors.grey[300],
//                           thumbColor: Theme.of(context).primaryColor,
//                           overlayColor:
//                               Theme.of(context).primaryColor.withOpacity(0.2),
//                         ),
//                         child: Slider(
//                           value: _currentPosition.inSeconds.toDouble(),
//                           min: 0.0,
//                           max: _totalDuration.inSeconds.toDouble(),
//                           onChanged: (value) {
//                             setState(() {
//                               _currentPosition =
//                                   Duration(seconds: value.toInt());
//                             });
//                             // _audioService.seek(Duration(seconds: value.toInt())); // In a real app
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(_formatDuration(_currentPosition)),
//                             Text(_formatDuration(_totalDuration)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   // Playback Controls
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           Icons.shuffle,
//                           color: _isShuffle
//                               ? Theme.of(context).primaryColor
//                               : Colors.grey[600],
//                         ),
//                         iconSize: 28.0,
//                         onPressed: _toggleShuffle,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.skip_previous),
//                         iconSize: 48.0,
//                         onPressed: _playPreviousSong,
//                       ),
//                       Container(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                         child: IconButton(
//                           icon: Icon(
//                             _isPlaying ? Icons.pause : Icons.play_arrow,
//                             color: Colors.white,
//                           ),
//                           iconSize: 50.0,
//                           onPressed: _togglePlayPause,
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.skip_next),
//                         iconSize: 48.0,
//                         onPressed: _playNextSong,
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.repeat,
//                           color: _isRepeat
//                               ? Theme.of(context).primaryColor
//                               : Colors.grey[600],
//                         ),
//                         iconSize: 28.0,
//                         onPressed: _toggleRepeat,
//                       ),
//                     ],
//                   ),
//                   Spacer()
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, int index,
//       {bool isActive = false}) {
//     return GestureDetector(
//       onTap: () {
//         // Implement navigation logic here
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('$label tapped! (Navigation Placeholder)')),
//         );
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
//           ),
//           Text(
//             label,
//             style: TextStyle(
//               color:
//                   isActive ? Theme.of(context).primaryColor : Colors.grey[600],
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // --- Dummy SongList Widget (for AlbumDetailScreen to use if needed) ---
// // This widget is primarily for the AlbumDetailScreen, but included here
// // for completeness in a single file if you were to paste everything.
// // In a real app, this would be in its own file: lib/Views/Audio/widgets/song_list_new.dart
// class SongList extends StatelessWidget {
//   final List<AudioModel> songs;
//   final bool showActionButtons;
//   final bool showAlbumArt;
//   final PlaylistService playlistService;
//   final Function(int)? onSongTap;

//   const SongList({
//     super.key,
//     required this.songs,
//     this.showActionButtons = false,
//     this.showAlbumArt = false,
//     required this.playlistService,
//     this.onSongTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: songs.length,
//       itemBuilder: (context, index) {
//         final song = songs[index];
//         return ListTile(
//           leading: showAlbumArt
//               ? ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.network(
//                     song.albumArt,
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         width: 50,
//                         height: 50,
//                         color: Colors.grey[200],
//                         child: const Icon(Icons.music_note, color: Colors.grey),
//                       );
//                     },
//                   ),
//                 )
//               : null,
//           title: Text(song.title),
//           subtitle: Text(song.artist),
//           trailing: showActionButtons
//               ? Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.playlist_add),
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content:
//                                   Text('Added "${song.title}" to playlist')),
//                         );
//                         playlistService.addSongsToPlaylist([song]);
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.more_vert),
//                       onPressed: () {
//                         // Implement song-specific menu
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content:
//                                   Text('More options for "${song.title}"')),
//                         );
//                       },
//                     ),
//                   ],
//                 )
//               : null,
//           onTap: () {
//             onSongTap?.call(index);
//           },
//         );
//       },
//     );
//   }
// }

// lib/Views/Audio/screens/audio_player_screen.dart
import 'package:anoopam_mission/Views/Audio/services/album_service_new.dart';
import 'package:flutter/material.dart';
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
    final durationInMilliseconds = _parseDuration(song.duration).inMilliseconds;

    return MediaItem(
      id: song.songUrl,
      title: song.title,
      artist: song.artist,
      artUri: Uri.tryParse(
          song.imageUrl), // Use tryParse for URLs that might be malformed
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
              _totalDuration =
                  _parseDuration(widget.songs[_currentSongIndex].duration);
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
                Uri.parse(song.songUrl),
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

      // Update total duration for the initially loaded song
      if (widget.songs.isNotEmpty &&
          widget.initialIndex < widget.songs.length) {
        setState(() {
          _totalDuration =
              _parseDuration(widget.songs[widget.initialIndex].duration);
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
        'Check out the song "${currentSong.title}" by ${currentSong.artist} on AnoopaMission! ${currentSong.songUrl}');
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
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
                      currentSong.imageUrl, // Using imageUrl from AudioModel
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              currentSong.artist,
                              style: TextStyle(
                                fontSize: 16,
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
                      ),
                      // Share button next to song info
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          size: 28,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: _shareSong,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Seek Bar
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4.0,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8.0),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16.0),
                          activeTrackColor: Theme.of(context).primaryColor,
                          inactiveTrackColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          thumbColor: Theme.of(context).primaryColor,
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
                        child: IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: _isShuffleEnabled
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                          ),
                          iconSize: 28.0,
                          onPressed: _toggleShuffle,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            Icons.skip_previous,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          iconSize: 48.0,
                          onPressed: _skipToPrevious,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
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
                          iconSize: 48.0,
                          onPressed: _skipToNext,
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            _loopMode == LoopMode.off
                                ? Icons.repeat
                                : _loopMode == LoopMode.all
                                    ? Icons.repeat_on
                                    : Icons
                                        .repeat_one_on, // repeat_one_on for LoopMode.one
                            color: _loopMode != LoopMode.off
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                          ),
                          iconSize: 28.0,
                          onPressed: _toggleRepeat,
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
