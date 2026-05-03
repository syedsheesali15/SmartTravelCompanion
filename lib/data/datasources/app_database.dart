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
    await db.execute('CREATE INDEX idx_places_search ON places(title, location_line, region_bucket);');
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    // Web sqflite_common_ffi_web expects a logical name (IndexedDB), not OS paths.
    final path = kIsWeb
        ? 'smart_travel_companion.db'
        : p.join((await getApplicationDocumentsDirectory()).path, 'smart_travel_companion.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _installPlacesSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _installPlacesSchema(db);
        }
      },
    );
    return _db!;
  }
}
