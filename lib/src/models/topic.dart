import 'package:equatable/equatable.dart';

/// Represents a Wikipedia topic with its metadata
class Topic extends Equatable {
  /// Creates a new Topic instance
  const Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.wordCount,
    required this.size,
    required this.imageCount,
  });

  /// Creates a Topic instance from a JSON map
  factory Topic.fromJson(Map<String, dynamic> json) {
    final description = json['description'] as String? ?? '';
    final timestamp = json['timestamp'] as String? ?? DateTime.now().toIso8601String();

    return Topic(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      description: description,
      timestamp: timestamp,
      wordCount:
          json['wordCount'] as int? ?? description.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length,
      size: json['size'] as int? ?? 0,
      imageCount: json['imageCount'] as int? ?? 0,
    );
  }

  /// The unique identifier of the topic
  final String id;

  /// The title of the topic
  final String title;

  /// A brief description of the topic
  final String description;

  /// The timestamp when the topic was last modified
  final String timestamp;

  /// The number of words in the topic's description
  final int wordCount;

  /// The size of the topic's content in bytes
  final int size;

  /// The number of images associated with this topic
  final int imageCount;

  /// Converts the Topic instance to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'timestamp': timestamp,
        'wordCount': wordCount,
        'size': size,
        'imageCount': imageCount,
      };

  /// Gets the timestamp as a DateTime object
  DateTime get dateTime => DateTime.parse(timestamp);

  /// Creates a copy of this Topic with the given fields replaced with new values
  Topic copyWith({
    String? id,
    String? title,
    String? description,
    String? timestamp,
    int? wordCount,
    int? size,
    int? imageCount,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      wordCount: wordCount ?? this.wordCount,
      size: size ?? this.size,
      imageCount: imageCount ?? this.imageCount,
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
      ];

  @override
  String toString() => 'Topic(id: $id, title: $title, wordCount: $wordCount)';
}
