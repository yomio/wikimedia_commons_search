import 'package:test/test.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() {
  late WikimediaCommonsSearch search;

  setUp(() {
    search = WikimediaCommonsSearch();
  });

  tearDown(() {
    search.dispose();
  });

  group('WikimediaCommonsSearch Integration Tests', () {
    test('searchTopics finds Tomáš Masaryk page', () async {
      final topics = await search.searchTopics('Masaryk');

      // Find the topic about Tomáš Masaryk
      final masarykTopic = topics.firstWhere(
        (topic) => topic.title.contains('Masaryk') && (topic.title.contains('Tomáš') || topic.title.contains('Tomas')),
        orElse: () =>
            throw TestFailure('Expected to find topic about Tomáš Masaryk in search results, but it was not found.\n'
                'Found topics: ${topics.map((t) => t.title).join(', ')}'),
      );

      // Verify the topic data
      expect(masarykTopic.id, isNotEmpty);
      expect(masarykTopic.title, contains('Masaryk'));
      expect(masarykTopic.description, isNotEmpty);
      expect(
        masarykTopic.description,
        contains('Czechoslovak'), // Should contain reference to Czechoslovakia as he was its first president
        reason: 'Description should mention his connection to Czechoslovakia',
      );
      expect(masarykTopic.timestamp, matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$')));
      expect(masarykTopic.wordCount, greaterThan(0));
      expect(masarykTopic.size, greaterThan(0));
    }, timeout: Timeout(Duration(seconds: 30))); // Increased timeout for API call

    test('searchTopics handles special characters', () async {
      // Test with special characters and diacritics
      final topics = await search.searchTopics('Dvořák composer');

      expect(topics, isNotEmpty, reason: 'Should find topics with diacritics');
      expect(
        topics.any((t) => t.title.contains('Dvořák') && t.description.toLowerCase().contains('composer')),
        isTrue,
        reason: 'Should find Dvořák the composer',
      );
    }, timeout: Timeout(Duration(seconds: 30)));

    test('getTopicImages retrieves images from a topic', () async {
      // First get the Eiffel Tower topic as it's guaranteed to have images
      final topics = await search.searchTopics('Eiffel Tower');
      final eiffelTopic = topics.firstWhere(
        (topic) => topic.title.contains('Eiffel Tower'),
        orElse: () => throw TestFailure('Could not find Eiffel Tower topic'),
      );

      // Get images for the topic
      final images = await search.getTopicImages(eiffelTopic.id);

      // Verify we got some images
      expect(images, isNotEmpty, reason: 'Should find at least one image');

      // Verify image structure and metadata
      final firstImage = images.first;
      expect(firstImage, isA<CommonsImage>());
      expect(firstImage.title, isNotEmpty);
      expect(firstImage.fullTitle, startsWith('File:'));
      expect(firstImage.url, startsWith('https://'));
      expect(firstImage.thumbUrl, startsWith('https://'));
      expect(firstImage.width, greaterThan(0));
      expect(firstImage.height, greaterThan(0));
      expect(firstImage.mimeType, startsWith('image/'));
      expect(firstImage.description, isNotNull);
      expect(firstImage.license, isNotNull);

      // Verify image sorting (non-SVG before SVG)
      if (images.length > 1) {
        final containsSvg = images.any((img) => img.mimeType?.toLowerCase().contains('svg') ?? false);
        if (containsSvg) {
          expect(
            images.first.mimeType?.toLowerCase().contains('svg') ?? false,
            isFalse,
            reason: 'Non-SVG images should be sorted before SVG images',
          );
        }
      }
    }, timeout: Timeout(Duration(seconds: 60))); // Longer timeout as it makes multiple API calls

    test('searchAndGetImages combines search and image retrieval', () async {
      final images = await search.searchImages('Eiffel Tower');

      expect(images, isNotEmpty, reason: 'Should find at least one image');

      final firstImage = images.first;
      expect(firstImage.title, isNotEmpty);
      expect(firstImage.fullTitle, startsWith('File:'));
      expect(firstImage.url, startsWith('https://'));
      expect(firstImage.thumbUrl, startsWith('https://'));
      expect(firstImage.width, greaterThan(0));
      expect(firstImage.height, greaterThan(0));
      expect(firstImage.mimeType, startsWith('image/'));
      expect(firstImage.description, isNotNull);
      expect(firstImage.license, isNotNull);
    }, timeout: Timeout(Duration(seconds: 60)));

    test('searchImages finds images directly', () async {
      final images = await search.api.searchImages('Eiffel Tower');

      // Verify we got some images
      expect(images, isNotEmpty, reason: 'Should find at least one image');

      // Verify image structure
      final firstImage = images.first;
      expect(firstImage, isA<CommonsImage>());
      expect(firstImage.url, startsWith('https://'));
      expect(firstImage.width, greaterThan(0));
      expect(firstImage.height, greaterThan(0));
      expect(firstImage.mimeType, startsWith('image/'));

      // Verify image details
      final details = await search.api.getImageInfo(firstImage.fullTitle);
      expect(details, isNotNull);
      expect(details!.description, isNotNull);
      expect(details.license, isNotNull);

      // Verify minimum image size requirement
      expect(
        firstImage.width! >= 200 && firstImage.height! >= 200,
        isTrue,
        reason: 'Images should be at least 200x200 pixels',
      );
    }, timeout: Timeout(Duration(seconds: 60)));

    test('handles API errors gracefully', () async {
      // Test with invalid page ID
      expect(
        () => search.getTopicImages('-1'),
        throwsA(isA<WikimediaNoResultsException>().having(
          (e) => e.message,
          'message',
          'No images found for the given topic',
        )),
      );

      // Test with very long search query
      final longQuery = 'a' * 1000;
      expect(
        () => search.searchTopics(longQuery),
        throwsA(isA<WikimediaApiException>()),
      );

      // Test with disposed instance
      search.dispose();
      expect(
        () => search.searchTopics('test'),
        throwsA(isA<DisposedException>()),
      );
    }, timeout: Timeout(Duration(seconds: 30)));
  });
}
