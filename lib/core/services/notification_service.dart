import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_colors.dart';

/// Single channel ID for Android 8+ tray notifications (must stay in sync everywhere).
const _kAndroidChannelId = 'stc_travel_main';
const _kAndroidChannelName = 'Smart Travel Companion';

final class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  NotificationDetails get _travelDetails => NotificationDetails(
        android: AndroidNotificationDetails(
          _kAndroidChannelId,
          _kAndroidChannelName,
          channelDescription:
              'Favorites, offline tips & gentle travel reminders.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (_) {},
    );

    if (!kIsWeb) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kAndroidChannelId,
          _kAndroidChannelName,
          description:
              'Saves favorites, Explore tips & gentle travel reminders.',
          importance: Importance.high,
        ),
      );
      await android?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  /// Fire-and-forget: local notifications are best-effort.
  Future<void> _safeShow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized || kIsWeb) return;
    try {
      await _plugin.show(id, title, body, _travelDetails);
    } catch (e, st) {
      debugPrint('notification show failed $e $st');
    }
  }

  /// When marking a catalog or world pin as favorite.
  Future<void> favoriteAdded(String placeName) async {
    await _safeShow(
      id: placeName.hashCode & 0x7fffffff,
      title: 'Added to favorites',
      body:
          '$placeName is saved — open My favorites offline anytime.',
    );
    debugPrint('Notification (favorite added) for $placeName');
  }

  /// Shown when opening Map from the drawer — reminds user of trip planning features.
  Future<void> browseMapReminder() async {
    await _safeShow(
      id: 77002,
      title: 'Trip planning on the map',
      body:
          'Pan worldwide, search pins & keep weather strips handy while you explore.',
    );
  }

  /// Settings / QA: two stacked notifications so tray permission can be verified quickly.
  Future<void> showSampleTrayNotifications() async {
    await _safeShow(
      id: 99001,
      title: 'Smart Travel Companion',
      body:
          'SQLite keeps your starred catalog + map pins available offline.',
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _safeShow(
      id: 99002,
      title: 'Favorite a place',
      body:
          'Heart any tile — you\'ll get a ping here and it appears under My favorites.',
    );
  }

  void showTravelTipTopBanner(BuildContext context) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..clearMaterialBanners()
      ..showMaterialBanner(
        MaterialBanner(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 8,
            top: 8,
            bottom: 12,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: .15),
            child: Icon(
              Icons.auto_awesome_outlined,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.primary,
              size: 22,
            ),
          ),
          content: Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                  ),
              children: const [
                TextSpan(
                  text: 'Travel tip ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      "— starred places also ping the notification tray on Android / iOS.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: const Text('OK'),
            ),
          ],
          forceActionsBelow: MediaQuery.of(context).size.width < 400,
          overflowAlignment: OverflowBarAlignment.end,
        ),
      );

    Future<void>.delayed(const Duration(seconds: 5), () {
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.hideCurrentMaterialBanner();
    });

    unawaited(travelTipMorning());
  }

  Future<void> travelTipMorning() async {
    await _safeShow(
      id: 881,
      title: 'Smart Travel Companion',
      body:
          'Tip: Favorite places you discover — SQLite keeps them readable without Wi‑Fi.',
    );
  }
}
