import '../../core/geo/fake_location.dart';
import '../../core/geo/place_stock_photos.dart';
import '../../domain/entities/place_entity.dart';

/// Builds a canonical catalog [PlaceEntity] from `(albumId, photoId)` so title,
/// location line, Wikimedia thumbnail, and about text stay in sync whenever
/// [PredefinedDestinations] order/content changes — avoids stale headings with
/// newly indexed imagery (e.g. "Reykjavik" caption with Taj Mahal photo).
PlaceEntity catalogPlaceEntityFromAlbumPhoto({
  required int id,
  required int albumId,
  required String latinCuratorSnippet,
  required bool isFavorite,
  required int? lastViewedMs,
}) {
  final loc = syntheticTravelSpot(albumId: albumId, photoId: id);
  final photos = curatedSpotPhotos(albumId: albumId, photoId: id);
  final commaParts = loc.titleLine
      .split(',')
      .map((segment) => segment.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  final displayTitle =
      commaParts.isNotEmpty ? commaParts.first : 'Curated vista';
  final note = latinCuratorSnippet.trim().isEmpty
      ? 'illustrative travel imagery.'
      : latinCuratorSnippet.trim();
  final about =
      'Visit $displayTitle — anchored in ${loc.titleLine}. '
      'This gallery frame (#$id • album $albumId) showcases ${loc.regionBucket} palettes with dreamy lighting. '
      'Curator note: $note';

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

/// Recover the Latin/HTML caption tail we stored earlier (first ~8 tokens + …).
String curatorSnippetFromStoredAbout(String? aboutText) {
  if (aboutText == null || aboutText.isEmpty) {
    return '';
  }
  const key = 'Curator note: ';
  final idx = aboutText.indexOf(key);
  if (idx < 0) return '';
  return aboutText.substring(idx + key.length).trim();
}

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
    return catalogPlaceEntityFromAlbumPhoto(
      id: id,
      albumId: albumId,
      latinCuratorSnippet:
          '${title.split(' ').take(8).join(' ')}…',
      isFavorite: isFavorite,
      lastViewedMs: lastViewedMs,
    );
  }
}
