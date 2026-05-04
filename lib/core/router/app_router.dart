import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/place_entity.dart';
import '../router/app_route_paths.dart';
import '../../presentation/ui/detail/detail_screen.dart';
import '../../presentation/ui/explore/world_place_preview_screen.dart';
import '../../presentation/ui/favorites/favorites_screen.dart';
import '../../presentation/ui/home/home_screen.dart';
import '../../presentation/ui/landing/landing_screen.dart';
import '../../presentation/ui/map/map_screen.dart';
import '../../presentation/ui/pages/about_screen.dart';
import '../../presentation/ui/pages/downloaded_catalog_screen.dart';
import '../../presentation/ui/pages/help_support_screen.dart';
import '../../presentation/ui/pages/settings_screen.dart';
import '../../presentation/ui/pages/route_error_screen.dart';
import '../../presentation/ui/pages/simple_page.dart';
import '../../presentation/ui/profile/profile_screen.dart';
import '../../presentation/ui/shell/main_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: LandingScreen.routePath,
    errorBuilder: (context, state) => RouteErrorScreen(state: state),
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
                path: AppRoutePaths.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.map,
                name: 'map',
                builder: (context, state) => const MapScreen(showAll: true),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.favorites,
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.worldPlace,
        name: 'world-place',
        builder: (context, state) {
          final qp = state.uri.queryParameters;
          final lat = double.tryParse(qp['lat'] ?? '');
          final lng = double.tryParse(qp['lng'] ?? '');
          final title = qp['title'] ?? 'Place';
          final subtitle = qp['subtitle'] ?? '';
          final sid = int.tryParse(qp['sid'] ?? '0') ?? 0;
          if (lat == null || lng == null) {
            return const SimplePage(
              title: 'Place unavailable',
              subtitle: 'Missing coordinates for this preview.',
            );
          }
          return WorldPlacePreviewScreen(
            latitude: lat,
            longitude: lng,
            title: title,
            subtitle: subtitle,
            geocodeSeedId: sid,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/place/:placeId',
        name: 'place-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['placeId']!);
          final raw = state.extra;
          PlaceEntity? seed =
              raw is PlaceEntity && raw.id == id ? raw : null;
          return DetailScreen(placeId: id, initialPlace: seed);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.downloads,
        builder: (context, state) => const DownloadedCatalogScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.help,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutePaths.mapTarget,
        name: 'map-target',
        builder: (context, state) {
          final qp = state.uri.queryParameters;
          final lat = double.tryParse(qp['lat'] ?? '');
          final lng = double.tryParse(qp['lng'] ?? '');
          final title = qp['title'] ?? 'Pinned place';
          if (lat == null || lng == null) {
            return const SimplePage(
              title: 'Map unavailable',
              subtitle: 'Missing coordinates.',
            );
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
