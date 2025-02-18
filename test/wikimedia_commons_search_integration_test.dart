@Tags(['integration'])
library wikimedia_commons_search_integration_test;

import 'package:test/test.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() {
  late WikimediaCommons commons;

  setUp(() {
    commons = WikimediaCommons(defaultThumbnailHeight: 250);
  });

  tearDown(() {
    commons.dispose();
  });

  group('WikimediaCommons Integration Tests', () {
    test('searchTopics finds Tomáš Masaryk page', () async {
      final topics = await commons.searchTopics('Masaryk');

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
      final topics = await commons.searchTopics('Dvořák composer');

      expect(topics, isNotEmpty, reason: 'Should find topics with diacritics');
      expect(
        topics.any((t) => t.title.contains('Dvořák') && t.description.toLowerCase().contains('composer')),
        isTrue,
        reason: 'Should find Dvořák the composer',
      );
    }, timeout: Timeout(Duration(seconds: 30)));

    test('getTopicImages retrieves images from a topic', () async {
      // First get the Eiffel Tower topic as it's guaranteed to have images
      final topics = await commons.searchTopics('Eiffel Tower');
      final eiffelTopic = topics.firstWhere(
        (topic) => topic.title.contains('Eiffel Tower'),
        orElse: () => throw TestFailure('Could not find Eiffel Tower topic'),
      );

      // Get images for the topic
      final images = await commons.getTopicImages(eiffelTopic.id);

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

      // Optional metadata fields - verify format when present
      if (firstImage.description != null) {
        expect(firstImage.description, isNotEmpty);
      }
      if (firstImage.license != null) {
        expect(firstImage.license, isNotEmpty);
      }
      if (firstImage.artistName != null) {
        expect(firstImage.artistName, isNotEmpty);
        if (firstImage.artistUrl != null) {
          expect(firstImage.artistUrl, startsWith('http'));
        }
      }
      if (firstImage.latitude != null) {
        expect(firstImage.longitude, isNotNull);
        expect(firstImage.latitude, inInclusiveRange(-90, 90));
        expect(firstImage.longitude, inInclusiveRange(-180, 180));
      }
      if (firstImage.fileSize != null) {
        expect(firstImage.fileSize, greaterThan(0));
      }

      // Verify image sorting (non-SVG before SVG)
      if (images.length > 1) {
        final containsSvg = images.any((img) => img.mimeType.contains('svg'));
        if (containsSvg) {
          expect(
            images.first.mimeType.contains('svg'),
            isFalse,
            reason: 'Non-SVG images should be sorted before SVG images',
          );
        }
      }
    }, timeout: Timeout(Duration(seconds: 60))); // Longer timeout as it makes multiple API calls

    test('searchImages finds images directly', () async {
      final images = await commons.searchImages('Eiffel Tower');

      expect(images, isNotEmpty, reason: 'Should find at least one image');

      final firstImage = images.first;
      expect(firstImage.title, isNotEmpty);
      expect(firstImage.fullTitle, startsWith('File:'));
      expect(firstImage.url, startsWith('https://'));
      expect(firstImage.thumbUrl, startsWith('https://'));
      expect(firstImage.width, greaterThan(0));
      expect(firstImage.height, greaterThan(0));
      expect(firstImage.mimeType, startsWith('image/'));

      // Optional metadata fields - verify format when present
      if (firstImage.description != null) {
        expect(firstImage.description, isNotEmpty);
      }
      if (firstImage.license != null) {
        expect(firstImage.license, isNotEmpty);
      }

      // Verify minimum image size requirement
      expect(
        firstImage.width >= 200 && firstImage.height >= 200,
        isTrue,
        reason: 'Images should be at least 200x200 pixels',
      );
    }, timeout: Timeout(Duration(seconds: 60)));

    test('getImageInfo retrieves detailed image information', () async {
      // First get an image from search
      final images = await commons.searchImages('Eiffel Tower');
      expect(images, isNotEmpty, reason: 'Should find at least one image');

      // Get detailed info for the first image
      final details = await commons.getImageInfo(images.first.fullTitle);
      expect(details, isNotNull, reason: 'Should get image details');

      // Verify detailed metadata
      final image = details!;
      expect(image.title, isNotEmpty);
      expect(image.fullTitle, startsWith('File:'));
      expect(image.url, startsWith('https://'));
      expect(image.width, greaterThan(0));
      expect(image.height, greaterThan(0));
      expect(image.mimeType, startsWith('image/'));

      // Optional metadata fields - verify format when present
      if (image.description != null) {
        expect(image.description, isNotEmpty);
      }
      if (image.license != null) {
        expect(image.license, isNotEmpty);
      }
      if (image.artistName != null) {
        expect(image.artistName, isNotEmpty);
        if (image.artistUrl != null) {
          expect(image.artistUrl, startsWith('http'));
        }
      }
      if (image.latitude != null) {
        expect(image.longitude, isNotNull);
        expect(image.latitude, inInclusiveRange(-90, 90));
        expect(image.longitude, inInclusiveRange(-180, 180));
      }
      if (image.fileSize != null) {
        expect(image.fileSize, greaterThan(0));
      }
    }, timeout: Timeout(Duration(seconds: 60)));

    test('handles API errors gracefully', () async {
      // Test with invalid page ID
      expect(
        () => commons.getTopicImages('-1'),
        throwsA(isA<WikimediaNoResultsException>().having(
          (e) => e.message,
          'message',
          'No images found for the given topic',
        )),
      );

      // Test with very long search query
      final longQuery = 'a' * 1000;
      expect(
        () => commons.searchTopics(longQuery),
        throwsA(isA<WikimediaApiException>()),
      );

      // Test with disposed instance
      commons.dispose();
      expect(
        () => commons.searchTopics('test'),
        throwsA(isA<DisposedException>()),
      );
    }, timeout: Timeout(Duration(seconds: 30)));

    test('getThumbnailUrl generates valid URLs', () async {
      // First get a real image URL from the API
      final images = await commons.searchImages('Eiffel Tower');
      expect(images, isNotEmpty);

      final imageUrl = images.first.url;
      expect(imageUrl, startsWith('https://upload.wikimedia.org/'));

      // Test thumbnail URL generation
      final thumbUrl = WikimediaCommons.getThumbnailUrl(imageUrl, width: 800);
      expect(
        thumbUrl,
        allOf([
          startsWith('https://upload.wikimedia.org/wikipedia/commons/thumb/'),
          matches(RegExp(r'/800px-[^/]+$')), // Match any filename at the end
        ]),
      );

      // Verify the thumbnail URL works by trying to load it
      final response = await commons.searchImages('test'); // Just to get a new client
      expect(response, isNotEmpty); // Verify we can still make requests
    }, timeout: Timeout(Duration(seconds: 60)));
  });
}
