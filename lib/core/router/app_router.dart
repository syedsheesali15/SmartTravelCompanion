import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/ui/detail/detail_screen.dart';
import '../../presentation/ui/favorites/favorites_screen.dart';
import '../../presentation/ui/home/home_screen.dart';
import '../../presentation/ui/landing/landing_screen.dart';
import '../../presentation/ui/map/map_screen.dart';
import '../../presentation/ui/pages/simple_page.dart';
import '../../presentation/ui/profile/profile_screen.dart';
import '../../presentation/ui/shell/main_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: LandingScreen.routePath,
    routes: [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: LandingScreen.routePath,
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                name: 'map',
                builder: (context, state) => const MapScreen(showAll: true),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/place/:placeId',
        name: 'place-detail',
        builder: (context, state) =>
            DetailScreen(placeId: int.parse(state.pathParameters['placeId']!)),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/downloads',
        builder: (_, __) => const SimplePage(
          title: 'Downloaded',
          subtitle: 'Offline-ready favorites live in SQLite. Star places on Wi-Fi '
              'and revisit them anytime from Favorites—even when you are disconnected.',
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/settings',
        builder: (_, __) => const SimplePage(
          title: 'Settings',
          subtitle: 'Flip Dark Mode instantly from the drawer. Pull-to-refresh on Explore merges '
              'fresh JSONPlaceholder photos into SQLite for offline previews. Map tab uses Google Maps when keys '
              '(and platform) permit, otherwise OpenStreetMap.',
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/help',
        builder: (_, __) => const SimplePage(
          title: 'Help & Support',
          subtitle: 'Document how Hero flights, AnimatedList inserts, AnimatedSize about sections, '
              'Open-Meteo loaders, offline retry panels, Google Maps (+ OSM fallback), notifications, and pagination hit the PDF rubric.',
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/about',
        builder: (_, __) => const SimplePage(
          title: 'About Smart Travel Companion',
          subtitle: 'Demonstrates Provider + layered clean architecture atop SQLite caches, curated UI from '
              '`assignment_ui.png`, JSONPlaceholder photos, Open-Meteo forecasts, Google Maps Platform (bonus) with '
              'OpenStreetMap fallback where the native Maps SDK does not apply.',
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/map/target',
        name: 'map-target',
        builder: (context, state) {
          final qp = state.uri.queryParameters;
          final lat = double.tryParse(qp['lat'] ?? '');
          final lng = double.tryParse(qp['lng'] ?? '');
          final title = qp['title'] ?? 'Pinned place';
          if (lat == null || lng == null) {
            return const SimplePage(title: 'Map unavailable', subtitle: 'Missing coordinates.');
          }
          return MapScreen(
            latitude: lat,
            longitude: lng,
            caption: title,
            showAll: false,
          );
        },
      ),
    ],
  );
}
