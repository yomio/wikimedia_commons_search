# Wikimedia Commons Search Examples

This directory contains examples demonstrating how to use the `wikimedia_commons_search` package.

## Basic Examples

### Search for Images

```dart
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() async {
  final commons = WikimediaCommons();

  try {
    // Search for images
    final images = await commons.searchImages('Eiffel Tower');
    
    for (final image in images) {
      print('Title: ${image.title}');
      print('URL: ${image.url}');
      print('Thumbnail: ${image.thumbnailUrl}');
      print('License: ${image.license}');
      print('Description: ${image.description}');
      
      // Get GPS coordinates if available
      if (image.gpsCoordinates != null) {
        print('Location: ${image.gpsCoordinates}');
      }
      
      print('---');
    }
  } finally {
    commons.dispose();
  }
}
```

### Search for Topics

```dart
void main() async {
  final commons = WikimediaCommons();

  try {
    // Search for topics
    final topics = await commons.searchTopics('Leonardo da Vinci');
    
    for (final topic in topics) {
      print('Title: ${topic.title}');
      print('Description: ${topic.description}');
      print('Word Count: ${topic.wordCount}');
      
      // Get images for this topic
      final images = await commons.getTopicImages(topic.id);
      print('Found ${images.length} images');
      
      for (final image in images) {
        print('- ${image.title}');
      }
      print('---');
    }
  } finally {
    commons.dispose();
  }
}
```

### Generate Thumbnails

```dart
void main() {
  final imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Example.jpg';
  
  // Generate thumbnail URLs with different options
  final smallThumb = WikimediaCommons.getThumbnailUrl(imageUrl, width: 200);
  final largeThumb = WikimediaCommons.getThumbnailUrl(imageUrl, width: 800);
  
  print('Small thumbnail: $smallThumb');
  print('Large thumbnail: $largeThumb');
}
```

### Error Handling

```dart
void main() async {
  final commons = WikimediaCommons();

  try {
    final images = await commons.searchImages('');
  } on WikimediaNoResultsException catch (e) {
    print('No results found: ${e.message}');
  } on WikimediaApiException catch (e) {
    print('API error: ${e.message}');
  } on ResponseParsingException catch (e) {
    print('Failed to parse response: ${e.message}');
  } finally {
    commons.dispose();
  }
}
```

## Flutter Example

A complete Flutter example application is available in the [example_app](example_app) directory.

The example app demonstrates:
- Searching for topics and images
- Displaying search results in a grid
- Showing image details with metadata
- Handling errors and loading states
- Implementing pull-to-refresh
- Proper resource disposal

## Tips and Best Practices

1. Always dispose the `WikimediaCommons` instance when you're done:
   ```dart
   final commons = WikimediaCommons();
   try {
     // Use the instance...
   } finally {
     commons.dispose();
   }
   ```

2. Use appropriate error handling for different scenarios:
   - `WikimediaNoResultsException` for empty search results
   - `WikimediaNoImagesException` when no images are found for a topic
   - `WikimediaApiException` for API-related errors
   - `ResponseParsingException` for malformed responses
   - `DisposedException` when using a disposed instance

3. When generating thumbnails, consider:
   - Use appropriate sizes for your use case
   - Cache thumbnails in your application
   - Handle SVG images appropriately (they're automatically converted to PNG)

4. For topic searches:
   - Start with broad searches and let users refine
   - Use the topic description to help users choose the right topic
   - Consider the word count when displaying topic information

5. For image searches:
   - Check license information before using images
   - Display attribution when required
   - Use GPS coordinates when available for location-based features
   - Consider image dimensions when displaying thumbnails
``` 