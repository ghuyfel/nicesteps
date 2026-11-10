import 'package:flutter/widgets.dart';

/// One step of a flow as the stepper names it: its label, the glyph its
/// dot shows, and whether it may be skipped.
@immutable
class NiceStep {
  /// Creates a step.
  const NiceStep({required this.label, this.icon, this.optional = false});

  /// Short, already translated: it sits under a 30 px dot.
  final String label;

  /// What the dot shows while the step is not completed (a completed one
  /// shows a check). Without one the dot shows the step's number, and the
  /// "STEP 2" eyebrow under it is left out, since the number says it.
  final IconData? icon;

  /// Marked "optional" in the list of steps the compact bar opens, for as
  /// long as the step is still to come; the host decides what skipping
  /// means.
  final bool optional;
}
