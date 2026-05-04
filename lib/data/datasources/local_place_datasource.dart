import 'package:sqflite/sqflite.dart';

import '../../core/geo/place_stock_photos.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/entities/place_query.dart';
import '../models/photo_dto.dart';
import 'app_database.dart';

class LocalPlaceDataSource {
  LocalPlaceDataSource({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

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
      final entity = photo.toEntity(
        isFavorite: fav == 1,
        lastViewedMs: viewed,
      );
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

    final orderClause =
        switch (query.sort) {
          PlaceSort.recommended => 'album_id DESC, id ASC',
          PlaceSort.titleAsc => 'title COLLATE NOCASE ASC',
          PlaceSort.titleDesc => 'title COLLATE NOCASE DESC',
          PlaceSort.idAsc => 'id ASC',
        };

    final trailing =
        filterByChip && query.chip == HomeChip.recent ? 'viewed_at DESC, id ASC' : orderClause;

    return _runSqlSelect(
      whereSql: buffer.toString(),
      whereArgs: args,
      orderBy: trailing,
    );
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
    final rows = await db.query('places', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> updateFavorite({required int id, required bool value}) async {
    final db = await _database.database;
    await db.update(
      'places',
      {'is_favorite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
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
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  Future<int> countPlaces() async {
    final db = await _database.database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM places');
    final c = Sqflite.firstIntValue(res);
    return c ?? 0;
  }
}
