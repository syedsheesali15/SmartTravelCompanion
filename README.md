# Smart Travel Companion

Smart Travel Application for Flutter Project — **JSONPlaceholder photos** as places, **Open-Meteo** weather, **SQLite** offline cache, **Provider** state, **GoRouter** navigation, and UI guided by `assignment_ui.png`.

## Run

```bash
cd smart_travel_companion
flutter pub get
flutter run
```

Release APK:

```bash
flutter build apk --release
```

> **Windows dev note:** Flutter may warn about symlink/developer mode when native plugins (`sqflite`, etc.) are copied. Enable **Developer Mode** (Settings → System → For developers) if plugin builds fail due to symlink policy.

### Android: Gradle download errors (`Connection reset`, `UnknownHost`, `ExclusiveFileAccessManager`)

That is the **Gradle wrapper** failing to download **`gradle-8.14-all.zip`** (network / VPN / locks). It is **not** a Dart dependency conflict.

1. Close **Android Studio** and extra terminals, then run **one** prefetch (resumes if interrupted):

```powershell
cd smart_travel_companion
powershell -ExecutionPolicy Bypass -File .\scripts\preload_gradle.ps1
```

Or in **Git Bash**: `bash scripts/preload_gradle.sh`

2. Then: `flutter pub get` → `flutter run -d emulator-5554`

### `Failed to decode advisories … advisoriesUpdated`

Harmless **Dart / pub.dev** advisory JSON mismatch; you still get **`Got dependencies!`**. Run **`flutter upgrade`** when convenient to pull a toolchain fix.

## Google Maps (optional)

Without keys, the **map tab uses OpenStreetMap** (`flutter_map`) and shows a hint banner. To use **Google Maps** instead:

### Web (Chrome / `flutter build web`)

1. In [Google Cloud Console](https://console.cloud.google.com/google/maps-apis), enable **Maps JavaScript API** and create an API key.
2. Pass it at compile time (the app injects the Maps script on startup — you do **not** need to edit `web/index.html`):

```bash
flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY_HERE
# release web:
flutter build web --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY_HERE
```

Without the dart-define, the map screen uses OpenStreetMap on web.

### Android

Add to `android/local.properties` (do not commit real keys if the repo is public):

```properties
GOOGLE_MAPS_API_KEY=YOUR_KEY_HERE
```

Enable **Maps SDK for Android** for that key. See comments in `android/app/src/main/AndroidManifest.xml`.

### iOS

Replace `REPLACE_WITH_GOOGLE_MAPS_IOS_API_KEY` in `ios/Runner/Info.plist` with your key and enable **Maps SDK for iOS**.

## Architecture

- `lib/domain` — entities + repository interfaces.
- `lib/data` — remote HTTP + SQLite + repository implementations.
- `lib/presentation` — `provider/` notifiers and `ui/` screens.
- `lib/core` — theme, router, notification helper.

Presentation imports **domain**, not concrete `data` classes. Dependencies are wired in `lib/main.dart`.

## Rubric mapping

| Slice | Highlights |
| --- | --- |
| Animations | `AnimatedContainer`, `AnimatedOpacity`, `AnimatedList` (Explore + Favorites tab), `Hero` on imagery, `AnimatedSize` About section, `AnimatedSwitcher` for weather skeleton/success/error. |
| APIs | Photos: `jsonplaceholder.typicode.com` for catalog ids; **listing images** come from curated [Wikimedia Commons](https://commons.wikimedia.org/) shots matching each seeded destination (better on web than JSONPlaceholder `via.placeholder`). Weather: `api.open-meteo.com` |
| Offline / errors | Cached rows in SQLite, retry banner & empty states similar to mocks. |
| Bonuses | Dark mode (persisted via `shared_preferences`), OpenStreetMap via `flutter_map`, `flutter_local_notifications` on favorite taps + toolbar bell tip, scroll pagination overlays. |

## PythonAnywhere / Flutter Web reminder

**`sqflite` does not compile for Flutter Web.** Ship the graded **Android APK**. Optional: host a **`flutter build web`** artifact as static files on PythonAnywhere and document that persistence differs from Android.
