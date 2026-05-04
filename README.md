# Smart Travel Companion

**SMD final assignment — Flutter advanced application.** A travel-themed Flutter app that browses a **photo-derived place catalog**, shows **weather** and rich **detail** screens, caches everything in **SQLite** for offline use, and extras such as **dark mode**, an **OpenStreetMap map** (`flutter_map`), **notifications**, and **pagination**.

**HTTP APIs wired in code (three):**

1. **JSONPlaceholder** — download paged `/photos` for the SQLite catalog (and occasional single-photo fetches).  
2. **Open-Meteo Forecast** — `api.open-meteo.com/v1/forecast` for weather at latitude/longitude.  
3. **Open-Meteo Geocoding** — `geocoding-api.open-meteo.com/v1/search` to turn typed place names into coordinates for map search and world previews.

The **map imagery** itself comes from **public OpenStreetMap raster tiles** consumed by **`flutter_map`** (policy + attribution in-app). That is **not** a fourth paid “Maps API key” endpoint in this submission — tiles are fetched as URLs, separate from the three APIs above.

**Version:** `1.0.0+1` (see `pubspec.yaml`)

---

## What the app does

- **Explore (Home)** — Chips for *All*, *Favorites*, and *Recent*; pull-to-refresh patterns; debounced search; filter sheet (sort, region, favorites-only). Catalog rows show image, title, location line, and a heart toggle. List updates use **`AnimatedList`** when new pages arrive from the network.
- **Place detail** — Hero transition from thumbnails; expandable “About” with **`AnimatedSize`**; **`AnimatedSwitcher`** for weather loading vs loaded; weather from coordinates via **Open-Meteo**.
- **Map tab** — Raster map from **`flutter_map`** using **OpenStreetMap** tiles (see [OSM policy / attribution](https://www.openstreetmap.org/copyright)). Pins combine catalog SQLite rows and searches. **Coordinates for search suggestions** come from the **Open-Meteo Geocoding REST API** (`geocoding_remote_datasource.dart`). **Device location** uses **`Geolocator`** (GPS / fused location) when the user grants permission.
- **Favorites** — Only starred catalog + starred “world” rows (SQLite merges). **`AnimatedList`** for removals/visual feedback.
- **Profile** — Local display name, email, default asset avatar plus optional gallery photo; persisted on device.
- **Drawer & shell** — Settings, Downloads/offline catalog info, Help, About, onboarding-style **Landing** route. Bottom nav with animated chrome.

---

## Technical stack

| Area | Choice |
|------|--------|
| **Framework** | Flutter (Dart ^3.11) |
| **State management** | **Provider** — `PlacesNotifier`, `PlaceDetailNotifier`, `ThemeNotifier`, `ProfileNotifier`, `ConnectivityNotifier` |
| **Navigation** | **go_router** — `StatefulShellRoute` tabs + pushed full-screen routes; `extra` for `PlaceEntity` on detail |
| **Local database** | **sqflite** — `places` (catalog), `user_world_places` (geocoded visits/favorites merge) |
| **HTTP** | `http` package; timeouts & error surfacing in notifiers |
| **Images** | `cached_network_image` |
| **Maps** | **`flutter_map`** + OSM tile layers; **`GeocodingRemoteDataSource`** (HTTP JSON to Open‑Meteo Search); **`Geolocator`** for “where I am” on device |
| **Notifications** | `flutter_local_notifications` (Android runtime permission requested where needed) |

---

## Remote APIs (`lib/core/constants/api_constants.dart`)

These are the **three REST JSON endpoints** referenced as constants:

| # | Name | Endpoint (base / path) | Used for |
|---|------|-------------------------|----------|
| 1 | **JSONPlaceholder Photos** | `https://jsonplaceholder.typicode.com/photos` (`?_start=` & `_limit=` for paging; optional `/photos/:id`) | Fetch catalog batches into SQLite (`RemotePlaceDataSource`); hydrate titles/ids for merge with curated thumbnails; spotlight single fetch when needed. |
| 2 | **Open‑Meteo Forecast** | `https://api.open-meteo.com/v1/forecast` | Current weather (temperature, humidity, wind, apparent temp, **WMO `weather_code` → readable label**) for detail screen, map weather strip, and world preview (`WeatherRemoteDataSource`). |
| 3 | **Open‑Meteo Geocoding (search)** | `https://geocoding-api.open-meteo.com/v1/search?name=…` | Resolve free‑text place names → latitude/longitude for **map search autocomplete** and **world place preview routing** (`GeocodingRemoteDataSource`). |

**Map visualization (tiles, not counted as another “API assignment key” above):**

- The **basemap raster** comes from OpenStreetMap family tile servers configured in **`flutter_map`** / `TileLayer` implementations (URLs with zoom/x/y placeholders). Requests are anonymous tile GETs covered by usage policy → **respect OSM attribution** (see Help / About in the app).

Curated imagery and copy for catalog rows are enriched in-app (see `photo_dto` / stock photo helpers) so list tiles reflect real landmarks beyond raw JSONPlaceholder image URLs alone.

---

## Architecture (clean-style layering)

Dependencies point **inward** (presentation → domain ← data):

| Layer | Folder | Responsibility |
|-------|--------|----------------|
| **Domain** | `lib/domain` | Entities (`PlaceEntity`, `WeatherEntity`, …), repository **interfaces**. |
| **Data** | `lib/data` | `RemotePlaceDataSource`, `WeatherRemoteDataSource`, `GeocodingRemoteDataSource`, `LocalPlaceDataSource`, SQLite `AppDatabase`, repository **implementations**. |
| **Presentation** | `lib/presentation` | `provider/` notifiers, `ui/` screens, widgets, shell. |
| **Core** | `lib/core` | Router (`app_router.dart`, `app_route_paths.dart`), theme (`app_theme.dart`), `NotificationService`, geo helpers. **`maps_secrets.dart`** exists only if you voluntarily enable an optional Google/native map path — **not required** for OSM builds. |

Repositories are wired in **`lib/main.dart`** via `Provider` / `ChangeNotifierProvider`.

---

## Offline & error handling

- All primary browse queries read from **SQLite** (`LocalPlaceDataSource.fetchMatching`).
- Hydration pulls remote batches and **upserts** without losing favorites / `viewed_at` where applicable.
- **connectivity_plus** drives an offline strip and retry paths; banners surface network/catalog errors with **retry** affordances.

---

## Animations (assignment-aligned)

| Widget / pattern | Where |
|------------------|--------|
| **`AnimatedContainer`** | Home filter chips (All / Favorites / Recent); shell bottom bar treatment. |
| **`AnimatedOpacity`** | Home (e.g. offline banner fades). |
| **`AnimatedList`** | `ExplorePlacesAnimatedList` + Favorites screen (insert/remove motion). |
| **`Hero`** | Tile / popular strip → detail & world preview headers. |
| **`AnimatedSize`** | Expand/collapse About sections on detail / world preview. |
| **`AnimatedSwitcher`** | Weather / loading states on detail. |

---

## Core vs bonus features (brief)

**Core (brief alignment):** Home + detail APIs, SQLite offline, Provider, GoRouter + complex navigation (`extra`, query routes), mandated animation families, error/empty UX.

**Bonus (submission):**

- **Dark mode** — `ThemeNotifier` + `SharedPreferences`; toggle in drawer and Settings.
- **Maps (bonus)** — **OpenStreetMap** display via **`flutter_map`** + **Geocoding** API #3 above for searchable pins; **Geolocator** for device GPS. *(The repo retains an unused optional path for native Google Maps + keys — **not enabled** in the default build this README describes.)*
- **Notifications** — channel + tray alerts (e.g. new favorite, travel tip from bell icon, map reminder from drawer, sample ping in Settings on mobile).
- **Pagination** — JSONPlaceholder `_start`/`_limit`, `PlacesNotifier.pageSize`, `loadMore` / silent bootstrap pulls; `AnimatedList` inserts.

---

## Run & build

```bash
cd smart_travel_companion
flutter pub get
flutter run
```

Release APK:

```bash
flutter build apk --release
```

Artifact (typical path): **`build/app/outputs/flutter-apk/app-release.apk`**

---

## Troubleshooting

### Windows: symlinks / developer mode

Flutter may warn about symlink/developer mode when native plugins (`sqflite`, etc.) are copied. Enable **Developer Mode** (Settings → System → For developers) if builds fail due to symlink policy.

### Android: Gradle download errors (`Connection reset`, `UnknownHost`, `ExclusiveFileAccessManager`)

The **Gradle wrapper** may fail downloading **`gradle-8.14-all.zip`**. Close Android Studio and extra terminals, then run **one** prefetch (resumes if interrupted):

```powershell
cd smart_travel_companion
powershell -ExecutionPolicy Bypass -File .\scripts\preload_gradle.ps1
```

Or Git Bash: `bash scripts/preload_gradle.sh` — then `flutter pub get` → `flutter run -d emulator-5554`.

### `Failed to decode advisories … advisoriesUpdated`

Harmless **Dart / pub.dev** advisory JSON mismatch if you still see **`Got dependencies!`**. `flutter upgrade` when convenient helps.

---

## Optional native / Google Maps (advanced — **not part of default OSM build**)

The **grading build described in this README** uses **`flutter_map` + OpenStreetMap basemap tiles** plus **Geocoding API #3** for search coordinates — **not** Google Maps HTTP APIs.

The codebase still ships an optional path (`google_maps_flutter`, **`maps_secrets.dart`**, Gradle `GOOGLE_MAPS_API_KEY`, dart-define **`USE_GOOGLE_MAPS=true`**) only for teams that explicitly want Google's SDK instead of tiles. Omit that entirely unless requirements demand it — see **`AndroidManifest.xml`** + `MapsSecrets` if you pursue it later.

---

## Key files for reviewers

| Topic | Files |
|-------|--------|
| API constants | `lib/core/constants/api_constants.dart` |
| Catalog paging | `lib/data/datasources/remote_place_datasource.dart`, `lib/presentation/provider/places_notifier.dart` |
| SQLite queries | `lib/data/datasources/local_place_datasource.dart` |
| Router | `lib/core/router/app_router.dart`, `app_route_paths.dart` |
| Notifications | `lib/core/services/notification_service.dart` |
| Map (OSM + search) | `lib/presentation/ui/map/map_screen.dart`, `open_street_map_body.dart`; HTTP geocode in `geocoding_remote_datasource.dart` |
| Launcher icon tooling | `tool/normalize_launcher_icon.dart`, `flutter_launcher_icons` in `pubspec.yaml` |

---

## Flutter Web vs Android

**`sqflite` does not compile for Flutter Web** the same way as mobile; this project uses **sqflite_common_ffi_web** for optional web demos. For grading, ship the **Android APK**. A **`flutter build web`** build can be hosted as static files; persistence behavior differs.

---

## License / attribution

- **OpenStreetMap** — Map data © OpenStreetMap contributors (see in-app About / Help).  
- **Open-Meteo** — Weather & geocoding services used per their public APIs.

---

## Author notes

Submitted as coursework: **Smart Travel Companion** demonstrates layered architecture, the three documented HTTP integrations (photos + dual Open‑Meteo services), offline SQLite, declarative animations, OpenStreetMap-based mapping, notifications, and pagination.
