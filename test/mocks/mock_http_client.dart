import 'dart:convert';
import 'package:http/http.dart' as http;

class MockClient extends http.BaseClient {
  MockClient(this.handler);
  final Future<http.Response> Function(http.Request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request as http.Request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

/// Creates a mock client with predefined responses for common test scenarios
MockClient createMockClient() {
  return MockClient((request) async {
    final uri = request.url;

    // Handle empty search results
    if (uri.queryParameters['srsearch'] == 'xyznonexistentquery123' ||
        uri.queryParameters['gsrsearch']?.contains('xyznonexistentquery123') == true) {
      return http.Response(
        jsonEncode({
          'query': {'search': []}
        }),
        200,
      );
    }

    // Handle invalid page ID
    if (uri.queryParameters['pageids'] == '-1') {
      return http.Response(
        jsonEncode({
          'query': {'pages': <String, dynamic>{}}
        }),
        200,
      );
    }

    // Handle topic search (both endpoints)
    if ((uri.queryParameters['generator'] == 'search' && uri.queryParameters['gsrnamespace'] == '0') ||
        (uri.queryParameters['list'] == 'search' && uri.queryParameters['srnamespace'] == '0')) {
      return http.Response(
        jsonEncode({
          'query': {
            'pages': {
              '123': {
                'pageid': 123,
                'title': 'Eiffel Tower',
                'index': 1,
                'description': 'The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris.',
                'extract': 'The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris.',
                'timestamp': '2024-01-01T00:00:00Z',
                'length': 50000,
                'size': 5000,
              }
            },
            'search': [
              {
                'pageid': 123,
                'title': 'Eiffel Tower',
                'snippet': 'The Eiffel Tower is a wrought-iron lattice tower on the Champ de Mars in Paris.',
                'timestamp': '2024-01-01T00:00:00Z',
                'wordcount': 50000,
                'size': 5000,
              }
            ]
          }
        }),
        200,
      );
    }

    // Handle image queries
    if (uri.path.contains('/w/api.php') && uri.queryParameters['prop']?.contains('imageinfo') == true) {
      return http.Response(
        jsonEncode({
          'query': {
            'pages': {
              '456': {
                'pageid': 456,
                'title': 'File:Eiffel Tower.jpg',
                'imageinfo': [
                  {
                    'url': 'https://example.com/Eiffel_Tower.jpg',
                    'thumburl': 'https://example.com/Eiffel_Tower_thumb.jpg',
                    'width': 1920,
                    'height': 1080,
                    'mime': 'image/jpeg',
                    'descriptionurl': 'https://commons.wikimedia.org/wiki/File:Eiffel_Tower.jpg',
                    'extmetadata': {
                      'ImageDescription': {'value': 'The Eiffel Tower at night'},
                      'License': {'value': 'CC BY-SA 4.0'},
                      'Attribution': {'value': 'Photo by John Doe'},
                    }
                  }
                ]
              }
            }
          }
        }),
        200,
      );
    }

    // Handle very long search query
    final searchQuery = uri.queryParameters['srsearch'];
    if (searchQuery != null && searchQuery.length > 500) {
      return http.Response('', 414); // Request URI too long
    }

    // Default response for unhandled requests
    return http.Response('Not found', 404);
  });
}
