# Smart Travel Companion

Flutter advanced assignment app: **JSONPlaceholder photos** as “places”, **Open-Meteo** weather, **SQLite** offline cache, **Provider** state, **GoRouter** navigation, and UI guided by `assignment_ui.png`.

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
| APIs | Photos: `jsonplaceholder.typicode.com/photos` with paging. Weather: `api.open-meteo.com` with deterministic lat/lng derived from photo id (no separate geocoder). |
| Offline / errors | Cached rows in SQLite, retry banner & empty states similar to mocks. |
| Bonuses | Dark mode (persisted via `shared_preferences`), OpenStreetMap via `flutter_map`, `flutter_local_notifications` on favorite taps + toolbar bell tip, scroll pagination overlays. |

## PythonAnywhere / Flutter Web reminder

**`sqflite` does not compile for Flutter Web.** Ship the graded **Android APK**. Optional: host a **`flutter build web`** artifact as static files on PythonAnywhere and document that persistence differs from Android.
