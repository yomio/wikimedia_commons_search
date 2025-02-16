import 'package:http/http.dart' as http;
import 'wikimedia_api_wrapper.dart';
import 'models/topic.dart';
import 'models/commons_image.dart';
import 'exceptions.dart';

/// A class that provides methods to search Wikipedia topics and retrieve associated
/// Wikimedia Commons images.
///
/// This class serves as the main entry point for the library, offering methods to:
/// - Search Wikipedia topics by keywords
/// - Retrieve images associated with specific topics
/// - Search for images directly
///
/// Example usage:
/// ```dart
/// final search = WikimediaCommonsSearch();
///
/// // Search for topics
/// try {
///   final topics = await search.searchTopics('Eiffel Tower');
///   // Handle topics...
/// } on WikimediaNoResultsException catch (e) {
///   print('No topics found: ${e.message}');
/// } on WikimediaApiException catch (e) {
///   print('API error: ${e.message}');
/// }
///
/// // Get images for a topic
/// try {
///   final images = await search.getTopicImages(topics.first.id);
///   // Handle images...
/// } on WikimediaNoImagesException catch (e) {
///   print('No images found: ${e.message}');
/// }
///
/// // Or search for images directly
/// try {
///   final images = await search.searchImages('Eiffel Tower');
///   // Handle images...
/// } on WikimediaCommonsException catch (e) {
///   print('Error: ${e.message}');
/// }
///
/// // Don't forget to dispose when done
/// search.dispose();
/// ```
///
/// The class automatically manages HTTP connections and should be disposed of
/// when no longer needed using the [dispose] method.
class WikimediaCommonsSearch {
  /// Creates a new instance of WikimediaCommonsSearch
  WikimediaCommonsSearch({http.Client? client}) : _api = WikimediaApiWrapper(client: client);

  final WikimediaApiWrapper _api;
  bool _isDisposed = false;

  /// Gets access to the underlying API wrapper
  WikimediaApiWrapper get api => _api;

  /// Searches for Wikipedia topics based on the given keyword.
  /// Returns a list of topics with their descriptions.
  ///
  /// The topics are sorted by relevance and limited to 10 results.
  /// Each topic includes basic metadata like title, description, word count, and size.
  ///
  /// Parameters:
  ///   - query: The search term to find Wikipedia topics
  ///
  /// Throws:
  /// - [WikimediaNoResultsException] if no topics are found for the query
  /// - [WikimediaApiException] if the API request fails or for general errors
  /// - [ResponseParsingException] if the API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<List<Topic>> searchTopics(String query) async {
    try {
      return await _api.searchTopics(query);
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to search topics: $e');
    }
  }

  /// Gets all images linked to a specific Wikipedia topic.
  /// Returns a list of images with their metadata.
  ///
  /// The images are filtered to exclude utility images (flags, icons, logos, etc.)
  /// and sorted with non-SVG images before SVG images, and larger files first.
  ///
  /// Each image contains:
  /// - title: The image title without 'File:' prefix
  /// - fullTitle: The full image title including 'File:' prefix
  /// - url: Direct URL to the full image
  /// - thumbUrl: URL to an 800px wide thumbnail (if available)
  /// - width: Original image width
  /// - height: Original image height
  /// - mimeType: Image MIME type (e.g., 'image/jpeg')
  /// - description: Image description (if available)
  /// - license: Image license information (if available)
  /// - attribution: Image attribution information (if available)
  ///
  /// Parameters:
  ///   - topicId: The Wikipedia page ID to get images from
  ///
  /// Throws:
  /// - [WikimediaNoImagesException] if no suitable images are found for the topic
  /// - [WikimediaApiException] if the API request fails or for general errors
  /// - [ResponseParsingException] if the API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<List<CommonsImage>> getTopicImages(String topicId) async {
    try {
      final images = await _api.getTopicImages(topicId);
      if (images.isEmpty) {
        throw WikimediaNoImagesException('No images found for topic: $topicId');
      }
      return images;
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to get topic images: $e');
    }
  }

  /// Searches for images by first finding a matching Wikipedia topic and then
  /// retrieving its images.
  ///
  /// This method:
  /// 1. Searches for topics matching the query
  /// 2. Takes the first (most relevant) topic
  /// 3. Retrieves all images from that topic
  ///
  /// The returned images are filtered and sorted the same way as in [getTopicImages].
  ///
  /// Parameters:
  ///   - query: The search term to find Wikipedia topics and their images
  ///
  /// Returns:
  ///   A list of [CommonsImage] objects associated with the most relevant topic.
  ///
  /// Throws:
  /// - [WikimediaNoResultsException] if no topics are found for the query
  /// - [WikimediaNoImagesException] if no suitable images are found
  /// - [WikimediaApiException] if any API request fails or for general errors
  /// - [ResponseParsingException] if any API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<List<CommonsImage>> searchImages(String query) async {
    try {
      final topics = await searchTopics(query);
      if (topics.isEmpty) {
        throw WikimediaNoResultsException('No topics found for query: $query');
      }
      return await getTopicImages(topics.first.id);
    } catch (e) {
      if (e is WikimediaCommonsException) rethrow;
      throw WikimediaApiException('Failed to search and get images: $e');
    }
  }

  /// Disposes the HTTP client and frees associated resources.
  ///
  /// This method should be called when the instance is no longer needed to prevent
  /// resource leaks. After calling dispose:
  /// - The instance should not be used anymore
  /// - Any attempt to use this instance will throw a [DisposedException]
  /// - Calling dispose multiple times has no effect
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _api.dispose();
  }
}
