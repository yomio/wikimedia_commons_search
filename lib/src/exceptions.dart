/// Custom exceptions for the Wikimedia Commons Search library.
library;

/// Base exception class for all Wikimedia Commons Search related errors.
class WikimediaCommonsException implements Exception {
  /// Creates a new [WikimediaCommonsException].
  const WikimediaCommonsException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'WikimediaCommonsException: $message';
}

/// Thrown when an API request fails.
class WikimediaApiException extends WikimediaCommonsException {
  /// Creates a new [WikimediaApiException].
  const WikimediaApiException(
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
    final parts = <String>['WikimediaApiException: $message'];
    if (statusCode != null) parts.add('Status code: $statusCode');
    if (endpoint != null) parts.add('Endpoint: $endpoint');
    return parts.join(', ');
  }
}

/// Thrown when no results are found for a search query.
class NoResultsException extends WikimediaCommonsException {
  /// Creates a new [NoResultsException].
  const NoResultsException([String? message]) : super(message ?? 'No results found for the given query');
}

/// Thrown when there's an issue with parsing the API response.
class ResponseParsingException extends WikimediaCommonsException {
  /// Creates a new [ResponseParsingException].
  const ResponseParsingException([String? message]) : super(message ?? 'Failed to parse API response');
}

/// Thrown when trying to use a disposed instance.
class DisposedException extends WikimediaCommonsException {
  /// Creates a new [DisposedException].
  const DisposedException([String? message]) : super(message ?? 'Instance has been disposed and cannot be used');
}
