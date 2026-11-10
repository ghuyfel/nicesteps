import 'package:flutter/material.dart';

import '../model/nice_step.dart';
import '../model/nice_stepper_strings.dart';
import '../theme/nice_stepper_theme.dart';
import 'nice_stepper_card.dart';
import 'nice_steps_sheet.dart';

/// The compact stepper for phones and narrow windows, on the same card as
/// the strip: a small accent eyebrow "STEP 2 OF 5", the current step's
/// name in bold with a chevron, and a thin progress track, so the step's
/// body keeps the height a column of dots would take. Tapping the card
/// opens [NiceStepsSheet] with the whole list, where a completed step can
/// be tapped to go back.
class NiceStepBar extends StatelessWidget {
  /// Creates the bar of [steps] with the one at [currentIndex] current.
  const NiceStepBar({
    required this.steps,
    required this.currentIndex,
    this.onStepTapped,
    this.done = false,
    super.key,
  });

  /// The flow's steps, in order.
  final List<NiceStep> steps;

  /// Index of the current step, clamped into [steps].
  final int currentIndex;

  /// Called with the index of a completed step the reader tapped in the
  /// list of steps.
  final ValueChanged<int>? onStepTapped;

  /// Every step completed: the track is full, and nothing in the list is
  /// tappable.
  final bool done;

  @override
  Widget build(BuildContext context) {
    final t = NiceStepperTheme.of(context);
    final s = NiceStepperStrings.of(context);
    final index = currentIndex.clamp(0, steps.length - 1);
    final current = steps[index];
    final animate = !MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      button: true,
      label: s.stepOf(index + 1, steps.length, current.label),
      child: NiceStepperCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => NiceStepsSheet.show(
            context,
            steps: steps,
            currentIndex: index,
            onStepTapped: done ? null : onStepTapped,
            done: done,
          ),
          // The label above says all of it; the counter, the name and
          // the progress under it would be read out again after it.
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    s.stepCounter(index + 1, steps.length).toUpperCase(),
                    style: t.counterTextStyle.copyWith(color: t.accent),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          current.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleTextStyle.copyWith(color: t.foreground),
                        ),
                      ),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 20,
                        color: t.mutedForeground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(t.trackThickness),
                    child: SizedBox(
                      height: t.trackThickness,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: done ? 1 : (index + 1) / steps.length,
                        ),
                        duration: animate ? t.animationDuration : Duration.zero,
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          minHeight: t.trackThickness,
                          backgroundColor: t.track,
                          color: t.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
