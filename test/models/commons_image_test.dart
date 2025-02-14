import 'package:test/test.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() {
  group('CommonsImage', () {
    test('creates instance with required parameters', () {
      final image = CommonsImage(
        title: 'test_image.jpg',
        fullTitle: 'File:test_image.jpg',
      );

      expect(image.title, 'test_image.jpg');
      expect(image.fullTitle, 'File:test_image.jpg');
      expect(image.url, isNull);
      expect(image.thumbUrl, isNull);
      expect(image.width, isNull);
      expect(image.height, isNull);
      expect(image.mimeType, isNull);
      expect(image.description, isNull);
      expect(image.license, isNull);
      expect(image.attribution, isNull);
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
    });

    test('creates basic instance', () {
      final image = CommonsImage.basic(
        title: 'test_image.jpg',
        fullTitle: 'File:test_image.jpg',
        url: 'https://example.com/test.jpg',
        thumbUrl: 'https://example.com/test_thumb.jpg',
      );

      expect(image.title, 'test_image.jpg');
      expect(image.fullTitle, 'File:test_image.jpg');
      expect(image.url, 'https://example.com/test.jpg');
      expect(image.thumbUrl, 'https://example.com/test_thumb.jpg');
      expect(image.width, isNull);
      expect(image.height, isNull);
      expect(image.mimeType, isNull);
      expect(image.description, isNull);
      expect(image.license, isNull);
      expect(image.attribution, isNull);
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
    });

    test('handles missing values in JSON', () {
      final json = {
        'title': 'test_image.jpg',
        'fullTitle': 'File:test_image.jpg',
      };

      final image = CommonsImage.fromJson(json);

      expect(image.title, 'test_image.jpg');
      expect(image.fullTitle, 'File:test_image.jpg');
      expect(image.url, isNull);
      expect(image.thumbUrl, isNull);
      expect(image.width, isNull);
      expect(image.height, isNull);
      expect(image.mimeType, isNull);
      expect(image.description, isNull);
      expect(image.license, isNull);
      expect(image.attribution, isNull);
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
      );

      // Modified values
      expect(copy.width, 1024);
      expect(copy.height, 768);
      expect(copy.description, 'New description');

      // Unchanged values
      expect(copy.title, original.title);
      expect(copy.fullTitle, original.fullTitle);
      expect(copy.url, original.url);
      expect(copy.thumbUrl, original.thumbUrl);
      expect(copy.mimeType, original.mimeType);
      expect(copy.license, original.license);
      expect(copy.attribution, original.attribution);
    });
  });
}
