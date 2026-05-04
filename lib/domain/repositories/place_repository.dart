import '../entities/place_entity.dart';
import '../entities/place_query.dart';
import '../entities/placeholder_photo.dart';

abstract class PlaceRepository {
  /// Cache-first list for current filters.
  Future<List<PlaceEntity>> queryLocal(PlaceQuery query);

  /// Top picks for the home carousel (ignores search chip; not filtered by favorites sheet).
  Future<List<PlaceEntity>> fetchPopularPreview({int limit = 12});

  /// Pull remote page and merge into SQLite (call [queryLocal] afterwards for UI projection).
  Future<void> fetchRemotePage({required int start, required int limit});

  Future<PlaceEntity?> getById(int id);

  Future<void> toggleFavorite(int id, bool value);

  Future<void> markRecent(int id);

  /// One-time migration from prefs-based world favorites into SQLite.
  Future<void> migrateLegacyWorldFavoritesFromPrefs();

  /// Track opening a worldwide (geocode) preview for Recent alongside catalog visits.
  Future<void> recordWorldPlaceVisited({
    required double latitude,
    required double longitude,
    required String title,
    required String subtitle,
    required int geocodeSeedId,
    required String thumbnailUrl,
    required String fullImageUrl,
    required String aboutText,
  });

  Future<bool> isWorldPlaceFavorite(double latitude, double longitude);

  /// Favorite state for coordinate-based previews (shows in Explore Favorites).
  Future<void> setWorldPlaceFavorite({
    required PlaceEntity projection,
    required bool favorite,
  });

  /// JSONPlaceholder `/photos/:id` — title + image for lightweight UI (e.g. map search).
  Future<PlaceholderPhoto> fetchPlaceholderPhoto(int photoId);

  /// Rows in the local `places` SQLite table (downloaded catalog cache).
  Future<int> countCachedCatalogPlaces();
}
