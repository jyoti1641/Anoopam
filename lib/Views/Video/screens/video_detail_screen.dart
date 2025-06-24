import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../models/video.dart';
import '../providers/watch_history_provider.dart';
import 'package:provider/provider.dart';

class VideoDetailScreen extends StatefulWidget {
  final Video video;

  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add to watch history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WatchHistoryProvider>().addToHistory(widget.video);
    });
  }

  void _playVideo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure we have a valid video ID
      if (widget.video.videoId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid video ID'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Try different URL formats
      final List<String> urlFormats = [
        'https://www.youtube.com/watch?v=${widget.video.videoId}',
        'https://youtu.be/${widget.video.videoId}',
        'https://m.youtube.com/watch?v=${widget.video.videoId}',
      ];

      bool launched = false;
      String? lastError;

      for (String urlString in urlFormats) {
        try {
          final url = Uri.parse(urlString);
          
          // Check if URL can be launched
          if (await canLaunchUrl(url)) {
            // Try external application first (YouTube app or browser)
            try {
              await launchUrl(url, mode: LaunchMode.externalApplication);
              launched = true;
              break;
            } catch (e) {
              print('Failed to launch with external application: $e');
              lastError = e.toString();
            }
          }
        } catch (e) {
          print('Error parsing URL $urlString: $e');
          lastError = e.toString();
        }
      }

      // If external launch failed, try in-app browser
      if (!launched) {
        final url = Uri.parse('https://www.youtube.com/watch?v=${widget.video.videoId}');
        if (await canLaunchUrl(url)) {
          try {
            await launchUrl(url, mode: LaunchMode.inAppWebView);
            launched = true;
          } catch (e) {
            print('Failed to launch with in-app browser: $e');
            lastError = e.toString();
          }
        }
      }

      // If still not launched, try platform default
      if (!launched) {
        final url = Uri.parse('https://www.youtube.com/watch?v=${widget.video.videoId}');
        if (await canLaunchUrl(url)) {
          try {
            await launchUrl(url);
            launched = true;
          } catch (e) {
            print('Failed to launch with platform default: $e');
            lastError = e.toString();
          }
        }
      }

      if (!launched) {
        // Fallback: Copy URL to clipboard and show instructions
        final videoUrl = 'https://www.youtube.com/watch?v=${widget.video.videoId}';
        await Clipboard.setData(ClipboardData(text: videoUrl));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Could not open video automatically'),
                  const SizedBox(height: 4),
                  Text('URL copied to clipboard: $videoUrl', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('Please paste the URL in your browser', style: TextStyle(fontSize: 12)),
                ],
              ),
              duration: const Duration(seconds: 8),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Error launching video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final videoUrl = 'https://www.youtube.com/watch?v=${widget.video.videoId}';
              Share.share(
                'Check out this video: ${widget.video.title}\n$videoUrl',
                subject: widget.video.title,
              );
            },
            tooltip: 'Share video',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail with Play Button
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(widget.video.thumbnailUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Play Button Overlay
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isLoading ? Icons.hourglass_empty : Icons.play_arrow,
                          size: 40,
                          color: Colors.white,
                        ),
                        onPressed: _isLoading ? null : _playVideo,
                        tooltip: _isLoading ? 'Opening...' : 'Play Video',
                      ),
                    ),
                  ),
                  // Loading indicator
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  // Duration overlay
                  if (widget.video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.video.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              widget.video.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Channel and stats
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.video.channelTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                if (widget.video.formattedViewCount.isNotEmpty) ...[
                  Text(
                    widget.video.formattedViewCount,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.video.formattedPublishedDate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Play Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _playVideo,
                icon: Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.play_arrow,
                ),
                label: Text(
                  _isLoading ? 'Opening in Browser...' : 'Play Video in Browser',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            if (widget.video.description.isNotEmpty) ...[
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.video.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Channel', widget.video.channelTitle),
                    if (widget.video.formattedViewCount.isNotEmpty)
                      _buildInfoRow('Views', widget.video.formattedViewCount),
                    _buildInfoRow('Published', widget.video.formattedPublishedDate),
                    _buildInfoRow('Duration', widget.video.duration ?? 'Unknown'),
                    _buildInfoRow('Video ID', widget.video.videoId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
