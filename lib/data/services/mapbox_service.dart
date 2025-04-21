import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/map_constants.dart';
import '../models/search_result.dart';

class MapboxService {
  static const String _baseUrl = 'api.mapbox.com';
  static const String _endpoint = '/geocoding/v5/mapbox.places';

  Future<List<SearchResult>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    final uri = Uri.https(_baseUrl, '$_endpoint/$query.json', {
      'access_token': MapConstants.mapboxAccessToken,
      'limit': '5',
      'types': 'place,address,poi',
      'proximity': '${MapConstants.initialPosition.longitude},${MapConstants.initialPosition.latitude}',
      'language': 'es',
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['features'] as List)
            .map((feature) => SearchResult.fromJson(feature))
            .toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al buscar lugares: $e');
    }
  }
}