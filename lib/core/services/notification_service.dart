import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (_) {},
    );
    _initialized = true;
  }

  /// Bonus: fires a subtle heads-up toast when marking a favorite / travel tip teaser.
  Future<void> favoriteAdded(String placeName) async {
    if (!_initialized) return;
    const androidDetails = AndroidNotificationDetails(
      'travel_channel',
      'Travel updates',
      channelDescription: 'Smart Travel Companion reminders & favorites',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await _plugin.show(
      placeName.hashCode & 0x7fffffff,
      'Saved favorite',
      'You starred $placeName',
      const NotificationDetails(android: androidDetails),
    );
    debugPrint('Notification shown for favorite');
  }

  Future<void> travelTipMorning() async {
    if (!_initialized) return;
    const androidDetails = AndroidNotificationDetails(
      'travel_channel',
      'Travel updates',
      channelDescription: 'Smart Travel Companion reminders & favorites',
    );
    await _plugin.show(
      881,
      'Smart Travel Companion',
      'Tip of the day: open Favorites offline to revisit cached journeys.',
      const NotificationDetails(android: androidDetails),
    );
  }
}
