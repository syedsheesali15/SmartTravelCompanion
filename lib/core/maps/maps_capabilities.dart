import 'maps_capabilities_stub.dart'
    if (dart.library.html) 'maps_capabilities_web.dart'
    if (dart.library.io) 'maps_capabilities_io.dart' as plat;

abstract final class MapsCapabilities {
  /// True for Android/iOS/Web. False for desktop (Windows/Linux/macOS) where Maps SDK UI is unsupported.
  static bool get sdkRunsGoogleMaps => plat.googleMapsPlatformSupported;
}
