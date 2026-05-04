import '../../core/geo/fake_location.dart';
import '../../core/geo/place_stock_photos.dart';
import '../../domain/entities/place_entity.dart';

class PhotoDto {
  PhotoDto({
    required this.id,
    required this.albumId,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  final int id;
  final int albumId;

  /// Raw JSONPlaceholder title (Latin); not shown as main heading — we use curated travel names instead.
  final String title;
  final String url;
  final String thumbnailUrl;

  factory PhotoDto.fromJson(Map<String, dynamic> json) {
    int asId(Object? raw) => raw is int ? raw : (raw as num).toInt();

    return PhotoDto(
      id: asId(json['id']),
      albumId: asId(json['albumId']),
      title: (json['title'] as String).trim(),
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }

  PlaceEntity toEntity({required bool isFavorite, required int? lastViewedMs}) {
    final loc = syntheticTravelSpot(albumId: albumId, photoId: id);
    final photos = curatedSpotPhotos(albumId: albumId, photoId: id);
    final commaParts = loc.titleLine
        .split(',')
        .map((segment) => segment.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final displayTitle = commaParts.isNotEmpty
        ? commaParts.first
        : 'Curated vista';
    final about =
        'Visit $displayTitle — anchored in ${loc.titleLine}. '
        'This gallery frame (#$id • album $albumId) showcases ${loc.regionBucket} palettes with dreamy lighting. '
        'Curator note: ${title.split(' ').take(8).join(' ')}…';

    return PlaceEntity(
      id: id,
      albumId: albumId,
      title: displayTitle,
      fullImageUrl: photos.fullImageUrl,
      thumbnailUrl: photos.thumbnailUrl,
      locationLine: loc.titleLine,
      aboutText: about,
      regionBucket: loc.regionBucket,
      isFavorite: isFavorite,
      lastViewedMs: lastViewedMs,
      worldLatitude: null,
      worldLongitude: null,
      worldGeocodeSeedId: 0,
    );
  }
}
