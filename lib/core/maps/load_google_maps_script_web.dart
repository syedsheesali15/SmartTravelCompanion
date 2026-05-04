import 'dart:async';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../constants/maps_secrets.dart';

/// Injects the Maps JavaScript API when [GOOGLE_MAPS_API_KEY] is passed via --dart-define.
Future<void> loadGoogleMapsScriptIfConfigured() async {
  final key = MapsSecrets.dartDefineGoogleMapsApiKey;
  if (key.isEmpty) return;

  final head = html.document.head;
  if (head == null) return;

  for (final node in html.document.querySelectorAll('script')) {
    if (node is! html.ScriptElement) continue;
    final src = node.src;
    if (src.contains('maps.googleapis.com/maps/api/js')) return;
  }

  final completer = Completer<void>();
  final script = html.ScriptElement()
    ..async = true
    ..src = 'https://maps.googleapis.com/maps/api/js?key=${Uri.encodeComponent(key)}';
  script.onLoad.listen((_) {
    if (!completer.isCompleted) completer.complete();
  });
  script.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.completeError(StateError('Failed to load Google Maps JavaScript API'));
    }
  });
  head.append(script);
  await completer.future;
}
