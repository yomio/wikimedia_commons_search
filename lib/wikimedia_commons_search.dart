/// A library for accessing Wikimedia Commons images and Wikipedia content.
///
/// This library provides functionality to:
/// - Search Wikipedia topics and retrieve their images
/// - Search Wikimedia Commons images directly
/// - Get detailed image information and metadata
/// - Generate thumbnail URLs for Wikimedia images
///
/// ## Getting Started
///
/// Create an instance of [WikimediaCommons] to start using the library:
///
/// ```dart
/// final commons = WikimediaCommons();
/// ```
///
/// Remember to dispose the instance when you're done:
///
/// ```dart
/// commons.dispose();
/// ```
///
/// ## Features
///
/// ### Topic Search
/// Search for Wikipedia topics and get their associated images:
///
/// ```dart
/// final topics = await commons.searchTopics('Eiffel Tower');
/// final images = await commons.getTopicImages(topics.first.id);
/// ```
///
/// ### Direct Image Search
/// Search for images directly on Wikimedia Commons:
///
/// ```dart
/// final images = await commons.searchImages('Eiffel Tower');
/// ```
///
/// ### Thumbnail Generation
/// Generate thumbnail URLs for any Wikimedia image:
///
/// ```dart
/// final thumbUrl = WikimediaCommons.getThumbnailUrl(
///   'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.jpg',
///   width: 800,
/// );
/// ```
///
/// ## Error Handling
///
/// The library provides several exception types:
/// - [WikimediaNoResultsException] when no results are found
/// - [WikimediaNoImagesException] when no images are found for a topic
/// - [WikimediaApiException] for API-related errors
/// - [ResponseParsingException] for malformed responses
/// - [DisposedException] when using a disposed instance
///
/// ## License Notice
///
/// This library is a tool for accessing Wikimedia content and does not handle content licensing.
/// When using content from Wikipedia or Wikimedia Commons, you must observe and comply with
/// Wikimedia's licensing terms. Different content pieces may have different licenses.
///
/// For more information, visit:
/// - [Wikimedia Commons Licensing](https://commons.wikimedia.org/wiki/Commons:Licensing)
/// - [Wikimedia Terms of Use](https://foundation.wikimedia.org/wiki/Terms_of_Use)
///
/// Topics: http, api, network, search, wikipedia, wikimedia, commons
library wikimedia_commons_search;

import 'package:wikimedia_commons_search/src/exceptions.dart'
    show
        WikimediaNoResultsException,
        WikimediaNoImagesException,
        WikimediaApiException,
        ResponseParsingException,
        DisposedException;
import 'package:wikimedia_commons_search/src/wikimedia_commons.dart' show WikimediaCommons;
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart'
    show
        WikimediaCommons,
        WikimediaNoResultsException,
        WikimediaNoImagesException,
        WikimediaApiException,
        ResponseParsingException,
        DisposedException;

export 'src/wikimedia_commons.dart';
export 'src/models/topic.dart';
export 'src/models/commons_image.dart';
export 'src/exceptions.dart';
