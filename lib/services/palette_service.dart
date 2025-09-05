// title=lib/services/palette_service.dart
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Lightweight "seeded" scheme. If [seed] is null, fall back to indigo.
class PaletteService {
  static ColorScheme schemeFromSeed(
      {Color? seed, Brightness brightness = Brightness.light}) {
    final base = seed ?? const Color(0xFF3F51B5); // Indigo
    final core = CorePalette.of(base.value);
    return brightness == Brightness.dark
        ? ColorScheme.fromSeed(seedColor: base, brightness: Brightness.dark)
        : ColorScheme.fromSeed(seedColor: base, brightness: Brightness.light);
  }
}
