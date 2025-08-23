// lib/screens/sahebji_darshan_screen.dart

import 'package:anoopam_mission/Views/Gallery/sahebji_darshan_detail_screen.dart';
import 'package:anoopam_mission/data/photo_service.dart';
import 'package:anoopam_mission/models/sahebji_darshan_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SahebjiDarshanScreen extends StatefulWidget {
  const SahebjiDarshanScreen({super.key});

  @override
  State<SahebjiDarshanScreen> createState() => _SahebjiDarshanScreenState();
}

class _SahebjiDarshanScreenState extends State<SahebjiDarshanScreen> {
  List<SahebjiDarshanAlbum> _albums = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  DateTime? _startDate;
  DateTime? _endDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
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
        _currentPage < _totalPages) {
      _fetchAlbums(page: _currentPage + 1);
    }
  }

  Future<void> _fetchAlbums(
      {int page = 1, String? startDate, String? endDate}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      if (page == 1) {
        _albums.clear();
      }
    });

    try {
      final response = await PhotoApiService.getSahebjiDarshanAlbums(
        page: page,
        startDate: startDate,
        endDate: endDate,
      );
      if (!mounted) return;
      setState(() {
        _albums.addAll(response.data);
        _currentPage = response.currentPage;
        _totalPages = response.totalPages;
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now(),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      final formattedStartDate = DateFormat('yyyyMMdd').format(_startDate!);
      final formattedEndDate = DateFormat('yyyyMMdd').format(_endDate!);
      _fetchAlbums(
        page: 1,
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahebji Darshan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: GestureDetector(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(
                      _startDate == null || _endDate == null
                          ? 'Select Date Range'
                          : '${DateFormat.yMMMd().format(_startDate!)} - ${DateFormat.yMMMd().format(_endDate!)}',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading && _albums.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : _albums.isEmpty
                        ? const Center(
                            child: Text(
                                'No albums found for the selected date range.'))
                        : RefreshIndicator(
                            onRefresh: () => _fetchAlbums(page: 1),
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(10),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: _albums.length + (_isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _albums.length) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                final album = _albums[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SahebjiDarshanDetailScreen(
                                                albumId: album.id),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          album.coverImage,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          size: 40,
                                                          color: Colors.grey)),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            color: Colors.black54,
                                            child: Text(
                                              album.date,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          right: 8,
                                          child: Text(
                                            album.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 3.0,
                                                    color: Colors.black,
                                                    offset: Offset(1.0, 1.0))
                                              ],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
