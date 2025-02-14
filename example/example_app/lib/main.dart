import 'package:flutter/material.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';
import 'dart:developer' as developer;
import 'widgets/search_bar_widget.dart';
import 'widgets/error_display.dart';
import 'widgets/topic_details_page.dart';
import 'widgets/image_detail_page.dart';

void main() {
  runApp(const WikimediaSearchApp());
}

class WikimediaSearchApp extends StatelessWidget {
  const WikimediaSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wikimedia Commons Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _search = WikimediaCommonsSearch();
  List<Topic>? _searchResults;
  List<CommonsImage>? _imageResults;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Execute both searches in parallel
      final results = await Future.wait([
        _search.searchTopics(query),
        _search.api.searchImages(query),
      ]);

      if (mounted) {
        setState(() {
          _searchResults = results[0] as List<Topic>;
          _imageResults = results[1] as List<CommonsImage>;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error performing search',
        error: e,
        stackTrace: stackTrace,
        name: 'WikimediaSearch',
      );
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _handleTopicSelected(Topic topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicDetailsPage(
          topic: topic,
          search: _search,
        ),
      ),
    );
  }

  Widget _buildTopicChips() {
    if (_searchResults == null || _searchResults!.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _searchResults!.map((topic) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(topic.title),
              onPressed: () => _handleTopicSelected(topic),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_imageResults == null) return const SizedBox.shrink();
    if (_imageResults!.isEmpty) {
      return const Center(
        child: Text(
          'No images found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _calculateCrossAxisCount(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: _imageResults!.length,
      itemBuilder: (context, index) {
        final image = _imageResults![index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageDetailPage(
                  image: image,
                  topic: const Topic(
                    id: 'search',
                    title: 'Search Results',
                    description: '',
                    timestamp: '',
                    wordCount: 0,
                    size: 0,
                    imageCount: 0,
                  ),
                  search: _search,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: image.url != null || image.thumbUrl != null
                  ? Image.network(
                      image.thumbUrl ?? image.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    if (width > 400) return 3;
    return 2;
  }

  Widget _buildContent() {
    if (_error != null) {
      return ErrorDisplay(
        error: _error!,
        onRetry: () {
          if (_searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          }
        },
      );
    }

    if (_imageResults == null && _searchResults == null) {
      return const Center(
        child: Text(
          'Enter a search term to find images and topics',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchResults != null && _searchResults!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Related Topics',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildTopicChips(),
          const SizedBox(height: 16),
        ],
        Expanded(child: _buildImageGrid()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wikimedia Commons Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SearchBarWidget(
                controller: _searchController,
                isLoading: _isLoading,
                onSubmitted: _performSearch,
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = null;
                    _imageResults = null;
                    _error = null;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
