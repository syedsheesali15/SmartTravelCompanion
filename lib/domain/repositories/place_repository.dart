import '../entities/place_entity.dart';
import '../entities/place_query.dart';

abstract class PlaceRepository {
  /// Cache-first list for current filters.
  Future<List<PlaceEntity>> queryLocal(PlaceQuery query);

  /// Top picks for the home carousel (ignores search chip; not filtered by favorites sheet).
  Future<List<PlaceEntity>> fetchPopularPreview({int limit = 12});

  /// Pull remote page and merge into SQLite (call [queryLocal] afterwards for UI projection).
  Future<void> fetchRemotePage({
    required int start,
    required int limit,
  });

  Future<PlaceEntity?> getById(int id);

  Future<void> toggleFavorite(int id, bool value);

  Future<void> markRecent(int id);
}
