import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/topic.dart';
import 'models/commons_image.dart';
import 'exceptions.dart';

/// A wrapper for Wikipedia API communications
class WikimediaApiWrapper {
  /// Creates a new instance of WikimediaApiWrapper
  WikimediaApiWrapper({http.Client? client}) : _client = client ?? http.Client();

  bool _isDisposed = false;

  // Use the CORS-enabled endpoint
  final String _baseWikipediaApiUrl = 'https://en.wikipedia.org/w/api.php';
  final String _baseCommonsApiUrl = 'https://commons.wikimedia.org/w/api.php';

  final http.Client _client;

  // Common patterns for utility images (flags, icons, etc.)
  final RegExp _utilityPatterns = RegExp(
    r'(flag|icon|template|logo|map|symbol|seal|coat[ _]of[ _]arms|emblem|banner)',
    caseSensitive: false,
  );

  // Images that should always be removed
  final RegExp _excludePatterns = RegExp(
    r'(commons-logo\.svg)',
    caseSensitive: false,
  );

  void _checkDisposed() {
    if (_isDisposed) {
      throw DisposedException();
    }
  }

  /// Searches for Wikipedia topics based on the given keyword
  Future<List<Topic>> searchTopics(String keyword) async {
    _checkDisposed();

    final queryParams = {
      'action': 'query',
      'format': 'json',
      'list': 'search',
      'srsearch': keyword,
      'srnamespace': '0',
      'srlimit': '10',
      'prop': 'extracts|info',
      'inprop': 'url|length',
      'explaintext': '1',
      'exintro': '1',
      'exchars': '500',
      'origin': '*',
    };

    final uri = Uri.parse(_baseWikipediaApiUrl).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw WikimediaApiException(
          'Failed to search topics',
          statusCode: response.statusCode,
          endpoint: uri.toString(),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['query'] == null || data['query']['search'] == null) {
        throw ResponseParsingException('Invalid API response format: missing query.search');
      }

      final searchResults = data['query']['search'] as List;
      if (searchResults.isEmpty) {
        throw WikimediaNoResultsException('No topics found for keyword: $keyword');
      }

      return searchResults.map((result) {
        final description = result['snippet'] as String? ?? '';

        return Topic(
          id: result['pageid'].toString(),
          title: result['title'] as String? ?? 'Untitled',
          description: description,
          timestamp: result['timestamp'] as String? ?? '',
          wordCount: result['wordcount'] as int? ?? 0,
          size: result['size'] as int? ?? 0,
          imageCount: 0, // We'll need a separate request to get image count
        );
      }).toList();
    } on FormatException catch (e) {
      throw ResponseParsingException('Failed to parse API response: ${e.message}');
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to search topics: $e');
    }
  }

  /// Gets basic information about all images from a specific Wikipedia page
  /// This method makes a single request and returns basic image information
  Future<List<CommonsImage>> getTopicImages(String pageId) async {
    _checkDisposed();

    final queryParams = {
      'action': 'query',
      'format': 'json',
      'pageids': pageId,
      'generator': 'images',
      'gimlimit': '500',
      'prop': 'imageinfo',
      'iiprop': 'url|size|mime|extmetadata',
      'iiurlwidth': '800',
      'origin': '*',
    };

    final uri = Uri.parse(_baseWikipediaApiUrl).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw WikimediaApiException(
          'Failed to get topic images',
          statusCode: response.statusCode,
          endpoint: uri.toString(),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['query'] == null || data['query']['pages'] == null) {
        throw WikimediaNoResultsException('No images found for the given topic');
      }

      final pages = data['query']['pages'] as Map<String, dynamic>;
      final images = <CommonsImage>[];

      for (final page in pages.values) {
        final title = page['title'] as String? ?? '';

        // Skip utility images and excluded patterns
        if (_utilityPatterns.hasMatch(title) || _excludePatterns.hasMatch(title)) {
          continue;
        }

        final imageInfo = (page['imageinfo'] as List?)?.firstOrNull as Map<String, dynamic>?;
        if (imageInfo == null) continue;

        final metadata = imageInfo['extmetadata'] as Map<String, dynamic>?;

        images.add(CommonsImage(
          title: title.replaceFirst('File:', ''),
          fullTitle: title,
          url: imageInfo['url'] as String?,
          thumbUrl: imageInfo['thumburl'] as String?,
          width: imageInfo['width'] as int?,
          height: imageInfo['height'] as int?,
          mimeType: imageInfo['mime'] as String?,
          description: metadata?['ImageDescription']?['value'] as String?,
          license: metadata?['License']?['value'] as String?,
          attribution: metadata?['Attribution']?['value'] as String?,
        ));
      }

      if (images.isEmpty) {
        throw WikimediaNoResultsException('No suitable images found for the given topic');
      }

      // Sort by priority (non-SVG before SVG, larger files first)
      images.sort((a, b) {
        final aPriority = a.mimeType?.contains('svg') == true ? 1 : 0;
        final bPriority = b.mimeType?.contains('svg') == true ? 1 : 0;
        if (aPriority != bPriority) return aPriority - bPriority;

        final aSize = (a.width ?? 0) * (a.height ?? 0);
        final bSize = (b.width ?? 0) * (b.height ?? 0);
        return bSize.compareTo(aSize);
      });

      return images;
    } on FormatException catch (e) {
      throw ResponseParsingException('Failed to parse API response: ${e.message}');
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to get topic images: $e');
    }
  }

  /// Gets detailed information about a specific image
  /// This includes metadata like description, license, and attribution
  Future<CommonsImage?> getImageInfo(String imageTitle) async {
    _checkDisposed();

    final queryParams = {
      'action': 'query',
      'format': 'json',
      'titles': imageTitle,
      'prop': 'imageinfo',
      'iiprop': 'url|size|mime|extmetadata',
      'iiurlwidth': '800',
      'origin': '*',
    };

    final uri = Uri.parse(_baseWikipediaApiUrl).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw WikimediaApiException(
          'Failed to get image info',
          statusCode: response.statusCode,
          endpoint: uri.toString(),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['query']?['pages'] == null) {
        throw ResponseParsingException('Invalid API response format: missing query.pages');
      }

      final pages = data['query']['pages'] as Map<String, dynamic>;
      final page = pages.values.first as Map<String, dynamic>;
      final imageInfo = page['imageinfo'] as List?;

      if (imageInfo == null || imageInfo.isEmpty) {
        throw WikimediaNoResultsException('No image info found for: $imageTitle');
      }

      final info = imageInfo.first as Map<String, dynamic>;
      final metadata = info['extmetadata'] as Map<String, dynamic>?;

      return CommonsImage(
        title: imageTitle.replaceFirst('File:', ''),
        fullTitle: imageTitle,
        url: info['url'] as String,
        thumbUrl: info['thumburl'] as String?,
        width: info['width'] as int,
        height: info['height'] as int,
        mimeType: info['mime'] as String,
        description: metadata?['ImageDescription']?['value'] as String?,
        license: metadata?['License']?['value'] as String?,
        attribution: metadata?['Attribution']?['value'] as String?,
      );
    } on FormatException catch (e) {
      throw ResponseParsingException('Failed to parse API response: ${e.message}');
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to get image info: $e');
    }
  }

  /// Searches for images directly on Wikimedia Commons based on a keyword
  /// Returns a list of images with their metadata
  Future<List<CommonsImage>> searchImages(String keyword) async {
    _checkDisposed();

    final queryParams = {
      'action': 'query',
      'format': 'json',
      'generator': 'search',
      'gsrnamespace': '6', // File namespace
      'gsrsearch': 'filetype:bitmap|drawing $keyword', // Exclude non-image files
      'gsrlimit': '50',
      'prop': 'imageinfo|categories',
      'iiprop': 'url|size|mime|metadata',
      'iiurlwidth': '800',
      'clcategories':
          'Category:Flag images|Category:Country flags|Category:SVG flags|Category:Icons|Category:Templates',
      'origin': '*',
    };

    final uri = Uri.parse(_baseCommonsApiUrl).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw WikimediaApiException(
          'Failed to search images',
          statusCode: response.statusCode,
          endpoint: uri.toString(),
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['query'] == null || data['query']['pages'] == null) {
        throw WikimediaNoResultsException('No images found for keyword: $keyword');
      }

      final pages = data['query']['pages'] as Map<String, dynamic>;
      final List<CommonsImage> result = [];

      for (final imagePage in pages.values) {
        final imageTitle = imagePage['title'] as String;
        if (!imageTitle.startsWith('File:')) continue;

        // Skip excluded images
        if (_excludePatterns.hasMatch(imageTitle)) continue;

        final imageInfo = (imagePage['imageinfo'] as List?)?.firstOrNull as Map<String, dynamic>?;
        if (imageInfo == null) continue;

        // Skip small images (likely icons, thumbnails, etc.)
        final width = imageInfo['width'] as int?;
        final height = imageInfo['height'] as int?;
        if (width != null && height != null) {
          if (width < 200 || height < 200) continue;
        }

        result.add(CommonsImage(
          title: imageTitle.replaceFirst('File:', ''),
          fullTitle: imageTitle,
          url: imageInfo['url'] as String?,
          thumbUrl: imageInfo['thumburl'] as String?,
          width: width,
          height: height,
          mimeType: imageInfo['mime'] as String?,
        ));
      }

      if (result.isEmpty) {
        throw WikimediaNoResultsException('No suitable images found for keyword: $keyword');
      }

      // Sort by priority (content images first, utility images last)
      result.sort((a, b) => a.priority.compareTo(b.priority));

      return result;
    } on FormatException catch (e) {
      throw ResponseParsingException('Failed to parse API response: ${e.message}');
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to search images: $e');
    }
  }

  /// Disposes the HTTP client
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _client.close();
  }
}
