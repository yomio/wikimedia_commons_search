import 'package:equatable/equatable.dart';

/// Represents an image from Wikimedia Commons with its metadata
class CommonsImage extends Equatable {
  /// Creates a new CommonsImage instance
  const CommonsImage({
    required this.title,
    required this.fullTitle,
    this.url,
    this.thumbUrl,
    this.width,
    this.height,
    this.mimeType,
    this.description,
    this.license,
    this.attribution,
    this.priority = 0,
  });

  /// Creates a CommonsImage instance from a JSON map
  factory CommonsImage.fromJson(Map<String, dynamic> json) {
    return CommonsImage(
      title: json['title'] as String? ?? '',
      fullTitle: json['fullTitle'] as String? ?? '',
      url: json['url'] as String?,
      thumbUrl: json['thumbUrl'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      mimeType: json['mimeType'] as String?,
      description: json['description'] as String?,
      license: json['license'] as String?,
      attribution: json['attribution'] as String?,
      priority: json['priority'] as int? ?? 0,
    );
  }

  /// Creates a basic CommonsImage instance with only essential information
  factory CommonsImage.basic({
    required String title,
    required String fullTitle,
    String? url,
    String? thumbUrl,
  }) {
    return CommonsImage(
      title: title,
      fullTitle: fullTitle,
      url: url,
      thumbUrl: thumbUrl,
    );
  }

  /// The title of the image without the 'File:' prefix
  final String title;

  /// The full title of the image including the 'File:' prefix
  final String fullTitle;

  /// Direct URL to the full image
  final String? url;

  /// URL to a thumbnail version of the image
  final String? thumbUrl;

  /// Original image width in pixels
  final int? width;

  /// Original image height in pixels
  final int? height;

  /// Image MIME type (e.g., 'image/jpeg')
  final String? mimeType;

  /// Image description from Commons
  final String? description;

  /// Image license information
  final String? license;

  /// Image attribution information
  final String? attribution;

  /// Internal priority for sorting (not included in JSON)
  final int priority;

  @override
  List<Object?> get props => [
        title,
        fullTitle,
        url,
        thumbUrl,
        width,
        height,
        mimeType,
        description,
        license,
        attribution,
        priority,
      ];

  @override
  String toString() => 'CommonsImage(title: $title, url: $url)';

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() => {
        'title': title,
        'fullTitle': fullTitle,
        if (url != null) 'url': url,
        if (thumbUrl != null) 'thumbUrl': thumbUrl,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (mimeType != null) 'mimeType': mimeType,
        if (description != null) 'description': description,
        if (license != null) 'license': license,
        if (attribution != null) 'attribution': attribution,
      };

  /// Creates a copy of this CommonsImage with the given fields replaced with new values
  CommonsImage copyWith({
    String? title,
    String? fullTitle,
    String? url,
    String? thumbUrl,
    int? width,
    int? height,
    String? mimeType,
    String? description,
    String? license,
    String? attribution,
    int? priority,
  }) {
    return CommonsImage(
      title: title ?? this.title,
      fullTitle: fullTitle ?? this.fullTitle,
      url: url ?? this.url,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      mimeType: mimeType ?? this.mimeType,
      description: description ?? this.description,
      license: license ?? this.license,
      attribution: attribution ?? this.attribution,
      priority: priority ?? this.priority,
    );
  }
}
