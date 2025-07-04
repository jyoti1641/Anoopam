import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../providers/watch_history_provider.dart';
import '../widgets/video_card.dart';
import '../widgets/shimmer_loader.dart';
import 'video_player_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class WatchHistoryScreen extends StatefulWidget {
  const WatchHistoryScreen({super.key});

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load watch history when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchHistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('history.title'.tr()),
        actions: [
          Consumer<WatchHistoryProvider>(
            builder: (context, historyProvider, child) {
              if (historyProvider.watchHistory.isNotEmpty) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'clear') {
                      _showClearHistoryDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all),
                          SizedBox(width: 8),
                          Text('history.clearHistory'.tr()),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<WatchHistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.isLoading) {
            return const ShimmerLoader();
          }

          if (historyProvider.watchHistory.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await historyProvider.loadHistory();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyProvider.watchHistory.length,
              itemBuilder: (context, index) {
                final video = historyProvider.watchHistory[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: VideoCard(
                    video: video,
                    onTap: () => _navigateToVideoPlayer(video),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeFromHistory(video.videoId),
                      tooltip: 'Remove from history',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'history.noWatchHistory'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'history.videosYouWatchAppearHere'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.play_arrow),
              label: Text('history.startWatching'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToVideoPlayer(Video video) {
    try {
      context.read<WatchHistoryProvider>().addToHistory(video);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(video: video),
        ),
      );
    } catch (e) {
      print('Error navigating to video player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open video: \\${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFromHistory(String videoId) {
    context.read<WatchHistoryProvider>().removeFromHistory(videoId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('history.removedFromHistory'.tr()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('history.clearWatchHistory'.tr()),
        content: Text('history.clearWatchHistoryConfirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('history.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              context.read<WatchHistoryProvider>().clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('history.watchHistoryCleared'.tr()),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
