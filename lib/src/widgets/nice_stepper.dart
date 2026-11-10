import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/nice_step.dart';
import '../model/nice_stepper_layout.dart';
import '../model/nice_stepper_strings.dart';
import '../theme/nice_stepper_theme.dart';
import 'nice_step_bar.dart';
import 'nice_step_strip.dart';

/// Where the reader is in a multi-step flow: which steps are done, which
/// is current, which are to come. Two forms, picked by [layout]: the
/// strip ([NiceStepStrip], dots and labels across the width) and the
/// compact bar ([NiceStepBar], one line over a progress track);
/// [NiceStepperLayout.auto] takes the bar below [compactBreakpoint], or
/// when the strip's dots would not fit.
///
/// The stepper has no buttons and holds no state: Previous and Next
/// belong to the host, which passes the [currentIndex] it is at. A
/// completed step is tappable when [onStepTapped] is given, and the host
/// decides whether to honour it.
///
/// ```dart
/// NiceStepper(
///   steps: const [
///     NiceStep(label: 'Account'),
///     NiceStep(label: 'Company'),
///     NiceStep(label: 'Review'),
///   ],
///   currentIndex: index,
///   onStepTapped: (i) => setState(() => index = i),
/// )
/// ```
///
/// Give it a bounded width (it fills it); its height is its own.
class NiceStepper extends StatelessWidget {
  /// Creates a stepper over [steps] with the one at [currentIndex]
  /// current.
  const NiceStepper({
    required this.steps,
    required this.currentIndex,
    this.onStepTapped,
    this.layout = NiceStepperLayout.auto,
    this.done = false,
    this.compactBreakpoint = defaultCompactBreakpoint,
    this.labelledCellWidth = NiceStepStrip.defaultLabelledCellWidth,
    this.theme,
    this.strings,
    super.key,
  });

  /// The flow's steps, in order; at least one.
  final List<NiceStep> steps;

  /// Index of the current step, clamped into [steps].
  final int currentIndex;

  /// Called with the index of a completed step the reader tapped.
  final ValueChanged<int>? onStepTapped;

  /// Which form to draw.
  final NiceStepperLayout layout;

  /// The flow finished: every step, the last one included, is drawn
  /// completed, and nothing is tappable.
  final bool done;

  /// Below this width [NiceStepperLayout.auto] shows the compact bar.
  final double compactBreakpoint;

  /// The strip's width per step below which only the current step keeps
  /// its label.
  final double labelledCellWidth;

  /// Overrides the theme for this stepper; see [NiceStepperTheme] for
  /// where it comes from otherwise.
  final NiceStepperTheme? theme;

  /// Overrides the strings for this stepper; the nearest
  /// [NiceStepperStringsScope], else English, otherwise.
  final NiceStepperStrings? strings;

  /// Default for [compactBreakpoint].
  static const double defaultCompactBreakpoint = 560;

  @override
  Widget build(BuildContext context) {
    assert(steps.isNotEmpty, 'a stepper has at least one step');
    final index = currentIndex.clamp(0, steps.length - 1);
    final t = theme ?? NiceStepperTheme.of(context);

    Widget stepper = LayoutBuilder(
      builder: (context, constraints) {
        final compact = switch (layout) {
          NiceStepperLayout.strip => false,
          NiceStepperLayout.compact => true,
          NiceStepperLayout.auto => constraints.maxWidth <
              math.max(
                compactBreakpoint,
                NiceStepStrip.minWidth(steps.length, t),
              ),
        };
        return compact
            ? NiceStepBar(
                steps: steps,
                currentIndex: index,
                onStepTapped: onStepTapped,
                done: done,
              )
            : NiceStepStrip(
                steps: steps,
                currentIndex: index,
                onStepTapped: onStepTapped,
                done: done,
                labelledCellWidth: labelledCellWidth,
              );
      },
    );
    // Explicit arguments reach the strip, the bar and the sheet as scopes.
    if (strings case final strings?) {
      stepper = NiceStepperStringsScope(strings: strings, child: stepper);
    }
    if (theme case final theme?) {
      stepper = NiceStepperThemeScope(theme: theme, child: stepper);
    }
    return stepper;
  }
}
