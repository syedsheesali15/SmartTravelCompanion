import 'package:sqflite/sqflite.dart';

import '../../core/geo/place_stock_photos.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/place_query.dart';
import '../models/photo_dto.dart';
import 'app_database.dart';

class LocalPlaceDataSource {
  LocalPlaceDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> upsertPhotos(List<PhotoDto> photos) async {
    if (photos.isEmpty) return;
    final db = await _database.database;
    final ids = photos.map((e) => e.id).toList();
    final existing = <int, Map<String, Object?>>{};
    if (ids.isNotEmpty) {
      final ph = List.filled(ids.length, '?').join(',');
      final rows = await db.rawQuery(
        'SELECT id, is_favorite, viewed_at FROM places WHERE id IN ($ph)',
        ids,
      );
      for (final row in rows) {
        existing[row['id']! as int] = row;
      }
    }

    final batch = db.batch();
    for (final photo in photos) {
      final row = existing[photo.id];
      final fav = row == null ? 0 : (row['is_favorite'] as int? ?? 0);
      final viewed = row == null ? null : row['viewed_at'] as int?;
      final entity = photo.toEntity(isFavorite: fav == 1, lastViewedMs: viewed);
      batch.insert(
        'places',
        _toRow(entity),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Map<String, Object?> _toRow(PlaceEntity e) => {
    'id': e.id,
    'album_id': e.albumId,
    'title': e.title,
    'url': e.fullImageUrl,
    'thumbnail_url': e.thumbnailUrl,
    'location_line': e.locationLine,
    'about_text': e.aboutText,
    'region_bucket': e.regionBucket,
    'is_favorite': e.isFavorite ? 1 : 0,
    'viewed_at': e.lastViewedMs,
  };

  PlaceEntity _fromRow(Map<String, Object?> row) {
    final id = row['id']! as int;
    final albumId = row['album_id']! as int;
    final photos = curatedSpotPhotos(albumId: albumId, photoId: id);
    return PlaceEntity(
      id: id,
      albumId: albumId,
      title: row['title']! as String,
      fullImageUrl: photos.fullImageUrl,
      thumbnailUrl: photos.thumbnailUrl,
      locationLine: row['location_line']! as String,
      aboutText: row['about_text']! as String,
      regionBucket: row['region_bucket']! as String,
      isFavorite: (row['is_favorite'] as int) == 1,
      lastViewedMs: row['viewed_at'] as int?,
      worldLatitude: null,
      worldLongitude: null,
      worldGeocodeSeedId: 0,
    );
  }

  Future<List<PlaceEntity>> fetchMatching(PlaceQuery query) async {
    final buffer = StringBuffer('1 = 1');
    final args = <Object?>[];

    final searchNeedle = _safeSearchNeedle(query.search);
    // While searching, chip filters (Favorites/Recent) are ignored so queries match catalog-wide.
    final filterByChip = searchNeedle == null;

    if (filterByChip) {
      switch (query.chip) {
        case HomeChip.favorites:
          buffer.write(' AND is_favorite = 1');
          break;
        case HomeChip.recent:
          buffer.write(' AND viewed_at IS NOT NULL');
          break;
        case HomeChip.all:
          break;
      }
    }

    if (query.region != 'All') {
      buffer.write(' AND region_bucket = ?');
      args.add(query.region);
    }
    if (query.showFavoritesOnly) {
      buffer.write(' AND is_favorite = 1');
    }

    if (searchNeedle != null) {
      final like = '%$searchNeedle%';
      buffer.write(
        ' AND ('
        'LOWER(title) LIKE ? OR '
        'LOWER(location_line) LIKE ? OR '
        'LOWER(about_text) LIKE ? OR '
        'LOWER(region_bucket) LIKE ? OR '
        'CAST(album_id AS TEXT) LIKE ? OR '
        'CAST(id AS TEXT) LIKE ?'
        ')',
      );
      args.addAll([like, like, like, like, like, like]);
    }

    final orderClause = switch (query.sort) {
      PlaceSort.recommended => 'album_id DESC, id ASC',
      PlaceSort.titleAsc => 'title COLLATE NOCASE ASC',
      PlaceSort.titleDesc => 'title COLLATE NOCASE DESC',
      PlaceSort.idAsc => 'id ASC',
    };

    final trailing = filterByChip && query.chip == HomeChip.recent
        ? 'viewed_at DESC, id ASC'
        : orderClause;

    final raw = await _runSqlSelect(
      whereSql: buffer.toString(),
      whereArgs: args,
      orderBy: trailing,
    );
    var catalog = _dedupeByDisplayKey(raw);

    final allowWorld = query.region == 'All';
    if (!allowWorld) {
      return catalog;
    }

    if (searchNeedle != null) {
      final geo = await _fetchWorldPlacesMatchingSearch(searchNeedle);
      final merged = [...catalog, ...geo];
      _sortCombinedExplore(merged, query.sort);
      return merged;
    }

    final wantsRecentMerged = filterByChip && query.chip == HomeChip.recent;
    final wantsFavoritesMerged =
        (filterByChip && query.chip == HomeChip.favorites) ||
        query.showFavoritesOnly;

    if (wantsRecentMerged) {
      final geo = await _fetchWorldRecentPlaces();
      final merged = [...catalog, ...geo];
      merged.sort(
        (a, b) => (b.lastViewedMs ?? 0).compareTo(a.lastViewedMs ?? 0),
      );
      return merged;
    }

    if (wantsFavoritesMerged) {
      final geo = await _fetchWorldFavoritePlaces();
      final merged = [...catalog, ...geo];
      _sortCombinedExplore(merged, query.sort);
      return merged;
    }

    return catalog;
  }

  void _sortCombinedExplore(List<PlaceEntity> items, PlaceSort sort) {
    switch (sort) {
      case PlaceSort.titleAsc:
        items.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case PlaceSort.titleDesc:
        items.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case PlaceSort.idAsc:
        items.sort((a, b) => a.id.compareTo(b.id));
        break;
      case PlaceSort.recommended:
        items.sort((a, b) {
          final c = b.albumId.compareTo(a.albumId);
          if (c != 0) return c;
          return a.id.compareTo(b.id);
        });
        break;
    }
  }

  static String geoSlotKey(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(5)}_${longitude.toStringAsFixed(5)}';

  static int syntheticWorldPlaceId(String slotKey) {
    var h = 5381;
    for (final u in slotKey.codeUnits) {
      h = ((h << 5) + h) + u;
    }
    var n = h.abs();
    if (n < 10000) {
      n += 7919 * slotKey.length;
    }
    n = n % 2000000000;
    if (n == 0) n = 1;
    return -n.toInt();
  }

  PlaceEntity _worldRowToEntity(Map<String, Object?> row) {
    final key = row['slot_key']! as String;
    final lat = (row['latitude'] as num).toDouble();
    final lng = (row['longitude'] as num).toDouble();
    final seedRaw = row['geocode_seed_id'];
    final seed = seedRaw is int ? seedRaw : (seedRaw as num?)?.toInt() ?? 0;
    return PlaceEntity(
      id: syntheticWorldPlaceId(key),
      albumId: 0,
      title: row['title']! as String,
      fullImageUrl: row['full_image_url']! as String,
      thumbnailUrl: row['thumbnail_url']! as String,
      locationLine: row['subtitle']! as String,
      aboutText: row['about_text']! as String,
      regionBucket: 'World',
      isFavorite: ((row['is_favorite'] as int?) ?? 0) == 1,
      lastViewedMs: row['viewed_at'] as int?,
      worldLatitude: lat,
      worldLongitude: lng,
      worldGeocodeSeedId: seed,
    );
  }

  Future<List<PlaceEntity>> _fetchWorldRecentPlaces() async {
    final db = await _database.database;
    final rows = await db.query(
      'user_world_places',
      where: 'viewed_at IS NOT NULL',
      orderBy: 'viewed_at DESC',
    );
    return rows.map(_worldRowToEntity).toList();
  }

  Future<List<PlaceEntity>> _fetchWorldFavoritePlaces() async {
    final db = await _database.database;
    final rows = await db.query(
      'user_world_places',
      where: 'is_favorite = 1',
      orderBy: 'updated_at DESC',
    );
    return rows.map(_worldRowToEntity).toList();
  }

  Future<List<PlaceEntity>> _fetchWorldPlacesMatchingSearch(
    String needleLowercase,
  ) async {
    final db = await _database.database;
    final like = '%$needleLowercase%';
    final rows = await db.query(
      'user_world_places',
      where: 'LOWER(title) LIKE ? OR LOWER(subtitle) LIKE ?',
      whereArgs: [like, like],
      orderBy: 'updated_at DESC',
    );
    return rows.map(_worldRowToEntity).toList();
  }

  /// Call when opening a worldwide preview so it appears under Recent with other visits.
  Future<void> recordWorldPlaceVisited({
    required double latitude,
    required double longitude,
    required String title,
    required String subtitle,
    required int geocodeSeedId,
    required String thumbnailUrl,
    required String fullImageUrl,
    required String aboutText,
  }) async {
    final db = await _database.database;
    final key = geoSlotKey(latitude, longitude);
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await db.query(
      'user_world_places',
      where: 'slot_key = ?',
      whereArgs: [key],
    );
    final prevFav = existing.isEmpty
        ? 0
        : ((existing.first['is_favorite'] as int?) ?? 0);

    await db.insert('user_world_places', <String, Object?>{
      'slot_key': key,
      'latitude': latitude,
      'longitude': longitude,
      'title': title,
      'subtitle': subtitle,
      'geocode_seed_id': geocodeSeedId,
      'thumbnail_url': thumbnailUrl,
      'full_image_url': fullImageUrl,
      'about_text': aboutText,
      'viewed_at': now,
      'updated_at': now,
      'is_favorite': prevFav,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Toggle heart for coordinate-based places (search-anywhere previews).
  Future<void> applyWorldPlaceFavorite({
    required double latitude,
    required double longitude,
    required bool value,
    required String title,
    required String subtitle,
    required int geocodeSeedId,
    required String thumbnailUrl,
    required String fullImageUrl,
    required String aboutText,
  }) async {
    final db = await _database.database;
    final key = geoSlotKey(latitude, longitude);
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await db.query(
      'user_world_places',
      where: 'slot_key = ?',
      whereArgs: [key],
    );
    final next = value ? 1 : 0;

    if (existing.isEmpty) {
      await db.insert('user_world_places', <String, Object?>{
        'slot_key': key,
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
        'subtitle': subtitle,
        'geocode_seed_id': geocodeSeedId,
        'thumbnail_url': thumbnailUrl,
        'full_image_url': fullImageUrl,
        'about_text': aboutText,
        'viewed_at': null,
        'updated_at': now,
        'is_favorite': next,
      });
    } else {
      await db.update(
        'user_world_places',
        {
          'is_favorite': next,
          'updated_at': now,
          'title': title,
          'subtitle': subtitle,
          'thumbnail_url': thumbnailUrl,
          'full_image_url': fullImageUrl,
          'about_text': aboutText,
          'geocode_seed_id': geocodeSeedId,
        },
        where: 'slot_key = ?',
        whereArgs: [key],
      );
    }
  }

  Future<bool> isWorldPlaceFavorite(double latitude, double longitude) async {
    final db = await _database.database;
    final key = geoSlotKey(latitude, longitude);
    final rows = await db.query(
      'user_world_places',
      columns: ['is_favorite'],
      where: 'slot_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    return ((rows.first['is_favorite'] as int?) ?? 0) == 1;
  }

  /// Migration from SharedPreferences `world_geocode_favorite_ids` before SQLite storage.
  Future<void> migrateLegacyWorldFavoriteStrings(List<String> rawIds) async {
    if (rawIds.isEmpty) return;

    final db = await _database.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final photos = curatedSpotPhotos(albumId: 1, photoId: 1);

    for (final raw in rawIds) {
      final parts = raw.split('|');
      if (parts.length != 2) continue;
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat == null || lng == null) continue;
      final key = geoSlotKey(lat, lng);
      final existing = await db.query(
        'user_world_places',
        where: 'slot_key = ?',
        whereArgs: [key],
      );
      if (existing.isNotEmpty) {
        await db.update(
          'user_world_places',
          {'is_favorite': 1, 'updated_at': now},
          where: 'slot_key = ?',
          whereArgs: [key],
        );
      } else {
        await db.insert('user_world_places', <String, Object?>{
          'slot_key': key,
          'latitude': lat,
          'longitude': lng,
          'title': 'Saved place',
          'subtitle': '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
          'geocode_seed_id': 0,
          'thumbnail_url': photos.thumbnailUrl,
          'full_image_url': photos.fullImageUrl,
          'about_text': 'Open this favorite to reload full details.',
          'viewed_at': null,
          'updated_at': now,
          'is_favorite': 1,
        });
      }
    }
  }

  /// Several remote photo ids can map to the same curated title + location (see
  /// [syntheticTravelSpotIndex]). Without this, "Favorites" shows duplicate cards
  /// for the same destination.
  List<PlaceEntity> _dedupeByDisplayKey(List<PlaceEntity> items) {
    final seen = <String, PlaceEntity>{};
    final order = <String>[];
    for (final p in items) {
      final k = '${p.title}\x1F${p.locationLine}';
      final existing = seen[k];
      if (existing == null) {
        seen[k] = p;
        order.add(k);
        continue;
      }
      final merged = existing.isFavorite || p.isFavorite
          ? existing.copyWith(isFavorite: true)
          : existing;
      seen[k] = merged;
    }
    return order.map((k) => seen[k]!).toList();
  }

  /// Strip LIKE metacharacters — JSONPlaceholder searches are alphanumeric.
  String? _safeSearchNeedle(String raw) {
    final t = raw.trim().toLowerCase();
    if (t.isEmpty) return null;
    final cleaned = StringBuffer();
    for (final code in t.runes) {
      final c = String.fromCharCode(code);
      if (c == '%' || c == '_' || c == '\\') continue;
      cleaned.write(c);
    }
    var out = cleaned.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (out.isEmpty) return null;
    if (out.length > 120) out = out.substring(0, 120);
    return out;
  }

  Future<List<PlaceEntity>> _runSqlSelect({
    required String whereSql,
    required List<Object?> whereArgs,
    required String orderBy,
  }) async {
    final db = await _database.database;
    final rows = await db.query(
      'places',
      where: whereSql,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return rows.map(_fromRow).toList();
  }

  Future<PlaceEntity?> getById(int id) async {
    final db = await _database.database;
    final rows = await db.query(
      'places',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> updateFavorite({required int id, required bool value}) async {
    final db = await _database.database;
    final rows = await db.query(
      'places',
      columns: ['title', 'location_line'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final title = rows.first['title']! as String;
    final locationLine = rows.first['location_line']! as String;
    await db.update(
      'places',
      {'is_favorite': value ? 1 : 0},
      where: 'title = ? AND location_line = ?',
      whereArgs: [title, locationLine],
    );
  }

  Future<void> bumpViewed(int id, int millis) async {
    final db = await _database.database;
    await db.update(
      'places',
      {'viewed_at': millis},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PlaceEntity>> fetchPopular({int limit = 12}) async {
    final db = await _database.database;
    final rows = await db.query(
      'places',
      orderBy: 'album_id DESC, id ASC',
      limit: limit * 4,
    );
    final deduped = _dedupeByDisplayKey(rows.map(_fromRow).toList());
    if (deduped.length <= limit) return deduped;
    return deduped.sublist(0, limit);
  }

  Future<int> countPlaces() async {
    final db = await _database.database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM places');
    final c = Sqflite.firstIntValue(res);
    return c ?? 0;
  }
}
