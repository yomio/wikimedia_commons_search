import 'package:http/http.dart' as http;
import 'wikimedia_api_wrapper.dart';
import 'models/topic.dart';
import 'models/commons_image.dart';
import 'exceptions.dart';

/// Main class for accessing Wikimedia Commons images and Wikipedia content.
///
/// This class provides methods to:
/// - Search Wikipedia topics by keywords
/// - Retrieve images associated with specific topics
/// - Search for images directly on Wikimedia Commons
/// - Get detailed image information
/// - Generate thumbnail URLs
///
/// Example usage:
/// ```dart
/// final commons = WikimediaCommons();
///
/// // Search for topics
/// try {
///   final topics = await commons.searchTopics('Eiffel Tower');
///   // Handle topics...
/// } on WikimediaNoResultsException catch (e) {
///   print('No topics found: ${e.message}');
/// }
///
/// // Get images for a topic
/// try {
///   final images = await commons.getTopicImages(topics.first.id);
///   // Handle images...
/// } on WikimediaNoImagesException catch (e) {
///   print('No images found: ${e.message}');
/// }
///
/// // Search for images directly on Commons
/// try {
///   final images = await commons.searchImages('Eiffel Tower');
///   // Handle images...
/// } on WikimediaCommonsException catch (e) {
///   print('Error: ${e.message}');
/// }
///
/// // Get a thumbnail URL
/// final thumbUrl = WikimediaCommons.getThumbnailUrl(
///   'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.jpg',
///   width: 800,
/// );
///
/// // Don't forget to dispose when done
/// commons.dispose();
/// ```
///
/// The class automatically manages HTTP connections and should be disposed of
/// when no longer needed using the [dispose] method.
class WikimediaCommons {
  /// Creates a new instance of WikimediaCommons
  ///
  /// Parameters:
  ///   - client: Optional HTTP client to use for requests
  ///   - defaultThumbnailHeight: Default height for image thumbnails (default: 200)
  WikimediaCommons({
    http.Client? client,
    int defaultThumbnailHeight = 200,
  }) : _api = WikimediaApiWrapper(
          client: client,
          defaultThumbnailHeight: defaultThumbnailHeight,
        );

  final WikimediaApiWrapper _api;

  /// Searches for Wikipedia topics based on the given keyword.
  /// Returns a list of topics with their descriptions.
  ///
  /// The topics are sorted by relevance.
  /// Each topic includes basic metadata like title, description, word count, and size.
  ///
  /// Parameters:
  ///   - query: The search term to find Wikipedia topics
  ///   - limit: Maximum number of results to return (default: 10)
  ///
  /// Throws:
  /// - [WikimediaNoResultsException] if no topics are found for the query
  /// - [WikimediaApiException] if the API request fails or for general errors
  /// - [ResponseParsingException] if the API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<List<WikipediaTopic>> searchTopics(String query, {int? limit}) async {
    try {
      return await _api.searchTopics(query, limit: limit);
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to search topics: $e');
    }
  }

  /// Gets all images linked to a specific Wikipedia topic.
  /// Returns a list of images with their metadata.
  ///
  /// The images are filtered to exclude utility images (flags, icons, logos, etc.)
  /// and sorted with larger files first.
  ///
  /// Parameters:
  ///   - topicId: The Wikipedia page ID to get images from
  ///   - thumbnailHeight: Optional height for image thumbnails
  ///
  /// Throws:
  /// - [WikimediaNoImagesException] if no suitable images are found for the topic
  /// - [WikimediaApiException] if the API request fails or for general errors
  /// - [ResponseParsingException] if the API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<List<CommonsImage>> getTopicImages(
    String topicId, {
    int? thumbnailHeight,
  }) async {
    try {
      final images = await _api.getTopicImages(topicId, thumbnailHeight: thumbnailHeight);
      if (images.isEmpty) {
        throw WikimediaNoImagesException('No images found for topic: $topicId');
      }
      return images;
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to get topic images: $e');
    }
  }

  /// Gets detailed information about a specific image.
  /// Returns the image with all available metadata.
  ///
  /// Parameters:
  ///   - imageTitle: The full image title (with 'File:' prefix)
  ///   - thumbnailHeight: Optional height for image thumbnail
  ///
  /// Returns:
  ///   A [CommonsImage] object with image details, or null if not found.
  ///
  /// Throws:
  /// - [WikimediaApiException] if the API request fails
  /// - [ResponseParsingException] if the API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<CommonsImage?> getImageInfo(
    String imageTitle, {
    int? thumbnailHeight,
  }) async {
    try {
      return await _api.getImageInfo(imageTitle, thumbnailHeight: thumbnailHeight);
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to get image info: $e');
    }
  }

  /// Searches for images directly on Wikimedia Commons.
  /// Returns a list of images with their metadata.
  ///
  /// The images are filtered to exclude utility images and sorted by relevance.
  ///
  /// Parameters:
  ///   - query: The search term to find images
  ///   - thumbnailHeight: Optional height for image thumbnails
  ///
  /// Throws:
  /// - [WikimediaNoResultsException] if no images are found for the query
  /// - [WikimediaApiException] if the API request fails
  /// - [ResponseParsingException] if the API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<List<CommonsImage>> searchImages(
    String query, {
    int? thumbnailHeight,
  }) async {
    try {
      return await _api.searchImages(query, thumbnailHeight: thumbnailHeight);
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to search images: $e');
    }
  }

  /// Creates a thumbnail URL for a Wikimedia image.
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
  /// Parameters:
  ///   - imageUrl: The original Wikimedia image URL
  ///   - width: Desired width of the thumbnail in pixels
  ///
  /// Throws [ArgumentError] if:
  /// - Width is not specified
  /// - Width is less than 1
  /// - The URL is not a valid Wikimedia image URL
  ///
  /// Example:
  /// ```dart
  /// final thumbUrl = WikimediaCommons.getThumbnailUrl(
  ///   'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.jpg',
  ///   width: 800,
  /// );
  /// ```
  static String getThumbnailUrl(
    String imageUrl, {
    required int width,
  }) {
    return WikimediaApiWrapper.getThumbnailUrl(imageUrl, width: width);
  }

  /// Disposes the HTTP client and frees associated resources.
  ///
  /// This method should be called when the instance is no longer needed to prevent
  /// resource leaks. After calling dispose:
  /// - The instance should not be used anymore
  /// - Any attempt to use this instance will throw a [DisposedException]
  /// - Calling dispose multiple times has no effect
  void dispose() {
    _api.dispose();
  }
}
