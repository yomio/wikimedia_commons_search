import 'package:test/test.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() {
  group('WikimediaApiException', () {
    test('creates with message only', () {
      final exception = WikimediaApiException('API error');
      expect(exception.message, equals('API error'));
      expect(exception.statusCode, isNull);
      expect(exception.endpoint, isNull);
      expect(exception.toString(), equals('API error'));
    });

    test('creates with all properties', () {
      final exception = WikimediaApiException(
        'API error',
        statusCode: 404,
        endpoint: 'https://api.example.com',
      );
      expect(exception.message, equals('API error'));
      expect(exception.statusCode, equals(404));
      expect(exception.endpoint, equals('https://api.example.com'));
      expect(
        exception.toString(),
        equals('API error, Status code: 404, Endpoint: https://api.example.com'),
      );
    });
  });

  group('WikimediaNoResultsException', () {
    test('creates with message', () {
      final exception = WikimediaNoResultsException('No results found');
      expect(exception.message, equals('No results found'));
      expect(exception.toString(), equals('No results found'));
    });
  });

  group('WikimediaNoImagesException', () {
    test('creates with message', () {
      final exception = WikimediaNoImagesException('No images found');
      expect(exception.message, equals('No images found'));
      expect(exception.toString(), equals('No images found'));
    });
  });

  group('ResponseParsingException', () {
    test('creates with default message', () {
      final exception = ResponseParsingException();
      expect(exception.message, equals('Failed to parse API response'));
      expect(exception.toString(), equals('Failed to parse API response'));
    });

    test('creates with custom message', () {
      final exception = ResponseParsingException('Invalid JSON format');
      expect(exception.message, equals('Invalid JSON format'));
      expect(exception.toString(), equals('Invalid JSON format'));
    });
  });

  group('DisposedException', () {
    test('creates with default message', () {
      final exception = DisposedException();
      expect(exception.message, equals('Instance has been disposed and cannot be used'));
      expect(
        exception.toString(),
        equals('Instance has been disposed and cannot be used'),
      );
    });

    test('creates with custom message', () {
      final exception = DisposedException('Client is disposed');
      expect(exception.message, equals('Client is disposed'));
      expect(exception.toString(), equals('Client is disposed'));
    });
  });
}
