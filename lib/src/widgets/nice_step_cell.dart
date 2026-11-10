import 'package:flutter/material.dart';

import '../model/nice_step.dart';
import '../model/nice_step_state.dart';
import '../model/nice_stepper_strings.dart';
import '../theme/nice_stepper_theme.dart';
import 'nice_step_connector.dart';
import 'nice_step_dot.dart';

/// One cell of the strip, left-aligned: the dot with the connector
/// running from it to the next cell (none after the last), then under the
/// dot a small "STEP 2" eyebrow (only when the dot shows an icon; a
/// numbered dot already says it) and the label in bold (muted when
/// upcoming). The dot's look is the step's state; nothing else repeats
/// it. With [showLabel] false (narrow cells) only the dot and the
/// connector remain, and the dot carries the label as a tooltip. With
/// [onTap] the whole cell is a button, announced as "Go back to Company".
class NiceStepCell extends StatelessWidget {
  /// Creates the cell of [step], the [number]th of the strip.
  const NiceStepCell({
    required this.step,
    required this.number,
    required this.state,
    required this.last,
    this.showLabel = true,
    this.onTap,
    super.key,
  });

  /// The step this cell draws.
  final NiceStep step;

  /// One-based position of [step] in the flow.
  final int number;

  /// Whether [step] is completed, current or upcoming.
  final NiceStepState state;

  /// Whether this is the strip's last cell, which has no connector.
  final bool last;

  /// Whether the eyebrow and the label are drawn under the dot.
  final bool showLabel;

  /// Makes the whole cell a button.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = NiceStepperTheme.of(context);
    final s = NiceStepperStrings.of(context);
    final upcoming = state == NiceStepState.upcoming;

    Widget dot = NiceStepDot(number: number, state: state, icon: step.icon);
    if (!showLabel) {
      dot = Tooltip(message: step.label, child: dot);
    }

    Widget cell = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            dot,
            if (!last)
              Expanded(child: NiceStepConnector(state: state))
            else
              const Spacer(),
          ],
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Padding(
            // In line with the disc, not with the ring around it.
            padding: EdgeInsetsDirectional.only(start: t.ringGap + t.ringWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step.icon != null) ...[
                  Text(
                    s.stepNumber(number).toUpperCase(),
                    style: t.eyebrowTextStyle.copyWith(
                      color:
                          upcoming ? t.upcomingForeground : t.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 1),
                ],
                Text(
                  step.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelTextStyle.copyWith(
                    color: upcoming ? t.upcomingForeground : t.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    // One node per step, named once: the eyebrow, the label and the
    // tooltip under it would otherwise be read out again after it.
    cell = ExcludeSemantics(child: cell);
    if (onTap == null) {
      return Semantics(container: true, label: step.label, child: cell);
    }
    // The whole cell, dot and text, is the button.
    return Semantics(
      container: true,
      button: true,
      label: s.goBackTo(step.label),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: t.accent.withValues(alpha: 0.05),
        child: cell,
      ),
    );
  }
}
