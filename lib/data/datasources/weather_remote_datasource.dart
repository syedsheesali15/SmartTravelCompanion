import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../domain/entities/weather_entity.dart';

class WeatherRemoteDataSource {
  WeatherRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherEntity> fetchCurrent({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(ApiConstants.openMeteoBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
      },
    );
    final res = await _client.get(uri).timeout(const Duration(seconds: 18));
    if (res.statusCode != 200) {
      throw Exception('Weather HTTP ${res.statusCode}');
    }
    final dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Open-Meteo: expected JSON object');
    }
    final current = decoded['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException('Open-Meteo: missing current');
    }
    final code = _asInt(current['weather_code'], fallback: 0);
    return WeatherEntity(
      temperatureC: _asDouble(current['temperature_2m']),
      apparentC: _asDouble(current['apparent_temperature']),
      humidityPct: _asInt(current['relative_humidity_2m']).clamp(0, 100),
      windKmh: _asDouble(current['wind_speed_10m']),
      conditionLabel: _labelForWmo(code),
    );
  }

  double _asDouble(Object? v, [double fallback = 0]) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  int _asInt(Object? v, {int fallback = 0}) {
    if (v is num) return v.round();
    return fallback;
  }

  String _labelForWmo(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Showers';
    if (code <= 86) return 'Snow showers';
    if (code <= 99) return 'Stormy';
    return 'Mixed conditions';
  }
}
