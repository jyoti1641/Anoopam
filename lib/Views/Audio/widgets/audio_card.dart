// import 'package:anoopam_mission/Views/Audio/models/song.dart';
// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:provider/provider.dart';

// import '../../../utils/responsive_helper.dart';

// class AudioCard extends StatelessWidget {
//   final AudioModel audio;
//   final VoidCallback? onTap;
//   final VoidCallback? onLongPress;
//   final bool showAlbumArt;
//   final bool showDuration;
//   final bool showFavoriteButton;
//   final bool showMoreButton;
//   final bool isPlaying;
//   final bool isSelected;

//   const AudioCard({
//     super.key,
//     required this.audio,
//     this.onTap,
//     this.onLongPress,
//     this.showAlbumArt = true,
//     this.showDuration = true,
//     this.showFavoriteButton = true,
//     this.showMoreButton = true,
//     this.isPlaying = false,
//     this.isSelected = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = ResponsiveHelper.isMobile(context);
//     final isTablet = ResponsiveHelper.isTablet(context);
    
//     return Card(
//       margin: EdgeInsets.symmetric(
//         horizontal: isMobile ? 8.0 : 12.0,
//         vertical: isMobile ? 4.0 : 6.0,
//       ),
//       elevation: isPlaying ? 8 : 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isMobile ? 8.0 : 12.0),
//       ),
//       child: InkWell(
//         onTap: onTap ?? () {
//           final audioProvider = Provider.of<AudioProvider>(context, listen: false);
//           audioProvider.play(audio);
//         },
//         borderRadius: BorderRadius.circular(isMobile ? 8.0 : 12.0),
//         child: Container(
//           padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
//           child: Row(
//             children: [
//               if (showAlbumArt) _buildAlbumArt(context),
//               SizedBox(width: isMobile ? 12.0 : 16.0),
//               Expanded(child: _buildSongInfo(context)),
//               if (showDuration) _buildDuration(),
//               if (showFavoriteButton) _buildFavoriteButton(context),
//               if (showMoreButton) _buildMoreButton(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAlbumArt(BuildContext context) {
//     final isMobile = ResponsiveHelper.isMobile(context);
//     final size = isMobile ? 48.0 : 56.0;
    
//     return Stack(
//       children: [
//         Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(isMobile ? 6.0 : 8.0),
//             color: AudioHelpers.getRandomColor().withOpacity(0.3),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(isMobile ? 6.0 : 8.0),
//             child: (audio.coverImageUrl?.isNotEmpty == true)
//                 ? CachedNetworkImage(
//                     imageUrl: audio.coverImageUrl!,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Icon(
//                       Icons.music_note,
//                       color: Colors.white.withOpacity(0.6),
//                       size: isMobile ? 20.0 : 24.0,
//                     ),
//                     errorWidget: (context, url, error) => Icon(
//                       Icons.music_note,
//                       color: Colors.white.withOpacity(0.6),
//                       size: isMobile ? 20.0 : 24.0,
//                     ),
//                   )
//                 : Icon(
//                     Icons.music_note,
//                     color: Colors.white.withOpacity(0.6),
//                     size: isMobile ? 20.0 : 24.0,
//                   ),
//           ),
//         ),
//         if (isPlaying)
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(isMobile ? 6.0 : 8.0),
//                 color: AudioTheme.primaryColor.withOpacity(0.7),
//               ),
//               child: const Icon(
//                 Icons.play_arrow,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildSongInfo(BuildContext context) {
//     final isMobile = ResponsiveHelper.isMobile(context);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           audio.name,
//           style: TextStyle(
//             fontSize: isMobile ? 14.0 : 16.0,
//             fontWeight: FontWeight.w600,
//             color: isPlaying ? AudioTheme.primaryColor : AudioTheme.textPrimary,
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         SizedBox(height: isMobile ? 2.0 : 4.0),
//         Text(
//           audio.artist ?? 'Unknown Artist',
//           style: TextStyle(
//             fontSize: isMobile ? 12.0 : 14.0,
//             color: AudioTheme.textSecondary,
//           ),
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         if (audio.duration != null) ...[
//           SizedBox(height: isMobile ? 2.0 : 4.0),
//           Text(
//             AudioHelpers.formatDuration(audio.duration!),
//             style: TextStyle(
//               fontSize: isMobile ? 10.0 : 12.0,
//               color: AudioTheme.textTertiary,
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildDuration() {
//     return Text(
//       audio.duration != null ? AudioHelpers.formatDuration(audio.duration!) : 'Unknown',
//       style: const TextStyle(
//         fontSize: 12,
//         color: AudioTheme.textTertiary,
//       ),
//     );
//   }

//   Widget _buildFavoriteButton(BuildContext context) {
//     return Consumer<AudioProvider>(
//       builder: (context, audioProvider, child) {
//         final isFavorite = audioProvider.isFavorite(audio.id);
        
//         return IconButton(
//           icon: Icon(
//             isFavorite ? Icons.favorite : Icons.favorite_border,
//             color: isFavorite ? Colors.red : AudioTheme.textSecondary,
//             size: 20,
//           ),
//           onPressed: () => audioProvider.toggleFavorite(audio.id),
//           padding: EdgeInsets.zero,
//           constraints: const BoxConstraints(),
//         );
//       },
//     );
//   }

//   Widget _buildMoreButton(BuildContext context) {
//     return PopupMenuButton<String>(
//       onSelected: (value) => _handleMoreAction(context, value),
//       itemBuilder: (context) => [
//         const PopupMenuItem(
//           value: 'add_to_playlist',
//           child: Row(
//             children: [
//               Icon(Icons.playlist_add, size: 20),
//               SizedBox(width: 8),
//               Text('Add to Playlist'),
//             ],
//           ),
//         ),
//         const PopupMenuItem(
//           value: 'download',
//           child: Row(
//             children: [
//               Icon(Icons.download, size: 20),
//               SizedBox(width: 8),
//               Text('Download'),
//             ],
//           ),
//         ),
//         const PopupMenuItem(
//           value: 'share',
//           child: Row(
//             children: [
//               Icon(Icons.share, size: 20),
//               SizedBox(width: 8),
//               Text('Share'),
//             ],
//           ),
//         ),
//         const PopupMenuItem(
//           value: 'info',
//           child: Row(
//             children: [
//               Icon(Icons.info, size: 20),
//               SizedBox(width: 8),
//               Text('Song Info'),
//             ],
//           ),
//         ),
//       ],
//       icon: const Icon(
//         Icons.more_vert,
//         color: AudioTheme.textSecondary,
//         size: 20,
//       ),
//       padding: EdgeInsets.zero,
//       constraints: const BoxConstraints(),
//     );
//   }

//   void _handleMoreAction(BuildContext context, String action) {
//     switch (action) {
//       case 'add_to_playlist':
//         _showPlaylistDialog(context);
//         break;
//       case 'download':
//         _downloadSong(context);
//         break;
//       case 'share':
//         _shareSong(context);
//         break;
//       case 'info':
//         _showSongInfo(context);
//         break;
//     }
//   }

//   void _showPlaylistDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add to Playlist'),
//         content: const Text('Select a playlist to add this song to.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               AudioHelpers.showSnackBar(context, 'Song added to playlist');
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _downloadSong(BuildContext context) {
//     AudioHelpers.showSnackBar(context, 'Download started');
//   }

//   void _shareSong(BuildContext context) {
//     AudioHelpers.showSnackBar(context, 'Sharing song...');
//   }

//   void _showSongInfo(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Song Information'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Title: ${audio.name}'),
//             const SizedBox(height: 8),
//             Text('Artist: ${audio.artist ?? 'Unknown Artist'}'),
//             const SizedBox(height: 8),
//             Text('Duration: ${audio.duration != null ? AudioHelpers.formatDuration(audio.duration!) : 'Unknown'}'),
//             const SizedBox(height: 8),
//             Text('Album ID: ${audio.albumId}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AudioCardCompact extends StatelessWidget {
//   final AudioModel audio;
//   final VoidCallback? onTap;
//   final bool isPlaying;
//   final bool isSelected;

//   const AudioCardCompact({
//     super.key,
//     required this.audio,
//     this.onTap,
//     this.isPlaying = false,
//     this.isSelected = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AudioProvider>(
//       builder: (context, audioProvider, child) {
//         final isCurrentSong = audioProvider.currentSong?.id == audio.id;

//         return GestureDetector(
//           onTap: onTap ?? () => audioProvider.play(audio),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: isSelected || isCurrentSong
//                   ? AudioTheme.primaryColor.withOpacity(0.1)
//                   : Colors.transparent,
//             ),
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 24,
//                   child: isPlaying || isCurrentSong
//                       ? const Icon(
//                           Icons.play_arrow,
//                           color: AudioTheme.primaryColor,
//                           size: 20,
//                         )
//                       : Text(
//                           '${audioProvider.queue.indexOf(audio) + 1}',
//                           style: const TextStyle(
//                             color: AudioTheme.textSecondary,
//                             fontSize: 14,
//                           ),
//                         ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         audio.name,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: isPlaying || isCurrentSong
//                               ? FontWeight.w600
//                               : FontWeight.w400,
//                           color: isPlaying || isCurrentSong
//                               ? AudioTheme.primaryColor
//                               : AudioTheme.textPrimary,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text(
//                         audio.artist ?? 'Unknown Artist',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: AudioTheme.textSecondary,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   audio.duration != null
//                       ? AudioHelpers.formatDuration(audio.duration!)
//                       : 'Unknown',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: AudioTheme.textTertiary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class AudioCardGrid extends StatelessWidget {
//   final AudioModel audio;
//   final VoidCallback? onTap;
//   final double size;
//   final bool showTitle;

//   const AudioCardGrid({
//     super.key,
//     required this.audio,
//     this.onTap,
//     this.size = 160,
//     this.showTitle = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = ResponsiveHelper.isMobile(context);
//     final cardSize = isMobile ? size * 0.8 : size;
    
//     return GestureDetector(
//       onTap: onTap ?? () {
//         final audioProvider = Provider.of<AudioProvider>(context, listen: false);
//         audioProvider.play(audio);
//       },
//       child: Container(
//         width: cardSize,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Album Art
//             Container(
//               width: cardSize,
//               height: cardSize,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(isMobile ? 8.0 : 12.0),
//                 color: AudioHelpers.getRandomColor().withOpacity(0.3),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(isMobile ? 8.0 : 12.0),
//                 child: (audio.coverImageUrl?.isNotEmpty == true)
//                     ? CachedNetworkImage(
//                         imageUrl: audio.coverImageUrl!,
//                         fit: BoxFit.cover,
//                         placeholder: (context, url) => Icon(
//                           Icons.music_note,
//                           color: Colors.white.withOpacity(0.6),
//                           size: cardSize * 0.3,
//                         ),
//                         errorWidget: (context, url, error) => Icon(
//                           Icons.music_note,
//                           color: Colors.white.withOpacity(0.6),
//                           size: cardSize * 0.3,
//                         ),
//                       )
//                     : Icon(
//                         Icons.music_note,
//                         color: Colors.white.withOpacity(0.6),
//                         size: cardSize * 0.3,
//                       ),
//               ),
//             ),
            
//             if (showTitle) ...[
//               SizedBox(height: isMobile ? 8.0 : 12.0),
//               // Song Title
//               Text(
//                 audio.name,
//                 style: TextStyle(
//                   fontSize: isMobile ? 12.0 : 14.0,
//                   fontWeight: FontWeight.w600,
//                   color: AudioTheme.textPrimary,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               SizedBox(height: isMobile ? 2.0 : 4.0),
//               // Artist Name
//               Text(
//                 audio.artist ?? 'Unknown Artist',
//                 style: TextStyle(
//                   fontSize: isMobile ? 10.0 : 12.0,
//                   color: AudioTheme.textSecondary,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// } 
