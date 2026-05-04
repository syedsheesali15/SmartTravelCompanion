import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  static Future<void> _installPlacesSchema(Database db) async {
    await db.execute('DROP TABLE IF EXISTS places');
    await db.execute('''
CREATE TABLE places (
  id INTEGER PRIMARY KEY,
  album_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  thumbnail_url TEXT NOT NULL,
  location_line TEXT NOT NULL,
  about_text TEXT NOT NULL,
  region_bucket TEXT NOT NULL,
  is_favorite INTEGER NOT NULL DEFAULT 0,
  viewed_at INTEGER
);
''');
    await db.execute('CREATE INDEX idx_places_fav ON places(is_favorite);');
    await db.execute('CREATE INDEX idx_places_viewed ON places(viewed_at);');
    await db.execute(
      'CREATE INDEX idx_places_search ON places(title, location_line, region_bucket);',
    );
  }

  static Future<void> _installWorldPlacesTable(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS user_world_places (
  slot_key TEXT PRIMARY KEY NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  geocode_seed_id INTEGER NOT NULL DEFAULT 0,
  thumbnail_url TEXT NOT NULL,
  full_image_url TEXT NOT NULL,
  about_text TEXT NOT NULL,
  viewed_at INTEGER,
  updated_at INTEGER NOT NULL,
  is_favorite INTEGER NOT NULL DEFAULT 0
);
''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_user_world_viewed ON user_world_places(viewed_at);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_user_world_fav ON user_world_places(is_favorite);',
    );
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    // Web sqflite_common_ffi_web expects a logical name (IndexedDB), not OS paths.
    final path = kIsWeb
        ? 'smart_travel_companion.db'
        : p.join(
            (await getApplicationDocumentsDirectory()).path,
            'smart_travel_companion.db',
          );
    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _installPlacesSchema(db);
        await _installWorldPlacesTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _installPlacesSchema(db);
        }
        if (oldVersion < 3) {
          await _installWorldPlacesTable(db);
        }
      },
    );
    return _db!;
  }
}
