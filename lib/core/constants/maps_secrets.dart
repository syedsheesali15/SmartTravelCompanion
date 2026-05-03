/// Pass at build/run time for **web**: enables Google Maps instead of OSM fallback.
/// Example:
/// `flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=your_key_here`
/// You must paste the **same key** into [web/index.html] (Maps JavaScript API script).
abstract final class MapsSecrets {
  static const String dartDefineGoogleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Web loads the Maps JS SDK from index.html — we only switch widgets when key is wired.
  static bool get googleMapsDartDefineProvided => dartDefineGoogleMapsApiKey.isNotEmpty;
}
