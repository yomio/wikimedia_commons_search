import 'package:test/test.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() {
  group('WikimediaCommonsException', () {
    test('creates with message and formats toString correctly', () {
      const exception = WikimediaCommonsException('Test error message');
      expect(exception.message, equals('Test error message'));
      expect(exception.toString(), equals('WikimediaCommonsException: Test error message'));
    });
  });

  group('WikimediaApiException', () {
    test('creates with message only', () {
      const exception = WikimediaApiException('API error');
      expect(exception.message, equals('API error'));
      expect(exception.statusCode, isNull);
      expect(exception.endpoint, isNull);
      expect(exception.toString(), equals('WikimediaApiException: API error'));
    });

    test('creates with all properties', () {
      const exception = WikimediaApiException(
        'API error',
        statusCode: 404,
        endpoint: 'https://api.example.com',
      );
      expect(exception.message, equals('API error'));
      expect(exception.statusCode, equals(404));
      expect(exception.endpoint, equals('https://api.example.com'));
      expect(
        exception.toString(),
        equals('WikimediaApiException: API error, Status code: 404, Endpoint: https://api.example.com'),
      );
    });
  });

  group('NoResultsException', () {
    test('creates with default message', () {
      const exception = NoResultsException();
      expect(exception.message, equals('No results found for the given query'));
      expect(exception.toString(), equals('WikimediaCommonsException: No results found for the given query'));
    });

    test('creates with custom message', () {
      const exception = NoResultsException('No images found');
      expect(exception.message, equals('No images found'));
      expect(exception.toString(), equals('WikimediaCommonsException: No images found'));
    });
  });

  group('ResponseParsingException', () {
    test('creates with default message', () {
      const exception = ResponseParsingException();
      expect(exception.message, equals('Failed to parse API response'));
      expect(exception.toString(), equals('WikimediaCommonsException: Failed to parse API response'));
    });

    test('creates with custom message', () {
      const exception = ResponseParsingException('Invalid JSON format');
      expect(exception.message, equals('Invalid JSON format'));
      expect(exception.toString(), equals('WikimediaCommonsException: Invalid JSON format'));
    });
  });

  group('DisposedException', () {
    test('creates with default message', () {
      const exception = DisposedException();
      expect(exception.message, equals('Instance has been disposed and cannot be used'));
      expect(
        exception.toString(),
        equals('WikimediaCommonsException: Instance has been disposed and cannot be used'),
      );
    });

    test('creates with custom message', () {
      const exception = DisposedException('Client is disposed');
      expect(exception.message, equals('Client is disposed'));
      expect(exception.toString(), equals('WikimediaCommonsException: Client is disposed'));
    });
  });
}
