// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
// import '../utils/theme.dart';

// class ShimmerLoader extends StatelessWidget {
//   final Widget child;
//   final Color? baseColor;
//   final Color? highlightColor;

//   const ShimmerLoader({
//     super.key,
//     required this.child,
//     this.baseColor,
//     this.highlightColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: baseColor ?? AudioTheme.surfaceColor,
//       highlightColor: highlightColor ?? AudioTheme.cardColor,
//       child: child,
//     );
//   }
// }

// class AudioCardShimmer extends StatelessWidget {
//   final double height;
//   final double width;

//   const AudioCardShimmer({
//     super.key,
//     this.height = 80,
//     this.width = double.infinity,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoader(
//       child: Container(
//         height: height,
//         width: width,
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             // Album art shimmer
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Text content shimmer
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Title shimmer
//                   Container(
//                     height: 16,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   // Artist shimmer
//                   Container(
//                     height: 12,
//                     width: MediaQuery.of(context).size.width * 0.4,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Duration shimmer
//             Container(
//               height: 12,
//               width: 40,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AlbumCardShimmer extends StatelessWidget {
//   final double size;

//   const AlbumCardShimmer({
//     super.key,
//     this.size = 160,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoader(
//       child: Container(
//         width: size,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Album art shimmer
//             Container(
//               width: size,
//               height: size,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             const SizedBox(height: 8),
//             // Album title shimmer
//             Container(
//               height: 16,
//               width: size * 0.8,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             const SizedBox(height: 4),
//             // Artist name shimmer
//             Container(
//               height: 12,
//               width: size * 0.6,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CategoryCardShimmer extends StatelessWidget {
//   final double height;
//   final double width;

//   const CategoryCardShimmer({
//     super.key,
//     this.height = 100,
//     this.width = 120,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoader(
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Icon shimmer
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               // Text shimmer
//               Container(
//                 height: 12,
//                 width: width * 0.7,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PlaylistCardShimmer extends StatelessWidget {
//   final double height;
//   final double width;

//   const PlaylistCardShimmer({
//     super.key,
//     this.height = 120,
//     this.width = 140,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoader(
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             // Playlist image shimmer
//             Expanded(
//               flex: 3,
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: const Icon(
//                   Icons.playlist_play,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//               ),
//             ),
//             // Text content shimmer
//             Expanded(
//               flex: 1,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 12,
//                       width: width * 0.8,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       height: 8,
//                       width: width * 0.5,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SearchBarShimmer extends StatelessWidget {
//   const SearchBarShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoader(
//       child: Container(
//         height: 48,
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//         ),
//       ),
//     );
//   }
// }

// class PlayerControlsShimmer extends StatelessWidget {
//   const PlayerControlsShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoader(
//       child: Container(
//         height: 80,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             // Album art shimmer
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Song info shimmer
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     height: 16,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Container(
//                     height: 12,
//                     width: MediaQuery.of(context).size.width * 0.3,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Play button shimmer
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class GridShimmer extends StatelessWidget {
//   final int crossAxisCount;
//   final double childAspectRatio;
//   final int itemCount;

//   const GridShimmer({
//     super.key,
//     this.crossAxisCount = 2,
//     this.childAspectRatio = 0.8,
//     this.itemCount = 6,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoader(
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: crossAxisCount,
//           childAspectRatio: childAspectRatio,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//         ),
//         itemCount: itemCount,
//         itemBuilder: (context, index) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class ListShimmer extends StatelessWidget {
//   final int itemCount;
//   final double itemHeight;

//   const ListShimmer({
//     super.key,
//     this.itemCount = 10,
//     this.itemHeight = 80,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoader(
//       child: ListView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: itemCount,
//         itemBuilder: (context, index) {
//           return Container(
//             height: itemHeight,
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class HorizontalListShimmer extends StatelessWidget {
//   final int itemCount;
//   final double itemWidth;
//   final double itemHeight;

//   const HorizontalListShimmer({
//     super.key,
//     this.itemCount = 5,
//     this.itemWidth = 160,
//     this.itemHeight = 200,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoader(
//       child: SizedBox(
//         height: itemHeight,
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: itemCount,
//           itemBuilder: (context, index) {
//             return Container(
//               width: itemWidth,
//               margin: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
