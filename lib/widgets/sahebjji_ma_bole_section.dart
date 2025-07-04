import 'package:flutter/material.dart';
import 'package:anoopam_mission/models/audio_item.dart';
import 'package:anoopam_mission/services/api_service.dart';
import 'package:anoopam_mission/widgets/content_card.dart';
import 'package:just_audio/just_audio.dart'; // Import just_audio
import 'package:easy_localization/easy_localization.dart';

class SahebjjiMaBoleSection extends StatefulWidget {
  const SahebjjiMaBoleSection({super.key});

  @override
  State<SahebjjiMaBoleSection> createState() => _SahebjjiMaBoleSectionState();
}

class _SahebjjiMaBoleSectionState extends State<SahebjjiMaBoleSection> {
  late Future<List<AudioItem>> _audioItemsFuture;
  final ApiService _apiService = ApiService();
  late AudioPlayer _audioPlayer; // Audio player instance
  String?
      _currentPlayingAudioId; // To keep track of the currently playing audio
  bool _isPlaying = false; // To manage play/pause state for the current audio

  @override
  void initState() {
    super.initState();
    _audioItemsFuture = _apiService.fetchAudioItems();
    _audioPlayer = AudioPlayer(); // Initialize the audio player

    // Listen for player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.ready) {
        if (playerState.playing) {
          setState(() {
            _isPlaying = true;
          });
        } else {
          setState(() {
            _isPlaying = false;
          });
        }
      } else if (playerState.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _currentPlayingAudioId = null; // Reset when audio completes
        });
      } else if (playerState.processingState == ProcessingState.idle) {
        setState(() {
          _isPlaying = false;
          _currentPlayingAudioId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Release resources when the widget is removed
    super.dispose();
  }

  void _playAudio(String audioUrl, String audioId) async {
    try {
      if (_currentPlayingAudioId == audioId) {
        // If the same audio is tapped, toggle play/pause
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play();
        }
      } else {
        // If a different audio is tapped, stop current and play new
        await _audioPlayer.stop();
        setState(() {
          _currentPlayingAudioId = audioId;
          _isPlaying =
              false; // Set to false initially, will be true when playback starts
        });
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
      }
    } catch (e) {
      print("Error playing audio: $e");
      // Optionally show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('errors.errorPlayingAudio'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Image(
                image: AssetImage('assets/icons/enlighten.png'),
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Text(
                'menu.sahebjjiMaBole'.tr(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          FutureBuilder<List<AudioItem>>(
            future: _audioItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SizedBox(
                  height: 140,
                  child: Center(
                      child: Text(
                          'Error: Failed to Fetch the Data, Make Sure You Have Stable Internet Connection and Try Again by Restarting the App!'
                              .tr())),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: 140,
                  child: Center(child: Text('errors.noAudioItemsFound'.tr())),
                );
              } else {
                final List<AudioItem> audioItems = snapshot.data!;
                return SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: audioItems.length,
                    itemBuilder: (context, index) {
                      final AudioItem audioItem = audioItems[index];

                      String displayDate = '';
                      String displayTitle = audioItem.audioTitle;

                      if (audioItem.audioTitle.contains(' - ')) {
                        final parts = audioItem.audioTitle.split(' - ');
                        if (parts.isNotEmpty) {
                          displayDate = parts[0].trim();
                        }
                        if (parts.length > 1) {
                          displayTitle = parts.sublist(1).join(' - ').trim();
                        }
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: SizedBox(
                          width: 360,
                          child: ContentCard(
                            imageUrl: audioItem.imageUrl,
                            date: displayDate,
                            title: displayTitle,
                            duration: audioItem.duration,
                            isPlaying:
                                _currentPlayingAudioId == audioItem.audioID &&
                                    _isPlaying, // Pass playing state
                            onPlay: () {
                              _playAudio(audioItem.audioURL,
                                  audioItem.audioID); // Pass audio URL and ID
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
