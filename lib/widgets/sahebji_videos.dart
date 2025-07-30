import 'dart:async';

import 'package:anoopam_mission/Views/Video/models/video.dart';
import 'package:anoopam_mission/Views/Video/providers/watch_history_provider.dart';
// import 'package:anoopam_mission/Views/Video/screens/video_player_screen.dart'; // REMOVE or COMMENT OUT if not needed for details
import 'package:anoopam_mission/Views/Video/services/youtube_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // NEW: Import url_launcher

class SahebjiVideosSection extends StatefulWidget {
  const SahebjiVideosSection({super.key});

  @override
  State<SahebjiVideosSection> createState() => _SahebjiVideosSectionState();
}

class _SahebjiVideosSectionState extends State<SahebjiVideosSection> {
  late YouTubeService _youtubeService;
  List<Video> _videos = [];
  List<Video> _filteredVideos = [];
  Video? _recentlyWatchedVideo;
  List<Video> _suggestedVideos = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String? _nextPageToken;
  bool _isLoadingMore = false;
  Timer? _autoRefreshTimer;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print("=== HOMESCREEN INIT ===");
    _youtubeService = YouTubeService(
      apiKey: dotenv.env['YOUTUBE_API_KEY'] ?? '',
      channelId: dotenv.env['YOUTUBE_CHANNEL_ID'] ?? '',
    );
    print("YouTubeService created with:");
    print("API Key: ${_youtubeService.apiKey.isNotEmpty ? 'YES' : 'NO'}");
    print("Channel ID: ${_youtubeService.channelId}");
    print("=======================");

    _fetchVideos();
    _setupAutoRefresh();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAutoRefresh() {
    // Auto-refresh every 5 minutes
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted && _searchQuery.isEmpty) {
        _fetchVideos();
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreVideos();
      }
    });
  }

  Future<void> _fetchVideos({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });
    }

    try {
      print("=== FETCHING VIDEOS ===");
      print("Starting API call...");
      final result = await _youtubeService.getVideos();
      print("API call completed successfully!");
      print("Fetched ${result.videos.length} videos");

      if (mounted) {
        setState(() {
          _videos = result.videos;
          _filteredVideos = _videos;
          _nextPageToken = result.nextPageToken;
          _recentlyWatchedVideo = _videos.isNotEmpty ? _videos.first : null;
          _suggestedVideos = _videos.skip(1).take(3).toList();
          _isLoading = false;
          _hasError = false;
        });
        print("State updated, loading set to false");
      }
      print("=====================");
    } catch (e) {
      print("=== API ERROR ===");
      print('Error fetching videos: $e');
      print("=================");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().contains('Network')
              ? 'No internet connection. Please check your network and try again.'
              : 'Failed to load videos. Please try again.';
        });
        print("Error state set, loading set to false");
      }
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore || _nextPageToken == null || _searchQuery.isNotEmpty) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await _youtubeService.getVideos(
        nextPageToken: _nextPageToken,
      );

      if (mounted) {
        setState(() {
          _videos.addAll(result.videos);
          _filteredVideos = _videos;
          _nextPageToken = result.nextPageToken;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _searchVideos(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _filteredVideos = _videos;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final result = await _youtubeService.searchVideos(query: query);

      if (mounted) {
        setState(() {
          _filteredVideos = result.videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to search videos. Please try again.';
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filteredVideos = _videos;
    });
  }

  // MODIFIED: This function now directly launches the video externally
  void _launchVideoExternally(Video video) async {
    // Correct YouTube video URL format
    final url = Uri.parse('https://www.youtube.com/watch?v=${video.videoId}');

    try {
      // Add to watch history immediately
      context.read<WatchHistoryProvider>().addToHistory(video);

      if (await canLaunchUrl(url)) {
        await launchUrl(url,
            mode: LaunchMode
                .externalApplication); // Use external application mode
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open video: ${video.title}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error launching video externally: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to launch video: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                image: AssetImage('assets/icons/videos.png'),
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Text(
                'menu.sahebjiVideos'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Content
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    strokeWidth: 20,
                  ))
                : _hasError
                    ? _buildErrorWidget()
                    : _buildContentWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _fetchVideos(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    return RefreshIndicator(
      onRefresh: () => _fetchVideos(isRefresh: true),
      child: ListView(
        controller: _scrollController,
        scrollDirection:
            Axis.horizontal, // Set the scroll direction to horizontal

        children: [
          // Video List
          ..._filteredVideos.map((video) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 250, // Set a fixed width for the card
                  child: VideoCard(
                    video: video,
                    // MODIFIED: Pass the new launch function directly
                    onTap: () => _launchVideoExternally(video),
                  ),
                ),
              )),
          // Loading more indicator
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// NO CHANGES NEEDED IN VIDEOCARD IF SahebjiVideosSection ALWAYS PASSES onTap
// However, for robustness if VideoCard is used elsewhere, you could update its internal fallback.
class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback? onTap; // This onTap is passed from SahebjiVideosSection

  const VideoCard({
    Key? key,
    required this.video,
    this.onTap,
  }) : super(key: key);

  // OPTIONAL: Update this internal function for consistency if VideoCard is used without an onTap from parent
  void _launchVideoExternallyFallback(BuildContext context) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=${video.videoId}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open YouTube.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error launching video externally from VideoCard fallback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to open video.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // The onTap from SahebjiVideosSection will be used first.
      // If onTap is null (e.g., if VideoCard is used directly without a parent onTap),
      // then _launchVideoExternallyFallback will be used.
      onTap: onTap ?? () => _launchVideoExternallyFallback(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(video.thumbnailUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Play button overlay (visual only, InkWell handles the tap)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // Video name at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
