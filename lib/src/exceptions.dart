/// Custom exceptions for the Wikimedia Commons Search library.
///
/// This library provides a set of custom exceptions for handling various error
/// scenarios when working with the Wikimedia Commons API. Each exception type
/// represents a specific category of errors that can occur during API operations.
///
/// Example usage:
/// ```dart
/// try {
///   final images = await commons.searchImages('');
/// } on WikimediaNoResultsException catch (e) {
///   print('No results found: ${e.message}');
/// } on WikimediaApiException catch (e) {
///   print('API error: ${e.message}, Status: ${e.statusCode}');
/// }
/// ```
library;

import 'package:wikimedia_commons_search/src/wikimedia_commons.dart' show WikimediaCommons;
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart' show WikimediaCommons;

/// Base exception class for all Wikimedia Commons related errors.
///
/// This is an abstract class that serves as the base for all custom exceptions
/// in the library. It implements the standard Dart [Exception] interface and
/// provides a message property that describes the error.
abstract class WikimediaCommonsException implements Exception {
  WikimediaCommonsException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Thrown when an API request fails due to network, authentication, or server errors.
///
/// This exception includes additional context about the failed request, such as
/// the HTTP status code and the API endpoint that was called. It's thrown in cases like:
/// - Network connectivity issues
/// - Invalid API requests
/// - Server-side errors
/// - Rate limiting
///
/// Example:
/// ```dart
/// try {
///   final topics = await commons.searchTopics('query');
/// } on WikimediaApiException catch (e) {
///   if (e.statusCode == 429) {
///     print('Rate limit exceeded');
///   } else {
///     print('API error: ${e.message}');
///   }
/// }
/// ```
class WikimediaApiException extends WikimediaCommonsException {
  /// Creates a new [WikimediaApiException].
  WikimediaApiException(
    super.message, {
    this.statusCode,
    this.endpoint,
  });

  /// The HTTP status code of the failed request.
  final int? statusCode;

  /// The API endpoint that was called.
  final String? endpoint;

  @override
  String toString() {
    final parts = <String>[message];
    if (statusCode != null) parts.add('Status code: $statusCode');
    if (endpoint != null) parts.add('Endpoint: $endpoint');
    return parts.join(', ');
  }
}

/// Thrown when a search query returns no results.
///
/// This exception is thrown when:
/// - A topic search finds no matching Wikipedia articles
/// - An image search finds no matching images on Wikimedia Commons
/// - The search query is empty or contains only stop words
///
/// Example:
/// ```dart
/// try {
///   final topics = await commons.searchTopics('xyzabc123');
/// } on WikimediaNoResultsException catch (e) {
///   print('No topics found: ${e.message}');
/// }
/// ```
class WikimediaNoResultsException extends WikimediaCommonsException {
  WikimediaNoResultsException(super.message);
}

/// Thrown when no suitable images are found for a topic.
///
/// This exception is thrown when:
/// - A topic has no associated images
/// - All associated images are filtered out (e.g., utility images)
/// - The topic ID is invalid or the topic no longer exists
///
/// Example:
/// ```dart
/// try {
///   final images = await commons.getTopicImages('Q123');
/// } on WikimediaNoImagesException catch (e) {
///   print('No images available: ${e.message}');
/// }
/// ```
class WikimediaNoImagesException extends WikimediaCommonsException {
  WikimediaNoImagesException(super.message);
}

/// Thrown when there's an issue with parsing the API response.
///
/// This exception is thrown when:
/// - The API response is not valid JSON
/// - Required fields are missing in the response
/// - Field values have unexpected types
/// - The response structure doesn't match the expected schema
///
/// Example:
/// ```dart
/// try {
///   final topics = await commons.searchTopics('query');
/// } on ResponseParsingException catch (e) {
///   print('Failed to parse response: ${e.message}');
/// }
/// ```
class ResponseParsingException extends WikimediaCommonsException {
  /// Creates a new [ResponseParsingException].
  ResponseParsingException([String? message]) : super(message ?? 'Failed to parse API response');
}

/// Thrown when attempting to use a disposed [WikimediaCommons] instance.
///
/// This exception is thrown when:
/// - Any method is called after [dispose] has been called
/// - The instance has been garbage collected
///
/// Example:
/// ```dart
/// final commons = WikimediaCommons();
/// commons.dispose();
///
/// try {
///   await commons.searchImages('query');
/// } on DisposedException catch (e) {
///   print('Instance is disposed: ${e.message}');
/// }
/// ```
class DisposedException extends WikimediaCommonsException {
  DisposedException() : super('This WikimediaCommons instance has been disposed');
}
