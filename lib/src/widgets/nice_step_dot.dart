import 'package:flutter/material.dart';

import '../model/nice_step_state.dart';
import '../theme/nice_stepper_theme.dart';

/// One step's circle, in its three looks: completed is a solid disc in
/// the theme's `completed` colour with a check; current is a solid disc
/// in the `accent` with the step's [icon] (or its number) and a thin ring
/// a few pixels out; upcoming is a surface disc with a hairline edge and
/// the glyph in the muted colour. The ring's room is always reserved
/// (`NiceStepperTheme.dotExtent`), so a row of dots never shifts when a
/// step becomes current. Transitions take the theme's
/// `animationDuration`, none when the platform asks for no animations.
class NiceStepDot extends StatelessWidget {
  /// Creates the dot of step [number] in [state].
  const NiceStepDot({
    required this.number,
    required this.state,
    this.icon,
    super.key,
  });

  /// One-based; what the circle shows while the step is not completed and
  /// has no [icon].
  final int number;

  /// Which of the three looks to draw.
  final NiceStepState state;

  /// Shown in place of [number] while the step is not completed.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = NiceStepperTheme.of(context);
    final animate = !MediaQuery.disableAnimationsOf(context);
    final d = animate ? t.animationDuration : Duration.zero;

    final (Color fill, Color edge, Color fg) = switch (state) {
      NiceStepState.completed => (t.completed, t.completed, t.onCompleted),
      NiceStepState.current => (t.accent, t.accent, t.onAccent),
      NiceStepState.upcoming => (
          t.upcomingFill,
          t.upcomingBorder,
          t.upcomingForeground,
        ),
    };
    final ring = state == NiceStepState.current;

    final Widget glyph;
    if (state == NiceStepState.completed) {
      glyph = Icon(Icons.check_rounded, size: t.dotSize * 16 / 30, color: fg);
    } else if (icon case final icon?) {
      glyph = Icon(icon, size: t.dotSize / 2, color: fg);
    } else {
      glyph = Text('$number', style: t.numberTextStyle.copyWith(color: fg));
    }

    return AnimatedContainer(
      duration: d,
      width: t.dotExtent,
      height: t.dotExtent,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ring ? t.accent : t.accent.withValues(alpha: 0),
          width: t.ringWidth,
        ),
      ),
      child: AnimatedContainer(
        duration: d,
        width: t.dotSize,
        height: t.dotSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: Border.all(color: edge, width: t.ringWidth),
        ),
        child: glyph,
      ),
    );
  }
}
