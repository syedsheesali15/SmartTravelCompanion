import 'package:flutter/material.dart';

/// Rounded-square travel mark (matches launcher art in `assets/images/app_icon.png`).
class AppBrandIcon extends StatelessWidget {
  const AppBrandIcon({
    super.key,
    this.size = 56,
    this.borderRadius = 14,
  });

  static const assetPath = 'assets/images/app_icon.png';

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final px = (size * dpr).ceil().clamp(1, 4096);
    final imageProvider = ResizeImage(
      AssetImage(assetPath),
      width: px,
      height: px,
      allowUpscaling: true,
      policy: ResizeImagePolicy.fit,
    );
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),
        ),
      ),
    );
  }
}
