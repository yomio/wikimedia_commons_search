import 'package:test/test.dart';
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() {
  group('Topic', () {
    test('creates instance with required parameters', () {
      final topic = Topic(
        id: '123',
        title: 'Test Topic',
        description: 'Test description',
        timestamp: '2024-01-01T00:00:00Z',
        wordCount: 100,
        size: 5000,
        imageCount: 10,
      );

      expect(topic.id, '123');
      expect(topic.title, 'Test Topic');
      expect(topic.description, 'Test description');
      expect(topic.timestamp, '2024-01-01T00:00:00Z');
      expect(topic.wordCount, 100);
      expect(topic.size, 5000);
      expect(topic.imageCount, 10);
    });

    test('creates instance from JSON', () {
      final json = {
        'id': '123',
        'title': 'Test Topic',
        'description': 'Test description with multiple words',
        'timestamp': '2024-01-01T00:00:00Z',
        'size': 5000,
        'imageCount': 10,
      };

      final topic = Topic.fromJson(json);

      expect(topic.id, '123');
      expect(topic.title, 'Test Topic');
      expect(topic.description, 'Test description with multiple words');
      expect(topic.timestamp, '2024-01-01T00:00:00Z');
      expect(topic.wordCount, 5); // Calculated from description
      expect(topic.size, 5000);
      expect(topic.imageCount, 10);
    });

    test('handles missing values in JSON', () {
      final json = {'id': '123'};

      final topic = Topic.fromJson(json);

      expect(topic.id, '123');
      expect(topic.title, 'Untitled');
      expect(topic.description, '');
      expect(
        topic.timestamp,
        matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')), // Match ISO8601 format without being exact
      );
      expect(topic.wordCount, 0);
      expect(topic.size, 0);
      expect(topic.imageCount, 0);
    });

    test('converts to JSON', () {
      final topic = Topic(
        id: '123',
        title: 'Test Topic',
        description: 'Test description',
        timestamp: '2024-01-01T00:00:00Z',
        wordCount: 100,
        size: 5000,
        imageCount: 10,
      );

      final json = topic.toJson();

      expect(json, {
        'id': '123',
        'title': 'Test Topic',
        'description': 'Test description',
        'timestamp': '2024-01-01T00:00:00Z',
        'wordCount': 100,
        'size': 5000,
        'imageCount': 10,
      });
    });
  });
}
