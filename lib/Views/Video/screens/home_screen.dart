import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/youtube_service.dart';
import '../widgets/video_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/section_title.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/video.dart';
import '../providers/watch_history_provider.dart';
import '../providers/favorites_provider.dart';
import 'favorites_screen.dart';
import 'watch_history_screen.dart';

import 'video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => FavoritesProvider()),
                    ChangeNotifierProvider(
                        create: (_) => WatchHistoryProvider()),
                  ],
                  child: const FavoritesScreen(),
                ),
              ),
            ),
            tooltip: 'Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(create: (_) => FavoritesProvider()),
                    ChangeNotifierProvider(
                        create: (_) => WatchHistoryProvider()),
                  ],
                  child: const WatchHistoryScreen(),
                ),
              ),
            ),
            tooltip: 'Watch History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search videos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: _searchVideos,
              onChanged: (value) {
                if (value.isEmpty) {
                  _clearSearch();
                }
              },
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const ShimmerLoader()
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
        padding: const EdgeInsets.all(16),
        children: [
          if (_searchQuery.isEmpty) ...[
            // Recently Watched Section
            if (_recentlyWatchedVideo != null) ...[
              const SectionTitle(title: 'Recently Watched'),
              VideoCard(
                video: _recentlyWatchedVideo!,
                onTap: () => _navigateToVideoPlayer(_recentlyWatchedVideo!),
              ),
            ],

            // Suggested Videos Section
            if (_suggestedVideos.isNotEmpty) ...[
              const SectionTitle(title: 'Suggested Videos'),
              ..._suggestedVideos.map((video) => VideoCard(
                    video: video,
                    onTap: () => _navigateToVideoPlayer(video),
                  )),
            ],

            // All Videos Section
            if (_filteredVideos.isNotEmpty) ...[
              const SectionTitle(title: 'All Videos'),
            ],
          ] else ...[
            // Search Results
            Text(
              'Search Results for "$_searchQuery"',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
          ],

          // Video List
          ..._filteredVideos.map((video) => VideoCard(
                video: video,
                onTap: () => _navigateToVideoPlayer(video),
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
}
