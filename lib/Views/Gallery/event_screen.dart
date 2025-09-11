// lib/screens/events_screen.dart

import 'package:anoopam_mission/data/photo_service.dart';
import 'package:anoopam_mission/models/event.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final PhotoApiService _eventsRepository = PhotoApiService();
  final ScrollController _scrollController = ScrollController();
  List<EventAlbum> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasNextPage) {
      _loadNextPage();
    }
  }

  Future<void> _fetchEvents() async {
    if (_isLoading) return;
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedEvents =
          await _eventsRepository.getEvents(page: _currentPage);
      if (!mounted) return;
      setState(() {
        _events.addAll(fetchedEvents);
        _hasNextPage = fetchedEvents.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    _currentPage++;
    await _fetchEvents();
  }

  void _onEventTap(EventAlbum event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          eventId: event.id,
          eventTitle: event.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: AppBar(
        title: Text('All Events'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 1,
        centerTitle: true,
        surfaceTintColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: _events.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _events.isEmpty
                  ? const Center(child: Text('No events found.'))
                  : Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _events.length + (_hasNextPage ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _events.length) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              final event = _events[index];
                              final themeProvider =
                                  Provider.of<ThemeProvider>(context);
                              final isDark =
                                  themeProvider.currentTheme == ThemeMode.dark;
                              return GestureDetector(
                                onTap: () => _onEventTap(event),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.5)
                                            : Colors.grey.withOpacity(0.18),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          event.coverImage,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          size: 50,
                                                          color: Colors.grey)),
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.6),
                                              ],
                                            ),
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(12),
                                              bottomRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: BoxBorder.all(
                                                        color: Colors.white70,
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 2),
                                                    child: Text(
                                                      event.date,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  event.title,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    // shadows: [
                                                    //   Shadow(
                                                    //     blurRadius: 3.0,
                                                    //     color: Colors.black,
                                                    //     offset:
                                                    //         Offset(1.0, 1.0),
                                                    //   ),
                                                    // ],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
