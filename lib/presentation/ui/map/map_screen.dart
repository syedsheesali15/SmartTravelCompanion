import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/maps_secrets.dart';
import '../../../../core/maps/maps_capabilities.dart';
import '../../../domain/entities/place_entity.dart';
import '../../../domain/entities/place_query.dart';
import '../../../domain/repositories/place_repository.dart';
import '../../provider/places_notifier.dart';
import 'google_maps_body.dart';
import 'open_street_map_body.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
    required this.showAll,
    this.latitude,
    this.longitude,
    this.caption,
  });

  final bool showAll;
  final double? latitude;
  final double? longitude;
  final String? caption;

  bool _preferGoogleMaps() {
    if (!MapsCapabilities.sdkRunsGoogleMaps) return false;
    if (kIsWeb) return MapsSecrets.googleMapsDartDefineProvided;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final refreshSalt = context.select<PlacesNotifier, int>((n) => n.refreshCounter);
    final repo = context.read<PlaceRepository>();
    final useGoogle = _preferGoogleMaps();

    return FutureBuilder<List<PlaceEntity>>(
      key: ValueKey('$refreshSalt-${showAll ? 'browse' : 'pin'}'),
      future: repo.queryLocal(PlaceQuery.initial),
      builder: (context, snapshot) {
        final appBar = AppBar(
          title: Text(showAll ? 'Pinned adventures' : (caption ?? 'Map')),
        );

        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(appBar: appBar, body: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: appBar,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load cached places:\n${snapshot.error}'),
              ),
            ),
          );
        }

        final catalog = snapshot.data ?? const <PlaceEntity>[];
        /// Pins from the entire SQLite catalog on the browse map; detail "View on map" uses a single marker.
        final pinList = showAll ? catalog : const <PlaceEntity>[];

        final lat = latitude ?? 0;
        final lng = longitude ?? 0;
        final fallbackCenter = OpenStreetMapBody.computeCenter(
          showAll: showAll,
          places: catalog,
          latitude: lat,
          longitude: lng,
        );
        final fallbackMarkers = OpenStreetMapBody.buildMarkers(
          showAll: showAll,
          places: catalog,
          latitude: lat,
          longitude: lng,
        );
        final fallbackZoom = OpenStreetMapBody.zoomFor(showAll);

        return Scaffold(
          appBar: appBar,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: useGoogle
                    ? GoogleMapsBody(
                        showAll: showAll,
                        places: pinList,
                        singleLat: latitude,
                        singleLng: longitude,
                        markerTitle: caption ?? 'Pinned place',
                      )
                    : OpenStreetMapBody(
                        center: fallbackCenter,
                        markers: fallbackMarkers,
                        initialZoom: fallbackZoom,
                      ),
              ),
              if (!useGoogle)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    minimum: const EdgeInsets.all(12),
                    child: Material(
                      elevation: 3,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.layers_outlined, color: AppColors.primary.withValues(alpha: .85)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                MapsCapabilities.sdkRunsGoogleMaps
                                    ? kIsWeb
                                        ? 'OpenStreetMap — add dart-define GOOGLE_MAPS_API_KEY plus the Maps JS script key in web/index.html to use Google.'
                                        : 'OpenStreetMap on this platform.'
                                    : 'OpenStreetMap — Google Maps runs on Android, iOS, and web once keys & SDK prerequisites are configured.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
