import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_colors.dart';

final class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

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

  /// In-app popup under the Explore [AppBar] + optional tray notification ([travelTipMorning]).
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
                      "— open Favorites offline to revisit cached places.",
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

    travelTipMorning();
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
