import 'package:flutter/material.dart';

/// Data-stability tenet (design_system.md, "Typography" tenet #3): every
/// metric, counter, stopwatch, and tracking number renders with mono tabular
/// numerals so columns and deltas never shift layout mid-training.
TextStyle monoNumerals(TextStyle base) {
  return base.copyWith(
    fontFamily: 'monospace',
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
