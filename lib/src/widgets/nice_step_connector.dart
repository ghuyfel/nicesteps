import 'package:flutter/material.dart';

import '../model/nice_step_state.dart';
import '../theme/nice_stepper_theme.dart';

/// The line from a step's dot to the next step, with rounded ends: lit in
/// the theme's `completed` colour in full after a completed step, in the
/// `accent` for `connectorProgress` of its length after the current one
/// (the step is under way), and left as bare track after an upcoming one.
/// The colours and the lit length animate with the dots.
///
/// It takes the width it is given, so inside a [Row] it goes in an
/// [Expanded]; that is how the strip fills whatever width it has and
/// never scrolls.
class NiceStepConnector extends StatelessWidget {
  /// Creates the line that leaves a step in [state].
  const NiceStepConnector({required this.state, super.key});

  /// The state of the step the line leaves.
  final NiceStepState state;

  @override
  Widget build(BuildContext context) {
    final t = NiceStepperTheme.of(context);
    final animate = !MediaQuery.disableAnimationsOf(context);
    final d = animate ? t.animationDuration : Duration.zero;
    final (Color color, double fraction) = switch (state) {
      NiceStepState.completed => (t.completed, 1.0),
      NiceStepState.current => (t.accent, t.connectorProgress),
      NiceStepState.upcoming => (t.track, 0.0),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(t.trackThickness / 2),
        child: SizedBox(
          height: t.trackThickness,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: t.track)),
              AnimatedFractionallySizedBox(
                duration: d,
                alignment: AlignmentDirectional.centerStart,
                widthFactor: fraction,
                heightFactor: 1,
                child: AnimatedContainer(duration: d, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
