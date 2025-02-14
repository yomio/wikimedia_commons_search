# Wikimedia Commons Search

A Dart library for searching Wikipedia topics and retrieving associated Wikimedia Commons images.

## ⚠️ Important Licensing Notice

This library is a tool for accessing Wikimedia content and does not handle content licensing. When using content from Wikipedia or Wikimedia Commons, you must observe and comply with Wikimedia's licensing terms. Different content pieces may have different licenses.

For more information, visit:
- [Wikimedia Commons Licensing](https://commons.wikimedia.org/wiki/Commons:Licensing)
- [Wikimedia Terms of Use](https://foundation.wikimedia.org/wiki/Terms_of_Use)

## Installation

```yaml
dependencies:
  wikimedia_commons_search: ^1.0.0
```

Then run:
```bash
dart pub get
```

## Usage

### Basic Example

```dart
import 'package:wikimedia_commons_search/wikimedia_commons_search.dart';

void main() async {
  final search = WikimediaCommonsSearch();

  try {
    // Search for topics
    final topics = await search.searchTopics('Eiffel Tower');
    
    // Get images for the first topic
    if (topics.isNotEmpty) {
      final images = await search.getTopicImages(topics.first.id);
      
      for (final image in images) {
        print('${image.title}: ${image.url}');
      }
    }
  } on WikimediaCommonsException catch (e) {
    print('Error: ${e.message}');
  } finally {
    search.dispose();
  }
}
```

### Quick Search

Use the convenience method to get images in one call:

```dart
final search = WikimediaCommonsSearch();

try {
  final images = await search.searchAndGetImages('Eiffel Tower');
  for (final image in images) {
    print('${image.title}: ${image.url}');
  }
} finally {
  search.dispose();
}
```

## Features

- Search Wikipedia topics
- Retrieve images from Wikipedia articles
- Search Wikimedia Commons directly
- Get image metadata (description, license, attribution)
- Automatic filtering of utility images
- Error handling with custom exceptions

## License

This library is licensed under the MIT License - see the LICENSE file for details.

Note: This license applies to the library code only, not to the content retrieved from Wikimedia Commons or Wikipedia. 