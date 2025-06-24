// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:rxdart/rxdart.dart';
// import '../utils/theme.dart';
// import '../utils/helpers.dart';

// class AudioSearchBar extends StatefulWidget {
//   final Function(String) onSearch;
//   final Function()? onClear;
//   final String? hintText;
//   final bool showSuggestions;
//   final List<String>? suggestions;
//   final Function(String)? onSuggestionTap;

//   const AudioSearchBar({
//     super.key,
//     required this.onSearch,
//     this.onClear,
//     this.hintText,
//     this.showSuggestions = true,
//     this.suggestions,
//     this.onSuggestionTap,
//   });

//   @override
//   State<AudioSearchBar> createState() => _AudioSearchBarState();
// }

// class _AudioSearchBarState extends State<AudioSearchBar> {
//   final TextEditingController _controller = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
//   bool _isSearching = false;
//   bool _showSuggestions = false;

//   @override
//   void initState() {
//     super.initState();
//     _setupSearchDebounce();
//     _focusNode.addListener(_onFocusChange);
//   }

//   void _setupSearchDebounce() {
//     _searchSubject
//         .debounceTime(AudioConstants.debounceDuration)
//         .listen((query) {
//       if (query.isNotEmpty) {
//         widget.onSearch(query);
//       }
//     });
//   }

//   void _onFocusChange() {
//     setState(() {
//       _showSuggestions = _focusNode.hasFocus && 
//           widget.showSuggestions && 
//           widget.suggestions != null &&
//           widget.suggestions!.isNotEmpty;
//     });
//   }

//   void _onSearchChanged(String value) {
//     setState(() {
//       _isSearching = value.isNotEmpty;
//     });
//     _searchSubject.add(value);
//   }

//   void _clearSearch() {
//     _controller.clear();
//     setState(() {
//       _isSearching = false;
//       _showSuggestions = false;
//     });
//     _searchSubject.add('');
//     widget.onClear?.call();
//   }

//   void _onSuggestionTap(String suggestion) {
//     _controller.text = suggestion;
//     _controller.selection = TextSelection.fromPosition(
//       TextPosition(offset: suggestion.length),
//     );
//     setState(() {
//       _isSearching = true;
//       _showSuggestions = false;
//     });
//     widget.onSuggestionTap?.call(suggestion);
//     widget.onSearch(suggestion);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: _controller,
//             focusNode: _focusNode,
//             onChanged: _onSearchChanged,
//             textInputAction: TextInputAction.search,
//             keyboardType: TextInputType.text,
//             style: Theme.of(context).textTheme.bodyLarge,
//             decoration: InputDecoration(
//               hintText: widget.hintText ?? 'Search songs, artists, albums...',
//               hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Theme.of(context).textTheme.bodySmall?.color,
//               ),
//               prefixIcon: Icon(
//                 Icons.search,
//                 color: Theme.of(context).iconTheme.color,
//               ),
//               suffixIcon: _isSearching
//                   ? IconButton(
//                       icon: Icon(
//                         Icons.clear,
//                         color: Theme.of(context).iconTheme.color,
//                       ),
//                       onPressed: _clearSearch,
//                     )
//                   : null,
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//             ),
//           ),
//         ),
//         if (_showSuggestions) _buildSuggestions(),
//       ],
//     );
//   }

//   Widget _buildSuggestions() {
//     if (widget.suggestions == null || widget.suggestions!.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ...widget.suggestions!.map((suggestion) => _buildSuggestionItem(suggestion)),
//         ],
//       ),
//     );
//   }

//   Widget _buildSuggestionItem(String suggestion) {
//     return ListTile(
//       leading: Icon(
//         Icons.history,
//         color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
//         size: 20,
//       ),
//       title: Text(
//         suggestion,
//         style: Theme.of(context).textTheme.bodyMedium,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//       onTap: () => _onSuggestionTap(suggestion),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _focusNode.dispose();
//     _searchSubject.close();
//     super.dispose();
//   }
// }

// class VoiceSearchButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final bool isListening;

//   const VoiceSearchButton({
//     super.key,
//     required this.onPressed,
//     this.isListening = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       child: IconButton(
//         onPressed: onPressed,
//         icon: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 200),
//           child: Icon(
//             isListening ? Icons.mic : Icons.mic_none,
//             key: ValueKey(isListening),
//             color: isListening 
//                 ? AudioTheme.primaryColor 
//                 : Theme.of(context).iconTheme.color,
//           ),
//         ),
//         style: IconButton.styleFrom(
//           backgroundColor: isListening 
//               ? AudioTheme.primaryColor.withOpacity(0.1)
//               : Colors.transparent,
//         ),
//       ),
//     );
//   }
// }

// class AudioFilterChip extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final IconData? icon;

//   const AudioFilterChip({
//     super.key,
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//     this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: isSelected 
//                 ? AudioTheme.primaryColor.withOpacity(0.1)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: isSelected 
//                   ? AudioTheme.primaryColor
//                   : Theme.of(context).dividerColor,
//             ),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (icon != null) ...[
//                 Icon(
//                   icon,
//                   size: 16,
//                   color: isSelected 
//                       ? AudioTheme.primaryColor
//                       : Theme.of(context).iconTheme.color,
//                 ),
//                 const SizedBox(width: 4),
//               ],
//               Text(
//                 label,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: isSelected 
//                       ? AudioTheme.primaryColor
//                       : Theme.of(context).textTheme.bodyMedium?.color,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SearchFilters extends StatefulWidget {
//   final List<String> filters;
//   final List<String> selectedFilters;
//   final Function(List<String>) onFiltersChanged;

//   const SearchFilters({
//     super.key,
//     required this.filters,
//     required this.selectedFilters,
//     required this.onFiltersChanged,
//   });

//   @override
//   State<SearchFilters> createState() => _SearchFiltersState();
// }

// class _SearchFiltersState extends State<SearchFilters> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 40,
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: widget.filters.length,
//         itemBuilder: (context, index) {
//           final filter = widget.filters[index];
//           final isSelected = widget.selectedFilters.contains(filter);
          
//           return AudioFilterChip(
//             label: filter,
//             isSelected: isSelected,
//             onTap: () {
//               final newFilters = List<String>.from(widget.selectedFilters);
//               if (isSelected) {
//                 newFilters.remove(filter);
//               } else {
//                 newFilters.add(filter);
//               }
//               widget.onFiltersChanged(newFilters);
//             },
//           );
//         },
//       ),
//     );
//   }
// } 