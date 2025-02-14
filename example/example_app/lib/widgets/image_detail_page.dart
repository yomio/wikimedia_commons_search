import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';
import 'package:wikimedia_commons_search/src/models/topic.dart';
import 'package:wikimedia_commons_search/src/models/commons_image.dart';

class ImageDetailPage extends StatefulWidget {
  final CommonsImage image;
  final Topic topic;
  final WikimediaCommonsSearch search;

  const ImageDetailPage({
    super.key,
    required this.image,
    required this.topic,
    required this.search,
  });

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  CommonsImage? _imageDetails;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImageDetails();
  }

  Future<void> _loadImageDetails() async {
    try {
      final details = await widget.search.api.getImageInfo(widget.image.fullTitle);
      if (mounted && details != null) {
        setState(() {
          _imageDetails = details;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load image details',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadImageDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildMetadata(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.image.title),
        actions: _imageDetails != null
            ? [
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy image URL',
                  onPressed: () async {
                    final url = _imageDetails!.url!;
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image URL copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ]
            : null,
      ),
      body: _error != null
          ? _buildError()
          : _imageDetails == null
              ? _buildLoading()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: (_imageDetails!.width ?? 1) / (_imageDetails!.height ?? 1),
                        child: Image.network(
                          _imageDetails!.url!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Failed to load image'),
                                ],
                              ),
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMetadata(context, 'From', widget.topic.title),
                            _buildMetadata(context, 'Description', _imageDetails!.description),
                            _buildMetadata(context, 'License', _imageDetails!.license),
                            _buildMetadata(context, 'Attribution', _imageDetails!.attribution),
                            _buildMetadata(
                              context,
                              'Size',
                              '${_imageDetails!.width} × ${_imageDetails!.height} pixels',
                            ),
                            _buildMetadata(context, 'Type', _imageDetails!.mimeType),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
