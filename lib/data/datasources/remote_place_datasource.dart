import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/photo_dto.dart';

class RemotePlaceDataSource {
  RemotePlaceDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<PhotoDto>> fetchPhotos({
    required int start,
    required int limit,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.photosBaseUrl}/photos?_start=$start&_limit=$limit',
    );
    final res = await _client.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('Photos HTTP ${res.statusCode}');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => PhotoDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Single photo from jsonplaceholder — used for map search spotlights (title + image).
  Future<PhotoDto> fetchPhotoById(int id) async {
    final safe = id.clamp(1, 5000);
    final uri = Uri.parse('${ApiConstants.photosBaseUrl}/photos/$safe');
    final res = await _client.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('Photo HTTP ${res.statusCode}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Photo: expected JSON object');
    }
    return PhotoDto.fromJson(decoded);
  }
}
