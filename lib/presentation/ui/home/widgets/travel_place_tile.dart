import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_navigation.dart';
import '../../../../domain/entities/place_entity.dart';

extension TravelPlaceSubtitle on PlaceEntity {
  /// Second line under curated title ("New Zealand" when line is "Lake Tekapo, New Zealand").
  String get subtitleLine {
    final parts = locationLine
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.length <= 1) return locationLine;
    return parts.sublist(1).join(', ');
  }
}

/// Explore Places kit: image (rounded top), white footer, heart aligned right in text row (not on photo).
class TravelPlaceTile extends StatelessWidget {
  const TravelPlaceTile({
    super.key,
    required this.place,
    required this.animation,
    required this.onFavorite,
  });

  final PlaceEntity place;
  final Animation<double> animation;
  final VoidCallback onFavorite;

  static const _radius = 18.0;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final titleColor = light ? const Color(0xFF0F172A) : null;
    final subtitleColor = light
        ? const Color(0xFF64748B)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final heartMuted = light ? const Color(0xFFCBD5E1) : Colors.white54;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
      side: BorderSide(
        color: light
            ? const Color(0xFFF1F5F9)
            : Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: .35),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: Material(
          color: light ? Colors.white : Theme.of(context).colorScheme.surface,
          elevation: light ? 2 : 4,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: light ? .08 : .28),
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (place.worldLatitude != null && place.worldLongitude != null) {
                context.pushWorldPlacePreview(
                  latitude: place.worldLatitude!,
                  longitude: place.worldLongitude!,
                  title: place.title,
                  subtitle: place.locationLine,
                  geocodeSeedId: place.worldGeocodeSeedId,
                );
              } else {
                context.pushPlaceDetail(place);
              }
            },
            borderRadius: BorderRadius.circular(_radius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(_radius),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Hero(
                      tag: 'place-${place.id}',
                      child: CachedNetworkImage(
                        imageUrl: place.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) =>
                            Container(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 4, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        titleColor ??
                                        Theme.of(context).colorScheme.onSurface,
                                    fontSize: light ? 17 : null,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              place.subtitleLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: subtitleColor,
                                    fontSize: light ? 14 : null,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        splashRadius: 22,
                        onPressed: onFavorite,
                        icon: Icon(
                          place.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline,
                          color: place.isFavorite
                              ? AppColors.accentHeart
                              : heartMuted,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
