import 'package:flutter/material.dart';

import '../model/nice_step.dart';
import '../model/nice_step_state.dart';
import '../model/nice_stepper_strings.dart';
import '../theme/nice_stepper_theme.dart';
import 'nice_step_dot.dart';

/// The list of a flow's steps as a bottom sheet, opened from the compact
/// `NiceStepBar`: one row per step with its dot and label, the current
/// one in bold, "optional" after a step still to come that may be
/// skipped. A completed row is tappable when [onStepTapped] is given: the
/// sheet closes and the host goes back to it.
class NiceStepsSheet extends StatelessWidget {
  /// Creates the list of [steps]; open it with [show].
  const NiceStepsSheet({
    required this.steps,
    required this.currentIndex,
    this.onStepTapped,
    this.done = false,
    this.theme,
    this.strings,
    super.key,
  });

  /// The flow's steps, in order.
  final List<NiceStep> steps;

  /// Index of the current step, clamped into [steps].
  final int currentIndex;

  /// Called with the index of a completed step the reader tapped, after
  /// the sheet has closed.
  final ValueChanged<int>? onStepTapped;

  /// Every step completed, the last one included.
  final bool done;

  /// Overrides the theme the sheet would resolve from its own context.
  final NiceStepperTheme? theme;

  /// Overrides the strings the sheet would resolve from its own context.
  final NiceStepperStrings? strings;

  /// Opens the sheet over [context]'s navigator.
  ///
  /// A sheet is built under the navigator, outside any
  /// [NiceStepperThemeScope] or [NiceStepperStringsScope] around the
  /// stepper that opened it, so the ones in scope at [context] are handed
  /// to it here unless [theme] and [strings] say otherwise.
  static Future<void> show(
    BuildContext context, {
    required List<NiceStep> steps,
    required int currentIndex,
    ValueChanged<int>? onStepTapped,
    bool done = false,
    NiceStepperTheme? theme,
    NiceStepperStrings? strings,
  }) {
    final scopedTheme = theme ?? NiceStepperThemeScope.maybeOf(context);
    final scopedStrings = strings ?? NiceStepperStringsScope.maybeOf(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => NiceStepsSheet(
        steps: steps,
        currentIndex: currentIndex,
        onStepTapped: onStepTapped,
        done: done,
        theme: scopedTheme,
        strings: scopedStrings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = theme ?? NiceStepperTheme.of(context);
    final s = strings ?? NiceStepperStrings.of(context);
    final textTheme = Theme.of(context).textTheme;
    final index = currentIndex.clamp(0, steps.length - 1);
    // The dots read their theme from the context.
    return NiceStepperThemeScope(
      theme: t,
      child: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                s.steps,
                style: textTheme.titleMedium?.copyWith(
                  color: t.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (var i = 0; i < steps.length; i++)
              ListTile(
                leading: NiceStepDot(
                  number: i + 1,
                  state: NiceStepState.of(i, index, done: done),
                  icon: steps[i].icon,
                ),
                title: Text(
                  steps[i].label,
                  style: t.titleTextStyle.copyWith(
                    fontWeight: i == index ? FontWeight.w700 : FontWeight.w500,
                    color: i > index ? t.mutedForeground : t.foreground,
                  ),
                ),
                trailing: steps[i].optional && i > index
                    ? Text(
                        s.optional,
                        style: textTheme.labelSmall
                            ?.copyWith(color: t.mutedForeground),
                      )
                    : null,
                enabled: (onStepTapped != null && i < index) || i == index,
                onTap: onStepTapped != null && i < index
                    ? () {
                        Navigator.of(context).pop();
                        onStepTapped!(i);
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
