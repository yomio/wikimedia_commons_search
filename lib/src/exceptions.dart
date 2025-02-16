/// Custom exceptions for the Wikimedia Commons Search library.
library;

/// Base exception class for all Wikimedia Commons related errors
abstract class WikimediaCommonsException implements Exception {
  WikimediaCommonsException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Thrown when the API request fails
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

/// Thrown when no results are found for a search query
class WikimediaNoResultsException extends WikimediaCommonsException {
  WikimediaNoResultsException(super.message);
}

/// Thrown when no images are found for a topic
class WikimediaNoImagesException extends WikimediaCommonsException {
  WikimediaNoImagesException(super.message);
}

/// Thrown when there's an issue with parsing the API response.
class ResponseParsingException extends WikimediaCommonsException {
  /// Creates a new [ResponseParsingException].
  ResponseParsingException([String? message]) : super(message ?? 'Failed to parse API response');
}

/// Thrown when trying to use a disposed instance.
class DisposedException extends WikimediaCommonsException {
  /// Creates a new [DisposedException].
  DisposedException([String? message]) : super(message ?? 'Instance has been disposed and cannot be used');
}
