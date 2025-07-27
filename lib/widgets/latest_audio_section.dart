import 'dart:async';

import 'package:anoopam_mission/models/audio_track.dart';
import 'package:anoopam_mission/services/api_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LatestAudioSection extends StatefulWidget {
  const LatestAudioSection({super.key});

  @override
  State<LatestAudioSection> createState() => _LatestAudioSectionState();
}

class _LatestAudioSectionState extends State<LatestAudioSection> {
  late Future<List<AudioTrack>> futureAudioTracks;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isLoading = false;
  bool isPlaying = false;
  int? currentPlayingIndex;
  late StreamSubscription<void> playerSubscription;

  @override
  void initState() {
    super.initState();
    futureAudioTracks = fetchAudioTracks();
    playerSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
          print('Player state changed: $state');
        });
      }
    });
  }

  @override
  void dispose() {
    playerSubscription.cancel(); // Cancel the subscription
    audioPlayer.dispose();
    super.dispose();
  }

  Duration parseDuration(String durationStr) {
    final parts = durationStr.split(':');
    if (parts.length != 2) {
      throw const FormatException('Invalid duration format');
    }
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  // Other methods remain the same

  Future<void> playAudio(String url, int index, String durationStr) async {
    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      isLoading = true;
      currentPlayingIndex = index;
    });

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries && mounted) {
      try {
        Duration duration = parseDuration(durationStr);
        await audioPlayer
            .play(UrlSource(url))
            .timeout(duration + const Duration(minutes: 10));
        break;
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed with error: $e');
        if (retryCount >= maxRetries) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Error playing audio after $maxRetries attempts: $e')),
            );
          }
        } else {
          await Future.delayed(const Duration(seconds: 5));
        }
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
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
                image: AssetImage('assets/icons/audios.png'),
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Text(
                'menu.latestAudio'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: FutureBuilder<List<AudioTrack>>(
              future: futureAudioTracks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      AudioTrack track = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          tileColor: Colors.blue.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          leading: Image.network(track.imageUrl),
                          title: Text(
                            track.title,
                            style: TextStyle(color: Colors.black),
                          ),
                          // subtitle: Text(track.artist),
                          trailing: IconButton(
                            icon: isLoading && currentPlayingIndex == index
                                ? const CircularProgressIndicator(
                                    color: Colors.black)
                                : Icon(
                                    isPlaying && currentPlayingIndex == index
                                        ? Icons.pause
                                        : Icons.play_circle,
                                    color: Colors.blue.shade800,
                                    size: 30,
                                  ),
                            onPressed: () {
                              if (isPlaying && currentPlayingIndex == index) {
                                audioPlayer.pause();
                                print('Audio paused'); // Debug print
                              } else {
                                playAudio(track.songUrl, index, track.duration);
                                print('Audio playing'); // Debug print
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
