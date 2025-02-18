import 'package:test/test.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() {
  group('getThumbnailUrl', () {
    const validJpgUrl = 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.jpg';
    const validPngUrl = 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.png';
    const validGifUrl = 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.gif';
    const validSvgUrl = 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.svg';
    const validJpegUrl = 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.jpeg';
    const validWebpUrl = 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.webp';

    test('preserves PNG extension for PNG files', () {
      final thumbUrl = WikimediaCommons.getThumbnailUrl(validPngUrl, width: 800);
      expect(thumbUrl, 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example.png/800px-Example.png');
    });

    test('preserves GIF extension for GIF files', () {
      final thumbUrl = WikimediaCommons.getThumbnailUrl(validGifUrl, width: 800);
      expect(thumbUrl, 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example.gif/800px-Example.gif');
    });

    test('converts SVG to PNG', () {
      final thumbUrl = WikimediaCommons.getThumbnailUrl(validSvgUrl, width: 800);
      expect(thumbUrl, 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example.svg/800px-Example.png');
    });

    test('converts JPEG to JPG', () {
      final thumbUrl = WikimediaCommons.getThumbnailUrl(validJpegUrl, width: 800);
      expect(thumbUrl, 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example.jpeg/800px-Example.jpg');
    });

    test('converts WEBP to JPG', () {
      final thumbUrl = WikimediaCommons.getThumbnailUrl(validWebpUrl, width: 800);
      expect(thumbUrl, 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example.webp/800px-Example.jpg');
    });

    test('converts JPG to JPG', () {
      final thumbUrl = WikimediaCommons.getThumbnailUrl(validJpgUrl, width: 800);
      expect(thumbUrl, 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example.jpg/800px-Example.jpg');
    });

    test('throws ArgumentError when width is less than 1', () {
      expect(
        () => WikimediaCommons.getThumbnailUrl(validJpgUrl, width: 0),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Width must be greater than 0',
        )),
      );
    });

    test('throws ArgumentError for invalid URL format', () {
      expect(
        () => WikimediaCommons.getThumbnailUrl('not-a-url', width: 800),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Not a Wikimedia URL',
        )),
      );
    });

    test('throws ArgumentError for non-Wikimedia URL', () {
      expect(
        () => WikimediaCommons.getThumbnailUrl('https://example.com/image.jpg', width: 800),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Not a Wikimedia URL',
        )),
      );
    });

    test('throws ArgumentError for invalid Wikimedia URL format', () {
      expect(
        () => WikimediaCommons.getThumbnailUrl('https://upload.wikimedia.org/invalid/path', width: 800),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Invalid Wikimedia URL format',
        )),
      );
    });

    test('throws ArgumentError for invalid filename format', () {
      expect(
        () =>
            WikimediaCommons.getThumbnailUrl('https://upload.wikimedia.org/wikipedia/commons/a/a5/invalid', width: 800),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Invalid filename format',
        )),
      );
    });

    test('handles commons.wikimedia.org URLs', () {
      const commonsUrl = 'https://commons.wikimedia.org/wikipedia/commons/a/a5/Example.jpg';
      final thumbUrl = WikimediaCommons.getThumbnailUrl(commonsUrl, width: 800);
      expect(thumbUrl, 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example.jpg/800px-Example.jpg');
    });

    test('handles URLs with query parameters', () {
      const urlWithQuery = 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.jpg?foo=bar';
      final thumbUrl = WikimediaCommons.getThumbnailUrl(urlWithQuery, width: 800);
      expect(thumbUrl, 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example.jpg/800px-Example.jpg');
    });
  });
}
