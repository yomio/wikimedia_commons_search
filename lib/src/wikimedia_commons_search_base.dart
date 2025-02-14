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
/// - Combine topic search and image retrieval in a single operation
///
/// Example usage:
/// ```dart
/// final search = WikimediaCommonsSearch();
///
/// // Search for topics
/// try {
///   final topics = await search.searchTopics('Eiffel Tower');
///   // Handle topics...
/// } on NoResultsException catch (e) {
///   print('No topics found: ${e.message}');
/// } on WikimediaApiException catch (e) {
///   print('API error: ${e.message}');
/// }
///
/// // Get images for a topic
/// try {
///   final images = await search.getTopicImages(topics.first.id);
///   // Handle images...
/// } on NoResultsException catch (e) {
///   print('No images found: ${e.message}');
/// }
///
/// // Or use the convenience method to do both in one call
/// try {
///   final images = await search.searchAndGetImages('Eiffel Tower');
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

  void _checkDisposed() {
    if (_isDisposed) {
      throw const DisposedException();
    }
  }

  /// Searches for Wikipedia topics based on the given keyword
  /// Returns a list of topics with their descriptions
  ///
  /// Throws:
  /// - [NoResultsException] if no topics are found
  /// - [WikimediaApiException] if the API request fails
  /// - [ResponseParsingException] if the API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<List<Topic>> searchTopics(String keyword) async {
    _checkDisposed();
    return _api.searchTopics(keyword);
  }

  /// Gets all images linked to a specific Wikipedia topic
  /// Returns a list of image URLs and their metadata
  ///
  /// Each image contains:
  /// - title: The image title
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
  /// Throws:
  /// - [NoResultsException] if no images are found
  /// - [WikimediaApiException] if the API request fails
  /// - [ResponseParsingException] if the API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<List<CommonsImage>> getTopicImages(String topicId) async {
    _checkDisposed();
    return _api.getTopicImages(topicId);
  }

  /// Searches for topics matching the given keyword and returns images for the first matching topic.
  ///
  /// This is a convenience method that combines [searchTopics] and [getTopicImages] into a single call.
  ///
  /// Parameters:
  ///   - keyword: The search term to find Wikipedia topics
  ///
  /// Returns:
  ///   A list of [CommonsImage] objects associated with the first matching topic.
  ///
  /// Throws:
  /// - [NoResultsException] if no topics or images are found
  /// - [WikimediaApiException] if any API request fails
  /// - [ResponseParsingException] if any API response cannot be parsed
  /// - [DisposedException] if the instance has been disposed
  Future<List<CommonsImage>> searchAndGetImages(String keyword) async {
    _checkDisposed();
    final topics = await searchTopics(keyword);
    return getTopicImages(topics.first.id);
  }

  /// Disposes the HTTP client and frees associated resources.
  ///
  /// This method should be called when the instance is no longer needed to prevent
  /// resource leaks. After calling dispose, the instance should not be used anymore.
  /// Calling dispose multiple times has no effect.
  ///
  /// After disposal, any attempt to use this instance will throw a [DisposedException].
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _api.dispose();
  }
}
