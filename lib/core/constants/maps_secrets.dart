/// Pass at **web** build/run time to enable Google Maps instead of OSM.
/// The Maps JavaScript SDK is injected automatically — no edits to `web/index.html`.
/// Enable **Maps JavaScript API** for the key in Google Cloud Console.
/// Example: `flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=your_key_here`
abstract final class MapsSecrets {
  static const String dartDefineGoogleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static bool get googleMapsDartDefineProvided =>
      dartDefineGoogleMapsApiKey.isNotEmpty;

  /// Native (Android/iOS): set `--dart-define=USE_GOOGLE_MAPS=true` **and** valid SDK keys
  /// to use Google; otherwise OpenStreetMap is used so map tiles load without Google Cloud.
  static const bool useGoogleMapsNative = bool.fromEnvironment(
    'USE_GOOGLE_MAPS',
    defaultValue: false,
  );
}
