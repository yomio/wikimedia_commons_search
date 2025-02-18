import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';
import 'mocks/mock_http_client.dart';

void main() {
  late WikimediaCommons commons;
  late http.Client mockClient;

  setUp(() {
    mockClient = createMockClient();
    commons = WikimediaCommons(client: mockClient, defaultThumbnailHeight: 250);
  });

  tearDown(() {
    commons.dispose();
  });

  group('WikimediaCommons', () {
    test('searchTopics returns topics for valid query', () async {
      final topics = await commons.searchTopics('Eiffel Tower');

      expect(topics, isNotEmpty);
      expect(topics.first.id, '123');
      expect(topics.first.title, 'Eiffel Tower');
      expect(topics.first.description, contains('wrought-iron lattice tower'));
    });

    test('searchTopics throws WikimediaNoResultsException for non-existent query', () async {
      expect(
        () => commons.searchTopics('xyznonexistentquery123'),
        throwsA(isA<WikimediaNoResultsException>()),
      );
    });

    test('getTopicImages returns images for valid topic', () async {
      final images = await commons.getTopicImages('123');

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
      expect(images.first.artistName, 'User:JohnDoe');
      expect(images.first.artistUrl, startsWith('https://commons.wikimedia.org/wiki/User:'));
      expect(images.first.latitude, 48.8584);
      expect(images.first.longitude, 2.2945);
      expect(images.first.fileSize, 1024 * 1024);
    });

    test('searchImages returns images for valid query', () async {
      final images = await commons.searchImages('Eiffel Tower');

      expect(images, isNotEmpty);
      expect(images.first.title, 'Eiffel Tower.jpg');
      expect(images.first.url, isNotEmpty);
      expect(images.first.thumbUrl, isNotEmpty);
    });

    test('searchImages throws WikimediaNoResultsException for non-existent query', () async {
      expect(
        () => commons.searchImages('xyznonexistentquery123'),
        throwsA(isA<WikimediaNoResultsException>()),
      );
    });

    test('getImageInfo returns detailed image information', () async {
      final image = await commons.getImageInfo('File:Eiffel Tower.jpg');

      expect(image, isNotNull);
      expect(image!.title, 'Eiffel Tower.jpg');
      expect(image.url, startsWith('https://'));
      expect(image.width, 1920);
      expect(image.height, 1080);
      expect(image.mimeType, 'image/jpeg');
      expect(image.description, 'The Eiffel Tower at night');
      expect(image.license, 'CC BY-SA 4.0');
      expect(image.artistName, 'User:JohnDoe');
      expect(image.artistUrl, startsWith('https://commons.wikimedia.org/wiki/User:'));
      expect(image.latitude, 48.8584);
      expect(image.longitude, 2.2945);
      expect(image.fileSize, 1024 * 1024);
    });

    test('throws DisposedException when using disposed instance', () async {
      commons.dispose();
      expect(
        () => commons.searchTopics('test'),
        throwsA(isA<DisposedException>()),
      );
    });

    test('exports all necessary models and classes', () {
      // Verify that all necessary classes are exported by trying to instantiate them
      expect(WikipediaTopic, isNotNull);
      expect(CommonsImage, isNotNull);
      expect(WikimediaCommons, isNotNull);
      expect(WikimediaCommonsException, isNotNull);
      expect(WikimediaApiException, isNotNull);
      expect(WikimediaNoResultsException, isNotNull);
      expect(ResponseParsingException, isNotNull);
      expect(DisposedException, isNotNull);

      // Verify we can create instances (this will fail if properties are not exported)
      final topic = WikipediaTopic(
        id: '123',
        title: 'Test Topic',
        description: 'Test Description',
        timestamp: '2024-01-01T00:00:00Z',
        wordCount: 100,
        size: 1000,
        imageCount: 5,
      );

      expect(topic, isA<WikipediaTopic>());
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
        artistName: 'John Doe',
        artistUrl: 'https://example.com/johndoe',
        latitude: 48.8584,
        longitude: 2.2945,
        fileSize: 1024 * 1024,
      );

      expect(image, isA<CommonsImage>());
      expect(image.title, 'Test.jpg');
      expect(image.artistName, 'John Doe');
    });
  });

  group('Excluded patterns', () {
    final excludedPatterns = RegExp(
      r'(commons-logo\.svg|'
      r'Gnome-mime-sound-openclipart\.svg|'
      r'Star_full\.svg|'
      r'Pending-protection-shackle\.svg|'
      r'Question_book-new\.svg|'
      r'Star_empty\.svg|'
      r'Disambig_gray\.svg|'
      r'Semi-protection-shackle\.svg)',
      caseSensitive: false,
    );

    test('filters out excluded patterns from topic images', () async {
      final mockClient = createMockClient();
      final commons = WikimediaCommons(client: mockClient);

      final images = await commons.getTopicImages('123');

      // Verify that no image URLs contain excluded patterns
      for (final image in images) {
        expect(
          image.url,
          isNot(matches(excludedPatterns)),
          reason: 'Image URL ${image.url} should not contain excluded patterns',
        );
        expect(
          image.thumbUrl,
          isNot(matches(excludedPatterns)),
          reason: 'Thumbnail URL ${image.thumbUrl} should not contain excluded patterns',
        );
        expect(
          image.fullTitle,
          isNot(matches(excludedPatterns)),
          reason: 'Image title ${image.fullTitle} should not contain excluded patterns',
        );
      }
    });

    test('filters out excluded patterns from direct image search', () async {
      final mockClient = createMockClient();
      final commons = WikimediaCommons(client: mockClient);

      final images = await commons.searchImages('test');

      // Verify that no image URLs contain excluded patterns
      for (final image in images) {
        expect(
          image.url,
          isNot(matches(excludedPatterns)),
          reason: 'Image URL ${image.url} should not contain excluded patterns',
        );
        expect(
          image.thumbUrl,
          isNot(matches(excludedPatterns)),
          reason: 'Thumbnail URL ${image.thumbUrl} should not contain excluded patterns',
        );
        expect(
          image.fullTitle,
          isNot(matches(excludedPatterns)),
          reason: 'Image title ${image.fullTitle} should not contain excluded patterns',
        );
      }
    });

    test('excludes utility images based on title', () async {
      final mockClient = createMockClient();
      final commons = WikimediaCommons(client: mockClient);

      final images = await commons.getTopicImages('123');

      // Verify that no image titles contain utility patterns
      for (final image in images) {
        expect(
          image.title.toLowerCase(),
          isNot(matches(r'(flag|icon|template|logo|map|symbol|seal|coat[ _]of[ _]arms|emblem|banner)')),
          reason: 'Image title ${image.title} should not contain utility patterns',
        );
      }
    });
  });
}
