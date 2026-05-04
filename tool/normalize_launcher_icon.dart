// Composites app_icon.png into an opaque disk on #0B0E14 so Android's circular
// adaptive mask does not leave "square inscribed in circle" wedge artifacts.
//
// dart run tool/normalize_launcher_icon.dart
// dart run flutter_launcher_icons

import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

const _size = 1024;
const _br = 11, _bg = 14, _bb = 20; // #0B0E14

double _mix(num a, num b, num t) =>
    (a + (b - a) * t).toDouble();

void main() {
  final f = File('assets/images/app_icon.png');
  if (!f.existsSync()) {
    stderr.writeln('Missing ${f.path}');
    exit(1);
  }

  final src = img.decodeImage(f.readAsBytesSync());
  if (src == null) {
    stderr.writeln('Could not decode icon');
    exit(1);
  }

  final work = src.width != _size || src.height != _size
      ? img.copyResize(
          src,
          width: _size,
          height: _size,
          interpolation: img.Interpolation.average,
        )
      : src;

  final out = img.Image(width: _size, height: _size, numChannels: 4);
  img.fill(out, color: img.ColorRgba8(_br, _bg, _bb, 255));

  final cx = (_size - 1) / 2.0;
  final cy = (_size - 1) / 2.0;
  final radius = _size / 2.0 - 20;
  final rOuter = radius + 3; // soft edge

  for (var y = 0; y < _size; y++) {
    for (var x = 0; x < _size; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final d = sqrt(dx * dx + dy * dy);

      if (d > rOuter + 1e-6) {
        continue;
      }

      final p = work.getPixel(x, y);
      final an = p.aNormalized.clamp(0.0, 1.0);

      if (d <= radius) {
        if (an >= 0.999) {
          out.setPixelRgba(x, y, p.r, p.g, p.b, 255);
        } else {
          out.setPixelRgba(
            x,
            y,
            _mix(_br, p.r, an).round().clamp(0, 255),
            _mix(_bg, p.g, an).round().clamp(0, 255),
            _mix(_bb, p.b, an).round().clamp(0, 255),
            255,
          );
        }
        continue;
      }

      final edgeT =
          ((rOuter - d) / (rOuter - radius + 1e-9)).clamp(0.0, 1.0);
      final rr = _mix(_br, p.r, an * edgeT).round().clamp(0, 255);
      final gg = _mix(_bg, p.g, an * edgeT).round().clamp(0, 255);
      final bb = _mix(_bb, p.b, an * edgeT).round().clamp(0, 255);
      out.setPixelRgba(x, y, rr, gg, bb, 255);
    }
  }

  f.writeAsBytesSync(img.encodePng(out, level: 6));
  stderr.writeln('Wrote circular composite to assets/images/app_icon.png');
}
