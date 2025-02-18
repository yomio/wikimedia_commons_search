import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/topic.dart';
import 'models/commons_image.dart';
import 'exceptions.dart';

/// A wrapper for Wikipedia API communications
class WikimediaApiWrapper {
  /// Creates a new instance of WikimediaApiWrapper
  WikimediaApiWrapper({
    http.Client? client,
    this.defaultThumbnailHeight = 200,
  }) : _client = client ?? http.Client();

  bool _isDisposed = false;

  /// Default height for image thumbnails in pixels
  final int defaultThumbnailHeight;

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
    r'(commons-logo\.svg|'
    r'Gnome-mime-sound-openclipart\.svg|'
    r'Star_full\.svg|'
    r'Pending-protection-shackle\.svg|'
    r'Question_book-new\.svg|'
    r'Star_empty\.svg|'
    r'Decrease2\.svg|'
    r'Increase2\.svg|'
    r'Steady2\.svg|'
    r'Semi-protection-shackle\.svg|'
    r'Disambig_gray\.svg|'
    r'Searchtool\.svg|'
    r'Nuvola_apps_kaboodle\.svg|'
    r'Cscr-featured\.svg|'
    r'Question_book-new\.svg)',
    caseSensitive: false,
  );

  void _checkDisposed() {
    if (_isDisposed) {
      throw DisposedException();
    }
  }

  /// Searches for Wikipedia topics based on the given keyword
  Future<List<WikipediaTopic>> searchTopics(String keyword, {int? limit}) async {
    _checkDisposed();

    final queryParams = {
      'action': 'query',
      'format': 'json',
      'list': 'search',
      'srsearch': keyword,
      'srnamespace': '0',
      'srlimit': (limit ?? 10).toString(),
      'srsort': 'relevance',
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
        final title = result['title'] as String? ?? 'Untitled';

        // Construct the Wikipedia URL from the title
        final encodedTitle = Uri.encodeComponent(title.replaceAll(' ', '_'));
        final url = 'https://en.wikipedia.org/wiki/$encodedTitle';

        return WikipediaTopic(
          id: result['pageid'].toString(),
          title: title,
          description: description,
          timestamp: result['timestamp'] as String? ?? '',
          wordCount: result['wordcount'] as int? ?? 0,
          size: result['size'] as int? ?? 0,
          imageCount: 0, // We'll need a separate request to get image count
          url: url,
        );
      }).toList();
    } on FormatException catch (e) {
      throw ResponseParsingException('Failed to parse API response: ${e.message}');
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to search topics: $e');
    }
  }

  /// Helper method to extract URLs from HTML-formatted text
  String? _extractUrlFromHtml(String? text) {
    if (text == null) return null;

    // First try to find an href URL
    final hrefMatch = RegExp(r'href=\"([^"]*)\"').firstMatch(text)?.group(1);
    if (hrefMatch != null) {
      try {
        final uri = Uri.parse(hrefMatch);
        if (!uri.hasScheme) {
          return 'https:${hrefMatch.startsWith('//') ? hrefMatch : '//$hrefMatch'}';
        }
        return hrefMatch;
      } on FormatException {
        // Ignore and try the next method
      }
    }

    // Then try to find a direct URL in the text
    final urlMatch = RegExp(r'https?://[^\s\]]+').firstMatch(text)?.group(0);
    if (urlMatch != null) {
      try {
        Uri.parse(urlMatch);
        return urlMatch;
      } on FormatException {
        return null;
      }
    }

    return null;
  }

  /// Helper method to extract artist information from metadata
  Map<String, String?> _extractArtistInfo(Map<String, dynamic>? metadata) {
    final artistText = _extractMetadataValue(metadata, 'Artist');
    if (artistText == null) return {'name': null, 'url': null};

    // Try to find a URL in the HTML or text
    final artistUrl = _extractUrlFromHtml(metadata?['Artist']?['value'] as String?);

    // Clean up artist name by removing URLs and wiki markup
    final String artistName = artistText
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'\[\[.*?\]\]'), '') // Remove wiki markup
        .replaceAll(RegExp(r'https?://[^\s\]]+'), '') // Remove URLs
        .replaceAll('|', '')
        .trim();

    return {
      'name': artistName.isEmpty ? null : artistName,
      'url': artistUrl,
    };
  }

  /// Helper method to extract GPS coordinates from metadata
  Map<String, double?> _extractGpsCoordinates(Map<String, dynamic>? metadata) {
    final latitude = _extractMetadataValue(metadata, 'GPSLatitude');
    final longitude = _extractMetadataValue(metadata, 'GPSLongitude');

    return {
      'latitude': latitude != null ? double.tryParse(latitude) : null,
      'longitude': longitude != null ? double.tryParse(longitude) : null,
    };
  }

  /// Gets basic information about all images from a specific Wikipedia page
  /// This method makes a single request and returns basic image information
  Future<List<CommonsImage>> getTopicImages(String pageId, {int? thumbnailHeight}) async {
    _checkDisposed();

    final queryParams = {
      'action': 'query',
      'format': 'json',
      'pageids': pageId,
      'generator': 'images',
      'gimlimit': '500',
      'prop': 'imageinfo',
      'iiprop': 'url|size|mime|extmetadata|mediatype',
      'iiurlheight': (thumbnailHeight ?? defaultThumbnailHeight).toString(),
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

        // Skip non-image media types
        final mediaType = imageInfo['mediatype'] as String?;
        if (mediaType != 'BITMAP' && mediaType != 'DRAWING') continue;

        final metadata = imageInfo['extmetadata'] as Map<String, dynamic>?;
        final url = imageInfo['url'] as String?;
        final width = imageInfo['width'] as int?;
        final height = imageInfo['height'] as int?;
        final mimeType = imageInfo['mime'] as String?;

        // Skip images that don't have required fields
        if (url == null || width == null || height == null || mimeType == null) {
          continue;
        }

        final artistInfo = _extractArtistInfo(metadata);
        final gpsCoordinates = _extractGpsCoordinates(metadata);
        final fileSize = imageInfo['size'] as int?;

        images.add(CommonsImage(
          title: title.replaceFirst('File:', ''),
          fullTitle: title,
          url: url,
          thumbUrl: imageInfo['thumburl'] as String? ?? url,
          width: width,
          height: height,
          mimeType: mimeType,
          description: _extractMetadataValue(metadata, 'ImageDescription'),
          license: _extractMetadataValue(metadata, 'LicenseShortName'),
          licenseUrl: metadata?['LicenseUrl']?['value'] as String?,
          artistName: artistInfo['name'],
          artistUrl: artistInfo['url'],
          attribution: _extractMetadataValue(metadata, 'Attribution'),
          latitude: gpsCoordinates['latitude'],
          longitude: gpsCoordinates['longitude'],
          fileSize: fileSize,
        ));
      }

      if (images.isEmpty) {
        throw WikimediaNoResultsException('No suitable images found for the given topic');
      }

      // Sort by size (larger files first)
      images.sort((a, b) {
        final aSize = a.width * a.height;
        final bSize = b.width * b.height;
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

  /// Helper method to extract metadata values from the API response
  String? _extractMetadataValue(Map<String, dynamic>? metadata, String key) {
    if (metadata == null) return null;
    final value = metadata[key]?['value'];
    if (value == null) return null;

    // The API sometimes returns HTML-formatted text, try to extract plain text
    final text = value
        .toString()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    return text.isEmpty ? null : text;
  }

  /// Gets detailed information about a specific image
  /// This includes metadata like description, license, and attribution
  Future<CommonsImage?> getImageInfo(String imageTitle, {int? thumbnailHeight}) async {
    _checkDisposed();

    final queryParams = {
      'action': 'query',
      'format': 'json',
      'titles': imageTitle,
      'prop': 'imageinfo|info',
      'iiprop': 'url|size|mime|extmetadata|mediatype',
      'iiurlheight': (thumbnailHeight ?? defaultThumbnailHeight).toString(),
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

      // If we don't have basic info, return null
      if (imageInfo == null || imageInfo.isEmpty) {
        return null;
      }

      final info = imageInfo.first as Map<String, dynamic>;
      final metadata = info['extmetadata'] as Map<String, dynamic>?;
      final url = info['url'] as String?;
      final width = info['width'] as int?;
      final height = info['height'] as int?;
      final mimeType = info['mime'] as String?;

      // If any of the required fields are missing, return null
      if (url == null || width == null || height == null || mimeType == null) {
        return null;
      }

      // Create the image with available metadata
      final artistInfo = _extractArtistInfo(metadata);
      final gpsCoordinates = _extractGpsCoordinates(metadata);
      final fileSize = info['size'] as int?;

      return CommonsImage(
        title: imageTitle.replaceFirst('File:', ''),
        fullTitle: imageTitle,
        url: url,
        thumbUrl: info['thumburl'] as String? ?? url,
        width: width,
        height: height,
        mimeType: mimeType,
        description: _extractMetadataValue(metadata, 'ImageDescription'),
        license: _extractMetadataValue(metadata, 'LicenseShortName'),
        licenseUrl: metadata?['LicenseUrl']?['value'] as String?,
        artistName: artistInfo['name'],
        artistUrl: artistInfo['url'],
        attribution: _extractMetadataValue(metadata, 'Attribution'),
        latitude: gpsCoordinates['latitude'],
        longitude: gpsCoordinates['longitude'],
        fileSize: fileSize,
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
  Future<List<CommonsImage>> searchImages(String keyword, {int? thumbnailHeight}) async {
    _checkDisposed();

    final queryParams = {
      'action': 'query',
      'format': 'json',
      'generator': 'search',
      'gsrnamespace': '6', // File namespace
      'gsrsearch': 'filetype:bitmap|drawing $keyword', // Exclude non-image files
      'gsrlimit': '50',
      'prop': 'imageinfo|categories',
      'iiprop': 'url|size|mime|extmetadata|mediatype',
      'iiurlheight': (thumbnailHeight ?? defaultThumbnailHeight).toString(),
      'clcategories': 'Category:Icons|Category:Templates',
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
        final url = imageInfo['url'] as String?;
        final mimeType = imageInfo['mime'] as String?;

        if (width == null || height == null || url == null || mimeType == null) continue;

        final metadata = imageInfo['extmetadata'] as Map<String, dynamic>?;
        final artistInfo = _extractArtistInfo(metadata);

        result.add(CommonsImage(
          title: imageTitle.replaceFirst('File:', ''),
          fullTitle: imageTitle,
          url: url,
          thumbUrl: imageInfo['thumburl'] as String? ?? url,
          width: width,
          height: height,
          mimeType: mimeType,
          description: _extractMetadataValue(metadata, 'ImageDescription'),
          license: _extractMetadataValue(metadata, 'LicenseShortName'),
          licenseUrl: metadata?['LicenseUrl']?['value'] as String?,
          artistName: artistInfo['name'],
          artistUrl: artistInfo['url'],
          attribution: _extractMetadataValue(metadata, 'Attribution'),
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

  /// Creates a thumbnail URL for a Wikimedia image
  ///
  /// Takes a Wikimedia image URL and returns a URL for a resized thumbnail.
  /// The thumbnail will be resized to the specified width while maintaining aspect ratio.
  ///
  /// Note: This functionality relies on undocumented Wikimedia URL patterns and may break
  /// in the future if Wikimedia changes their thumbnail URL structure.
  ///
  /// The resulting file is always JPEG, PNG or GIF:
  /// - SVG images are converted to PNG
  /// - GIF and PNG files keep their original format
  /// - All other formats are converted to JPEG
  ///
  /// Throws [ArgumentError] if:
  /// - Width is not specified
  /// - Width is less than 1
  /// - The URL is not a valid Wikimedia image URL
  ///
  /// Example:
  /// ```dart
  /// final thumbUrl = WikimediaApiWrapper.getThumbnailUrl(
  ///   'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.jpg',
  ///   width: 800,
  /// );
  /// ```
  static String getThumbnailUrl(
    String imageUrl, {
    required int width,
  }) {
    // Validate input
    if (width < 1) {
      throw ArgumentError.value(width, 'width', 'Width must be greater than 0');
    }

    // Check if this is a Wikimedia URL
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      throw ArgumentError.value(imageUrl, 'imageUrl', 'Not a Wikimedia URL');
    }

    final isWikimediaUrl = uri.host == 'upload.wikimedia.org' || uri.host == 'commons.wikimedia.org';
    if (!isWikimediaUrl) {
      throw ArgumentError.value(imageUrl, 'imageUrl', 'Not a Wikimedia URL');
    }

    // Extract the filename and hash from the path
    final segments = uri.pathSegments;
    if (segments.length < 4) {
      throw ArgumentError.value(imageUrl, 'imageUrl', 'Invalid Wikimedia URL format');
    }

    final filename = segments.last;
    if (!filename.contains('.')) {
      throw ArgumentError.value(filename, 'filename', 'Invalid filename format');
    }

    // Get the hash parts from the URL
    final hash1 = segments[segments.length - 3];
    final hash2 = segments[segments.length - 2];

    // Determine output extension based on input
    final inputExtension = filename.split('.').last.toLowerCase();
    final outputExtension = inputExtension == 'svg'
        ? 'png'
        : (inputExtension == 'gif' || inputExtension == 'png')
            ? inputExtension
            : 'jpg';

    // Replace original extension with the output extension
    final baseFilename = filename.substring(0, filename.lastIndexOf('.'));
    final outputFilename = '$baseFilename.$outputExtension';

    // Base URL for thumbnails
    final baseUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/$hash1/$hash2/$filename';

    // Width-only format: <width>px-<filename>
    return '$baseUrl/${width}px-$outputFilename';
  }
}
