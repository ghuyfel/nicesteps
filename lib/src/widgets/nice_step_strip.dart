import 'package:flutter/material.dart';

import '../model/nice_step.dart';
import '../model/nice_step_state.dart';
import '../model/nice_stepper_strings.dart';
import '../theme/nice_stepper_theme.dart';
import 'nice_step_cell.dart';
import 'nice_stepper_card.dart';

/// The horizontal stepper: a [NiceStepperCard] holding one left-aligned
/// cell per step (dot, connector to the next, eyebrow, label), so the
/// strip fills the width it is given and never scrolls. Below
/// [labelledCellWidth] per cell only the current step keeps its text; the
/// others keep their dot and get a tooltip. A completed step is a button
/// that calls [onStepTapped]; upcoming steps are not. Announced to a
/// screen reader as "Step 2 of 5, Company".
///
/// It needs a bounded width, and at least [minWidth] of it for the dots
/// to fit; `NiceStepper` takes the compact bar below that on its own.
class NiceStepStrip extends StatelessWidget {
  /// Creates the strip of [steps] with the one at [currentIndex] current.
  const NiceStepStrip({
    required this.steps,
    required this.currentIndex,
    this.onStepTapped,
    this.done = false,
    this.labelledCellWidth = defaultLabelledCellWidth,
    super.key,
  });

  /// The flow's steps, in order.
  final List<NiceStep> steps;

  /// Index of the current step, clamped into [steps].
  final int currentIndex;

  /// Called with the index of a completed step the reader tapped.
  final ValueChanged<int>? onStepTapped;

  /// Every step completed, the last one included: the flow finished, and
  /// nothing is tappable.
  final bool done;

  /// The width per step below which only the current step keeps its
  /// label.
  final double labelledCellWidth;

  /// Default for [labelledCellWidth].
  static const double defaultLabelledCellWidth = 120;

  /// Room between the card's edge and the cells.
  static const EdgeInsets padding = EdgeInsets.fromLTRB(24, 24, 24, 22);

  /// The narrowest a strip of [stepCount] steps can be before its dots
  /// overflow, under [theme].
  static double minWidth(int stepCount, NiceStepperTheme theme) =>
      // The last cell has two shares of the width to the others' three,
      // and holds a whole dot.
      padding.horizontal + theme.dotExtent * (3 * stepCount - 1) / 2;

  @override
  Widget build(BuildContext context) {
    final s = NiceStepperStrings.of(context);
    final index = currentIndex.clamp(0, steps.length - 1);
    return Semantics(
      label: s.stepOf(index + 1, steps.length, steps[index].label),
      container: true,
      // Each step stays its own node under the strip's; merged into it,
      // one tappable step would make the whole strip a button.
      explicitChildNodes: true,
      child: NiceStepperCard(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / steps.length;
            final labelled = cellWidth >= labelledCellWidth;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < steps.length; i++)
                  Expanded(
                    // The last cell needs no room for a connector.
                    flex: i == steps.length - 1 ? 2 : 3,
                    child: NiceStepCell(
                      step: steps[i],
                      number: i + 1,
                      state: NiceStepState.of(i, index, done: done),
                      last: i == steps.length - 1,
                      showLabel: labelled || i == index,
                      onTap: onStepTapped == null || done || i >= index
                          ? null
                          : () => onStepTapped!(i),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
