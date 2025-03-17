import 'package:equatable/equatable.dart';

/// Represents a Wikipedia topic with its metadata.
///
/// This class encapsulates information about a Wikipedia topic, including its
/// content metadata, description, and statistics about its content.
///
/// Example usage:
/// ```dart
/// final topic = WikipediaTopic(
///   id: 'Q243',
///   title: 'Eiffel Tower',
///   description: 'Wrought-iron lattice tower in Paris, France',
///   timestamp: '2024-03-21T12:00:00Z',
///   wordCount: 42,
///   size: 15000,
///   imageCount: 5,
///   url: 'https://en.wikipedia.org/wiki/Eiffel_Tower',
/// );
///
/// // Access topic properties
/// print('Title: ${topic.title}');
/// print('Description: ${topic.description}');
/// print('Last modified: ${topic.timestamp}');
/// print('Has images: ${topic.imageCount > 0}');
/// ```
///
/// ## Properties
///
/// ### Required Properties
/// - [id]: The unique identifier of the topic
/// - [title]: The title of the topic
/// - [description]: A brief description of the topic
/// - [timestamp]: The timestamp when the topic was last modified
/// - [wordCount]: The number of words in the topic's content
/// - [size]: The size of the topic's content in bytes
/// - [imageCount]: The number of images in the topic
///
/// ### Optional Properties
/// - [url]: The URL to the topic's Wikipedia page
///
/// ## JSON Serialization
///
/// The class provides [fromJson] factory constructor for creating instances
/// from JSON data. It handles missing or invalid data gracefully:
/// - Missing description defaults to empty string
/// - Missing timestamp defaults to current time
/// - Missing word count is calculated from description
/// - Missing size defaults to 0
/// - Missing image count defaults to 0
class WikipediaTopic extends Equatable {
  /// Creates a new Topic instance
  const WikipediaTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.wordCount,
    required this.size,
    required this.imageCount,
    this.url,
  });

  /// Creates a Topic instance from a JSON map.
  ///
  /// Handles missing or invalid data with sensible defaults:
  /// - Missing description → empty string
  /// - Missing timestamp → current time
  /// - Missing word count → calculated from description
  /// - Missing size → 0
  /// - Missing image count → 0
  factory WikipediaTopic.fromJson(Map<String, dynamic> json) {
    final description = json['description'] as String? ?? '';
    final timestamp = json['timestamp'] as String? ?? DateTime.now().toIso8601String();

    return WikipediaTopic(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      description: description,
      timestamp: timestamp,
      wordCount:
          json['wordCount'] as int? ?? description.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length,
      size: json['size'] as int? ?? 0,
      imageCount: json['imageCount'] as int? ?? 0,
      url: json['url'] as String?,
    );
  }

  /// The unique identifier of the topic from Wikipedia
  final String id;

  /// The title of the topic as it appears on Wikipedia
  final String title;

  /// A brief description or excerpt of the topic's content
  final String description;

  /// The ISO 8601 timestamp when the topic was last modified
  final String timestamp;

  /// The number of words in the topic's content
  final int wordCount;

  /// The size of the topic's content in bytes
  final int size;

  /// The number of images associated with the topic
  final int imageCount;

  /// The URL to the topic's Wikipedia page (optional)
  final String? url;

  /// Converts the Topic instance to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'timestamp': timestamp,
        'wordCount': wordCount,
        'size': size,
        'imageCount': imageCount,
        if (url != null) 'url': url,
      };

  /// Gets the timestamp as a DateTime object
  DateTime get dateTime => DateTime.parse(timestamp);

  /// Creates a copy of this Topic with the given fields replaced with new values
  WikipediaTopic copyWith({
    String? id,
    String? title,
    String? description,
    String? timestamp,
    int? wordCount,
    int? size,
    int? imageCount,
    String? url,
  }) {
    return WikipediaTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      wordCount: wordCount ?? this.wordCount,
      size: size ?? this.size,
      imageCount: imageCount ?? this.imageCount,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        timestamp,
        wordCount,
        size,
        imageCount,
        url,
      ];

  @override
  String toString() => 'Topic(id: $id, title: $title, wordCount: $wordCount)';
}
