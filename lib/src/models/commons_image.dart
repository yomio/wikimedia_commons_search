import 'package:equatable/equatable.dart';

/// Represents an image from Wikimedia Commons with its metadata.
///
/// This class encapsulates all the information about a Wikimedia Commons image,
/// including its metadata, dimensions, license information, and attribution details.
///
/// Example usage:
/// ```dart
/// final image = CommonsImage(
///   title: 'Example.jpg',
///   fullTitle: 'File:Example.jpg',
///   url: 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.jpg',
///   thumbUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example.jpg/800px-Example.jpg',
///   width: 1920,
///   height: 1080,
///   mimeType: 'image/jpeg',
/// );
///
/// // Access image properties
/// print('Title: ${image.title}');
/// print('URL: ${image.url}');
/// print('Dimensions: ${image.width}x${image.height}');
/// ```
///
/// ## Properties
///
/// ### Required Properties
/// - [title]: The file name without the 'File:' prefix
/// - [fullTitle]: The complete file title including the 'File:' prefix
/// - [url]: The full URL to the original image
/// - [thumbUrl]: The URL to a thumbnail version of the image
/// - [width]: The width of the image in pixels
/// - [height]: The height of the image in pixels
/// - [mimeType]: The MIME type of the image (e.g., 'image/jpeg')
///
/// ### Optional Properties
/// - [description]: A description of the image content
/// - [license]: The license under which the image is available
/// - [licenseUrl]: URL to the full license text
/// - [artistName]: The name of the image creator
/// - [artistUrl]: URL to the artist's page
/// - [attribution]: Attribution text required by the license
/// - [latitude]: Geographic latitude where the image was taken
/// - [longitude]: Geographic longitude where the image was taken
/// - [fileSize]: Size of the image file in bytes
/// - [priority]: Internal priority for sorting (default: 0)
///
/// ## JSON Serialization
///
/// The class provides [fromJson] factory constructor for creating instances
/// from JSON data. Required fields must be present in the JSON, or a
/// [FormatException] will be thrown.
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

  /// The file name without the 'File:' prefix
  final String title;

  /// The complete file title including the 'File:' prefix
  final String fullTitle;

  /// The full URL to the original image
  final String url;

  /// The URL to a thumbnail version of the image
  final String thumbUrl;

  /// The width of the image in pixels
  final int width;

  /// The height of the image in pixels
  final int height;

  /// The MIME type of the image (e.g., 'image/jpeg')
  final String mimeType;

  /// A description of the image content
  final String? description;

  /// The license under which the image is available
  final String? license;

  /// URL to the full license text
  final String? licenseUrl;

  /// The name of the image creator
  final String? artistName;

  /// URL to the artist's page
  final String? artistUrl;

  /// Attribution text required by the license
  final String? attribution;

  /// Geographic latitude where the image was taken
  final double? latitude;

  /// Geographic longitude where the image was taken
  final double? longitude;

  /// Size of the image file in bytes
  final int? fileSize;

  /// Internal priority for sorting (default: 0)
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
