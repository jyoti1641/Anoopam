class Video {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publishedAt;
  final String? duration;
  final int? viewCount;
  final String? likeCount;

  Video({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
    this.duration,
    this.viewCount,
    this.likeCount,
  });

  factory Video.fromJson(Map<String, dynamic> item) {
    return Video(
      videoId: item['id']['videoId'],
      title: item['snippet']['title'],
      description: item['snippet']['description'] ?? '',
      thumbnailUrl: item['snippet']['thumbnails']['high']['url'],
      channelTitle: item['snippet']['channelTitle'] ?? '',
      publishedAt: DateTime.parse(item['snippet']['publishedAt']),
    );
  }

  // Factory method for detailed video info (from videos.list endpoint)
  factory Video.fromDetailedJson(Map<String, dynamic> item) {
    final snippet = item['snippet'];
    final statistics = item['statistics'] ?? {};
    final contentDetails = item['contentDetails'] ?? {};
    
    return Video(
      videoId: item['id'],
      title: snippet['title'],
      description: snippet['description'] ?? '',
      thumbnailUrl: snippet['thumbnails']['high']['url'],
      channelTitle: snippet['channelTitle'] ?? '',
      publishedAt: DateTime.parse(snippet['publishedAt']),
      duration: contentDetails['duration'],
      viewCount: int.tryParse(statistics['viewCount'] ?? '0'),
      likeCount: statistics['likeCount'],
    );
  }

  // Convert duration from ISO 8601 format to readable format
  String get formattedDuration {
    if (duration == null) return '';
    
    // Parse ISO 8601 duration (PT4M13S -> 4:13)
    final durationStr = duration!;
    if (durationStr.startsWith('PT')) {
      final timeStr = durationStr.substring(2);
      final hours = timeStr.contains('H') ? int.parse(timeStr.split('H')[0]) : 0;
      final minutes = timeStr.contains('M') 
          ? int.parse(timeStr.split('M')[0].split('H').last) 
          : 0;
      final seconds = timeStr.contains('S') 
          ? int.parse(timeStr.split('S')[0].split('M').last) 
          : 0;
      
      if (hours > 0) {
        return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        return '${minutes}:${seconds.toString().padLeft(2, '0')}';
      }
    }
    return '';
  }

  String get formattedPublishedDate {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedViewCount {
    if (viewCount == null) return '';
    
    if (viewCount! >= 1000000) {
      return '${(viewCount! / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount! >= 1000) {
      return '${(viewCount! / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$viewCount views';
    }
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';
} 