/// Single source of truth for GoRouter paths (shell, modals, deep links).
abstract final class AppRoutePaths {
  static const landing = '/landing';
  static const home = '/home';
  static const map = '/map';
  static const favorites = '/favorites';
  static const profile = '/profile';

  static const downloads = '/downloads';
  static const settings = '/settings';
  static const help = '/help';
  static const about = '/about';

  static const worldPlace = '/world-place';
  static const mapTarget = '/map/target';

  static String placeDetail(int placeId) => '/place/$placeId';

  /// Query string for `/world-place` (lat/lng degrees, URIs-encoded text).
  static String worldPlaceQuery({
    required double lat,
    required double lng,
    required String title,
    required String subtitle,
    required int geocodeSeedId,
  }) {
    return '?lat=$lat&lng=$lng&title=${Uri.encodeComponent(title)}'
        '&subtitle=${Uri.encodeComponent(subtitle)}'
        '&sid=$geocodeSeedId';
  }

  static String mapTargetQuery({
    required double lat,
    required double lng,
    required String title,
  }) {
    return '?lat=$lat&lng=$lng&title=${Uri.encodeComponent(title)}';
  }
}
