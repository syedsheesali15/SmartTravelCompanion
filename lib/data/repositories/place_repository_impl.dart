import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/place_entity.dart';
import '../../domain/entities/place_query.dart';
import '../../domain/entities/placeholder_photo.dart';
import '../../domain/repositories/place_repository.dart';
import '../datasources/local_place_datasource.dart';
import '../datasources/remote_place_datasource.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  PlaceRepositoryImpl({
    required RemotePlaceDataSource remote,
    required LocalPlaceDataSource local,
  }) : _remote = remote,
       _local = local;

  final RemotePlaceDataSource _remote;
  final LocalPlaceDataSource _local;

  static const _legacyWorldFavPrefsKey = 'world_geocode_favorite_ids';

  @override
  Future<List<PlaceEntity>> queryLocal(PlaceQuery query) =>
      _local.fetchMatching(query);

  @override
  Future<List<PlaceEntity>> fetchPopularPreview({int limit = 12}) =>
      _local.fetchPopular(limit: limit);

  @override
  Future<void> fetchRemotePage({required int start, required int limit}) async {
    final photos = await _remote.fetchPhotos(start: start, limit: limit);
    await _local.upsertPhotos(photos);
  }

  @override
  Future<PlaceEntity?> getById(int id) => _local.getById(id);

  @override
  Future<void> toggleFavorite(int id, bool value) =>
      _local.updateFavorite(id: id, value: value);

  @override
  Future<void> markRecent(int id) =>
      _local.bumpViewed(id, DateTime.now().millisecondsSinceEpoch);

  @override
  Future<void> migrateLegacyWorldFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_legacyWorldFavPrefsKey);
    if (ids == null || ids.isEmpty) return;
    await _local.migrateLegacyWorldFavoriteStrings(ids);
    await prefs.remove(_legacyWorldFavPrefsKey);
  }

  @override
  Future<void> recordWorldPlaceVisited({
    required double latitude,
    required double longitude,
    required String title,
    required String subtitle,
    required int geocodeSeedId,
    required String thumbnailUrl,
    required String fullImageUrl,
    required String aboutText,
  }) => _local.recordWorldPlaceVisited(
    latitude: latitude,
    longitude: longitude,
    title: title,
    subtitle: subtitle,
    geocodeSeedId: geocodeSeedId,
    thumbnailUrl: thumbnailUrl,
    fullImageUrl: fullImageUrl,
    aboutText: aboutText,
  );

  @override
  Future<bool> isWorldPlaceFavorite(double latitude, double longitude) =>
      _local.isWorldPlaceFavorite(latitude, longitude);

  @override
  Future<void> setWorldPlaceFavorite({
    required PlaceEntity projection,
    required bool favorite,
  }) => _local.applyWorldPlaceFavorite(
    latitude: projection.worldLatitude!,
    longitude: projection.worldLongitude!,
    value: favorite,
    title: projection.title,
    subtitle: projection.locationLine,
    geocodeSeedId: projection.worldGeocodeSeedId,
    thumbnailUrl: projection.thumbnailUrl,
    fullImageUrl: projection.fullImageUrl,
    aboutText: projection.aboutText,
  );

  @override
  Future<PlaceholderPhoto> fetchPlaceholderPhoto(int photoId) async {
    final dto = await _remote.fetchPhotoById(photoId);
    return PlaceholderPhoto(title: dto.title, imageUrl: dto.url);
  }

  @override
  Future<int> countCachedCatalogPlaces() => _local.countPlaces();
}
