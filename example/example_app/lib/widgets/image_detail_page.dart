import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

class ImageDetailPage extends StatefulWidget {
  final CommonsImage image;
  final WikipediaTopic topic;
  final WikimediaCommons commons;

  const ImageDetailPage({
    super.key,
    required this.image,
    required this.topic,
    required this.commons,
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
      final details = await widget.commons.getImageInfo(widget.image.fullTitle);
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
                    final url = _imageDetails!.url;
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
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Image.network(
                            _imageDetails!.url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Column(
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
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Description and source
                            if (_imageDetails!.description != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _imageDetails!.description!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),

                            // Main metadata grid
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 24,
                                runSpacing: 12,
                                children: [
                                  // Author info
                                  if (_imageDetails!.artistName != null)
                                    _buildMetadataColumn(
                                      context,
                                      'Author',
                                      _imageDetails!.artistName!,
                                      url: _imageDetails!.artistUrl,
                                    ),

                                  // License
                                  if (_imageDetails!.license != null)
                                    _buildMetadataColumn(
                                      context,
                                      'License',
                                      _imageDetails!.license!,
                                    ),

                                  // Technical details
                                  _buildMetadataColumn(
                                    context,
                                    'Dimensions',
                                    '${_imageDetails!.width} × ${_imageDetails!.height}',
                                    subtitle: _imageDetails!.fileSize != null
                                        ? _formatFileSize(_imageDetails!.fileSize!)
                                        : null,
                                  ),

                                  // Location
                                  if (_imageDetails!.latitude != null && _imageDetails!.longitude != null)
                                    _buildMetadataColumn(
                                      context,
                                      'Location',
                                      '${_imageDetails!.latitude!.toStringAsFixed(4)}, ${_imageDetails!.longitude!.toStringAsFixed(4)}',
                                      url:
                                          'https://www.openstreetmap.org/?mlat=${_imageDetails!.latitude}&mlon=${_imageDetails!.longitude}&zoom=15',
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMetadataColumn(
    BuildContext context,
    String label,
    String value, {
    String? url,
    String? subtitle,
  }) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          if (url != null)
            InkWell(
              onTap: () async {
                final data = ClipboardData(text: url);
                await Clipboard.setData(data);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label URL copied to clipboard'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
              ),
            )
          else
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
