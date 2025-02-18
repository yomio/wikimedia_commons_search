import 'package:flutter/material.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';
import 'image_detail_page.dart';

class TopicDetailsPage extends StatefulWidget {
  final WikipediaTopic topic;
  final WikimediaCommons commons;

  const TopicDetailsPage({
    super.key,
    required this.topic,
    required this.commons,
  });

  @override
  State<TopicDetailsPage> createState() => _TopicDetailsPageState();
}

class _TopicDetailsPageState extends State<TopicDetailsPage> {
  late Future<List<CommonsImage>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    _imagesFuture = widget.commons.getTopicImages(widget.topic.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.topic.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.topic.imageCount > 0)
              Text(
                '${widget.topic.imageCount} images',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
      ),
      body: FutureBuilder<List<CommonsImage>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Only handle WikimediaCommonsException, let others propagate
            if (snapshot.error is WikimediaCommonsException) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _loadImages());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            // Rethrow other errors
            throw snapshot.error!;
          }

          final images = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = _calculateCrossAxisCount(context);
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageDetailPage(
                            image: image,
                            topic: widget.topic,
                            commons: widget.commons,
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
                        child: Image.network(
                          image.thumbUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Use more columns on wider screens
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    if (width > 400) return 3;
    return 2;
  }
}
