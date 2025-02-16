import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';
import 'mocks/mock_http_client.dart';

void main() {
  late WikimediaCommonsSearch search;
  late http.Client mockClient;

  setUp(() {
    mockClient = createMockClient();
    search = WikimediaCommonsSearch(client: mockClient);
  });

  tearDown(() {
    search.dispose();
  });

  group('WikimediaCommonsSearch', () {
    test('searchTopics returns topics for valid query', () async {
      final topics = await search.searchTopics('Eiffel Tower');

      expect(topics, isNotEmpty);
      expect(topics.first.id, '123');
      expect(topics.first.title, 'Eiffel Tower');
      expect(topics.first.description, contains('wrought-iron lattice tower'));
    });

    test('searchTopics throws WikimediaNoResultsException for non-existent query', () async {
      expect(
        () => search.searchTopics('xyznonexistentquery123'),
        throwsA(isA<WikimediaNoResultsException>()),
      );
    });

    test('getTopicImages returns images for valid topic', () async {
      final images = await search.getTopicImages('123');

      expect(images, isNotEmpty);
      expect(images.first.title, 'Eiffel Tower.jpg');
      expect(images.first.url, 'https://example.com/Eiffel_Tower.jpg');
      expect(images.first.thumbUrl, 'https://example.com/Eiffel_Tower_thumb.jpg');
      expect(images.first.width, 1920);
      expect(images.first.height, 1080);
      expect(images.first.mimeType, 'image/jpeg');
      expect(images.first.description, 'The Eiffel Tower at night');
      expect(images.first.license, 'CC BY-SA 4.0');
      expect(images.first.attribution, 'Photo by John Doe');
    });

    test('searchAndGetImages returns images for valid query', () async {
      final images = await search.searchImages('Eiffel Tower');

      expect(images, isNotEmpty);
      expect(images.first.title, 'Eiffel Tower.jpg');
      expect(images.first.url, isNotEmpty);
      expect(images.first.thumbUrl, isNotEmpty);
    });

    test('searchAndGetImages throws WikimediaNoResultsException for non-existent query', () async {
      expect(
        () => search.searchImages('xyznonexistentquery123'),
        throwsA(isA<WikimediaNoResultsException>()),
      );
    });

    test('throws DisposedException when using disposed instance', () async {
      search.dispose();
      expect(
        () => search.searchTopics('test'),
        throwsA(isA<DisposedException>()),
      );
    });

    test('exports all necessary models and classes', () {
      // Verify that all necessary classes are exported by trying to instantiate them
      expect(Topic, isNotNull);
      expect(CommonsImage, isNotNull);
      expect(WikimediaCommonsSearch, isNotNull);
      expect(WikimediaCommonsException, isNotNull);
      expect(WikimediaApiException, isNotNull);
      expect(WikimediaNoResultsException, isNotNull);
      expect(ResponseParsingException, isNotNull);
      expect(DisposedException, isNotNull);

      // Verify we can create instances (this will fail if properties are not exported)
      final topic = Topic(
        id: '123',
        title: 'Test Topic',
        description: 'Test Description',
        timestamp: '2024-01-01T00:00:00Z',
        wordCount: 100,
        size: 1000,
        imageCount: 5,
      );

      expect(topic, isA<Topic>());
      expect(topic.id, '123');

      final image = CommonsImage(
        title: 'Test.jpg',
        fullTitle: 'File:Test.jpg',
        url: 'https://example.com/test.jpg',
        thumbUrl: 'https://example.com/test_thumb.jpg',
        width: 800,
        height: 600,
        mimeType: 'image/jpeg',
        description: 'Test Description',
        license: 'CC0',
        attribution: 'Test Attribution',
      );

      expect(image, isA<CommonsImage>());
      expect(image.title, 'Test.jpg');
    });
  });
}
