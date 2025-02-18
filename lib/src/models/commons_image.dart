import 'package:equatable/equatable.dart';

/// Represents an image from Wikimedia Commons with its metadata
class CommonsImage extends Equatable {
  /// Creates a new CommonsImage instance
  const CommonsImage({
    required this.title,
    required this.fullTitle,
    required this.url,
    required this.thumbUrl,
    required this.width,
    required this.height,
    required this.mimeType,
    this.description,
    this.license,
    this.licenseUrl,
    this.artistName,
    this.artistUrl,
    this.attribution,
    this.latitude,
    this.longitude,
    this.fileSize,
    this.priority = 0,
  });

  /// Creates a CommonsImage instance from a JSON map
  factory CommonsImage.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String?;
    final width = json['width'] as int?;
    final height = json['height'] as int?;
    final mimeType = json['mimeType'] as String?;

    // Return null if required fields are missing
    if (url == null || width == null || height == null || mimeType == null) {
      throw FormatException('Missing required fields in CommonsImage JSON');
    }

    return CommonsImage(
      title: json['title'] as String? ?? '',
      fullTitle: json['fullTitle'] as String? ?? '',
      url: url,
      thumbUrl: json['thumbUrl'] as String? ?? url,
      width: width,
      height: height,
      mimeType: mimeType,
      description: json['description'] as String?,
      license: json['license'] as String?,
      licenseUrl: json['licenseUrl'] as String?,
      artistName: json['artistName'] as String?,
      artistUrl: json['artistUrl'] as String?,
      attribution: json['attribution'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      fileSize: json['fileSize'] as int?,
      priority: json['priority'] as int? ?? 0,
    );
  }

  /// Creates a basic CommonsImage instance with only essential information
  factory CommonsImage.basic({
    required String title,
    required String fullTitle,
    required String url,
    String? thumbUrl,
  }) {
    return CommonsImage(
      title: title,
      fullTitle: fullTitle,
      url: url,
      thumbUrl: thumbUrl ?? url,
      width: 0, // Default values since this is a basic constructor
      height: 0,
      mimeType: 'image/jpeg', // Default MIME type
    );
  }

  /// The title of the image without the 'File:' prefix
  final String title;

  /// The full title of the image including the 'File:' prefix
  final String fullTitle;

  /// Direct URL to the full image
  final String url;

  /// URL to a thumbnail version of the image
  final String thumbUrl;

  /// Original image width in pixels
  final int width;

  /// Original image height in pixels
  final int height;

  /// Image MIME type (e.g., 'image/jpeg')
  final String mimeType;

  /// Image description from Commons
  final String? description;

  /// Image license information (e.g., "CC BY-SA 4.0")
  final String? license;

  /// URL to the license details
  final String? licenseUrl;

  /// Name of the artist/creator
  final String? artistName;

  /// URL to the artist's page
  final String? artistUrl;

  /// Image attribution information
  final String? attribution;

  /// Latitude of the location where the image was taken (if available)
  final double? latitude;

  /// Longitude of the location where the image was taken (if available)
  final double? longitude;

  /// Size of the image file in bytes
  final int? fileSize;

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
        licenseUrl,
        artistName,
        artistUrl,
        attribution,
        latitude,
        longitude,
        fileSize,
        priority,
      ];

  @override
  String toString() => 'CommonsImage(title: $title, url: $url)';

  /// Converts the instance to a JSON map
  Map<String, dynamic> toJson() => {
        'title': title,
        'fullTitle': fullTitle,
        'url': url,
        'thumbUrl': thumbUrl,
        'width': width,
        'height': height,
        'mimeType': mimeType,
        if (description != null) 'description': description,
        if (license != null) 'license': license,
        if (licenseUrl != null) 'licenseUrl': licenseUrl,
        if (artistName != null) 'artistName': artistName,
        if (artistUrl != null) 'artistUrl': artistUrl,
        if (attribution != null) 'attribution': attribution,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (fileSize != null) 'fileSize': fileSize,
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
    String? licenseUrl,
    String? artistName,
    String? artistUrl,
    String? attribution,
    double? latitude,
    double? longitude,
    int? fileSize,
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
      licenseUrl: licenseUrl ?? this.licenseUrl,
      artistName: artistName ?? this.artistName,
      artistUrl: artistUrl ?? this.artistUrl,
      attribution: attribution ?? this.attribution,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fileSize: fileSize ?? this.fileSize,
      priority: priority ?? this.priority,
    );
  }
}
