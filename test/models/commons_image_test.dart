import 'package:test/test.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() {
  group('CommonsImage', () {
    test('creates instance with required parameters', () {
      final image = CommonsImage(
        title: 'test_image.jpg',
        fullTitle: 'File:test_image.jpg',
        url: 'https://example.com/test.jpg',
        thumbUrl: 'https://example.com/test_thumb.jpg',
        width: 800,
        height: 600,
        mimeType: 'image/jpeg',
      );

      expect(image.title, 'test_image.jpg');
      expect(image.fullTitle, 'File:test_image.jpg');
      expect(image.url, 'https://example.com/test.jpg');
      expect(image.thumbUrl, 'https://example.com/test_thumb.jpg');
      expect(image.width, 800);
      expect(image.height, 600);
      expect(image.mimeType, 'image/jpeg');
      expect(image.description, isNull);
      expect(image.license, isNull);
      expect(image.attribution, isNull);
      expect(image.artistName, isNull);
      expect(image.artistUrl, isNull);
      expect(image.latitude, isNull);
      expect(image.longitude, isNull);
      expect(image.fileSize, isNull);
    });

    test('creates instance with all parameters', () {
      final image = CommonsImage(
        title: 'test_image.jpg',
        fullTitle: 'File:test_image.jpg',
        url: 'https://example.com/test.jpg',
        thumbUrl: 'https://example.com/test_thumb.jpg',
        width: 800,
        height: 600,
        mimeType: 'image/jpeg',
        description: 'Test image description',
        license: 'CC BY-SA 4.0',
        attribution: 'Test Author',
        artistName: 'John Doe',
        artistUrl: 'https://example.com/johndoe',
        latitude: 48.8584,
        longitude: 2.2945,
        fileSize: 1024 * 1024,
      );

      expect(image.title, 'test_image.jpg');
      expect(image.fullTitle, 'File:test_image.jpg');
      expect(image.url, 'https://example.com/test.jpg');
      expect(image.thumbUrl, 'https://example.com/test_thumb.jpg');
      expect(image.width, 800);
      expect(image.height, 600);
      expect(image.mimeType, 'image/jpeg');
      expect(image.description, 'Test image description');
      expect(image.license, 'CC BY-SA 4.0');
      expect(image.attribution, 'Test Author');
      expect(image.artistName, 'John Doe');
      expect(image.artistUrl, 'https://example.com/johndoe');
      expect(image.latitude, 48.8584);
      expect(image.longitude, 2.2945);
      expect(image.fileSize, 1024 * 1024);
    });

    test('creates basic instance', () {
      final image = CommonsImage.basic(
        title: 'test_image.jpg',
        fullTitle: 'File:test_image.jpg',
        url: 'https://example.com/test.jpg',
      );

      expect(image.title, 'test_image.jpg');
      expect(image.fullTitle, 'File:test_image.jpg');
      expect(image.url, 'https://example.com/test.jpg');
      expect(image.thumbUrl, 'https://example.com/test.jpg');
      expect(image.width, 0);
      expect(image.height, 0);
      expect(image.mimeType, 'image/jpeg');
      expect(image.description, isNull);
      expect(image.license, isNull);
      expect(image.attribution, isNull);
      expect(image.artistName, isNull);
      expect(image.artistUrl, isNull);
      expect(image.latitude, isNull);
      expect(image.longitude, isNull);
      expect(image.fileSize, isNull);
    });

    test('creates instance from JSON', () {
      final json = {
        'title': 'test_image.jpg',
        'fullTitle': 'File:test_image.jpg',
        'url': 'https://example.com/test.jpg',
        'thumbUrl': 'https://example.com/test_thumb.jpg',
        'width': 800,
        'height': 600,
        'mimeType': 'image/jpeg',
        'description': 'Test image description',
        'license': 'CC BY-SA 4.0',
        'attribution': 'Test Author',
        'artistName': 'John Doe',
        'artistUrl': 'https://example.com/johndoe',
        'latitude': 48.8584,
        'longitude': 2.2945,
        'fileSize': 1024 * 1024,
      };

      final image = CommonsImage.fromJson(json);

      expect(image.title, 'test_image.jpg');
      expect(image.fullTitle, 'File:test_image.jpg');
      expect(image.url, 'https://example.com/test.jpg');
      expect(image.thumbUrl, 'https://example.com/test_thumb.jpg');
      expect(image.width, 800);
      expect(image.height, 600);
      expect(image.mimeType, 'image/jpeg');
      expect(image.description, 'Test image description');
      expect(image.license, 'CC BY-SA 4.0');
      expect(image.attribution, 'Test Author');
      expect(image.artistName, 'John Doe');
      expect(image.artistUrl, 'https://example.com/johndoe');
      expect(image.latitude, 48.8584);
      expect(image.longitude, 2.2945);
      expect(image.fileSize, 1024 * 1024);
    });

    test('throws FormatException when required fields are missing in JSON', () {
      final json = {
        'title': 'test_image.jpg',
        'fullTitle': 'File:test_image.jpg',
      };

      expect(
        () => CommonsImage.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('converts to JSON', () {
      final image = CommonsImage(
        title: 'test_image.jpg',
        fullTitle: 'File:test_image.jpg',
        url: 'https://example.com/test.jpg',
        thumbUrl: 'https://example.com/test_thumb.jpg',
        width: 800,
        height: 600,
        mimeType: 'image/jpeg',
        description: 'Test image description',
        license: 'CC BY-SA 4.0',
        attribution: 'Test Author',
        artistName: 'John Doe',
        artistUrl: 'https://example.com/johndoe',
        latitude: 48.8584,
        longitude: 2.2945,
        fileSize: 1024 * 1024,
      );

      final json = image.toJson();

      expect(json, {
        'title': 'test_image.jpg',
        'fullTitle': 'File:test_image.jpg',
        'url': 'https://example.com/test.jpg',
        'thumbUrl': 'https://example.com/test_thumb.jpg',
        'width': 800,
        'height': 600,
        'mimeType': 'image/jpeg',
        'description': 'Test image description',
        'license': 'CC BY-SA 4.0',
        'attribution': 'Test Author',
        'artistName': 'John Doe',
        'artistUrl': 'https://example.com/johndoe',
        'latitude': 48.8584,
        'longitude': 2.2945,
        'fileSize': 1024 * 1024,
      });
    });

    test('creates copy with modified values', () {
      final original = CommonsImage(
        title: 'test_image.jpg',
        fullTitle: 'File:test_image.jpg',
        url: 'https://example.com/test.jpg',
        thumbUrl: 'https://example.com/test_thumb.jpg',
        width: 800,
        height: 600,
        mimeType: 'image/jpeg',
      );

      final copy = original.copyWith(
        width: 1024,
        height: 768,
        description: 'New description',
        artistName: 'Jane Doe',
        latitude: 51.5074,
        longitude: -0.1278,
      );

      // Modified values
      expect(copy.width, 1024);
      expect(copy.height, 768);
      expect(copy.description, 'New description');
      expect(copy.artistName, 'Jane Doe');
      expect(copy.latitude, 51.5074);
      expect(copy.longitude, -0.1278);

      // Unchanged values
      expect(copy.title, original.title);
      expect(copy.fullTitle, original.fullTitle);
      expect(copy.url, original.url);
      expect(copy.thumbUrl, original.thumbUrl);
      expect(copy.mimeType, original.mimeType);
      expect(copy.license, original.license);
      expect(copy.attribution, original.attribution);
      expect(copy.artistUrl, original.artistUrl);
      expect(copy.fileSize, original.fileSize);
    });
  });
}
