import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../domain/entities/geocode_place.dart';

class GeocodingRemoteDataSource {
  GeocodingRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<GeocodePlace>> searchByName(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final uri = Uri.parse(
      ApiConstants.openMeteoGeocodingUrl,
    ).replace(queryParameters: {'name': q, 'count': '10', 'language': 'en'});
    final res = await _client
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
            'User-Agent':
                'SmartTravelCompanion/1.0 (Flutter; contact: student demo)',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Geocoding HTTP ${res.statusCode}');
    }
    final dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Geocoding: expected JSON object');
    }
    final raw = decoded['results'];
    if (raw == null) return const [];
    if (raw is! List<dynamic>) {
      throw const FormatException('Geocoding: results not a list');
    }

    final out = <GeocodePlace>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final id = _asInt(item['id']);
      final name = item['name'] as String?;
      final lat = _asDouble(item['latitude']);
      final lng = _asDouble(item['longitude']);
      final country = item['country'] as String? ?? '';
      if (name == null || name.trim().isEmpty) continue;

      final resolvedId =
          id ?? (Object.hash(name, lat ?? 0, lng ?? 0) & 0x7fffffff);

      out.add(
        GeocodePlace(
          id: resolvedId,
          name: name.trim(),
          latitude: lat ?? 0,
          longitude: lng ?? 0,
          country: country,
          admin1: item['admin1'] as String?,
        ),
      );
    }
    return out;
  }

  int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.round();
    return null;
  }

  double? _asDouble(Object? v) {
    if (v is num) return v.toDouble();
    return null;
  }
}
