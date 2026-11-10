import 'package:flutter/widgets.dart';

/// Every piece of text a stepper draws or announces on its own: the
/// "STEP 2 OF 5" counter, the "STEP 2" eyebrow, the title of the list of
/// steps, the "optional" tag and the screen-reader labels. English by
/// default; the step labels themselves are yours (`NiceStep.label`).
///
/// Hand a stepper one through `NiceStepper.strings`, or put a
/// [NiceStepperStringsScope] above every stepper (above your
/// `MaterialApp`'s pages, for instance) to translate them all at once:
///
/// ```dart
/// NiceStepperStringsScope(
///   strings: NiceStepperStrings(
///     steps: 'Étapes',
///     optional: 'facultatif',
///     stepCounter: (step, count) => 'Étape $step sur $count',
///   ),
///   child: child,
/// )
/// ```
///
/// Numbers are passed to the function-typed fields as numbers (one-based),
/// so a translation can place them where its grammar wants.
@immutable
class NiceStepperStrings {
  /// Creates a set of strings; every field defaults to its English text.
  const NiceStepperStrings({
    this.steps = 'Steps',
    this.optional = 'optional',
    this.stepNumber = defaultStepNumber,
    this.stepCounter = defaultStepCounter,
    this.stepOf = defaultStepOf,
    this.goBackTo = defaultGoBackTo,
  });

  /// Title of the list of steps the compact bar opens.
  final String steps;

  /// Tag after a step that may be skipped, in the list of steps.
  final String optional;

  /// The eyebrow under a dot that shows an icon, e.g. "Step 2"; drawn in
  /// upper case.
  final String Function(int step) stepNumber;

  /// The compact bar's counter, e.g. "Step 2 of 5"; drawn in upper case.
  final String Function(int step, int count) stepCounter;

  /// How a screen reader announces the stepper, e.g. "Step 2 of 5,
  /// Company".
  final String Function(int step, int count, String label) stepOf;

  /// How a screen reader announces a completed step that can be tapped,
  /// e.g. "Go back to Company".
  final String Function(String label) goBackTo;

  /// The strings of the nearest [NiceStepperStringsScope], else the
  /// English defaults.
  static NiceStepperStrings of(BuildContext context) =>
      NiceStepperStringsScope.maybeOf(context) ?? const NiceStepperStrings();

  /// Default for [stepNumber].
  static String defaultStepNumber(int step) => 'Step $step';

  /// Default for [stepCounter].
  static String defaultStepCounter(int step, int count) =>
      'Step $step of $count';

  /// Default for [stepOf].
  static String defaultStepOf(int step, int count, String label) =>
      'Step $step of $count, $label';

  /// Default for [goBackTo].
  static String defaultGoBackTo(String label) => 'Go back to $label';
}

/// Provides [NiceStepperStrings] to every stepper in [child]. A stepper's
/// own `strings` argument wins over the scope.
class NiceStepperStringsScope extends InheritedWidget {
  /// Creates a strings scope.
  const NiceStepperStringsScope({
    required this.strings,
    required super.child,
    super.key,
  });

  /// The strings to use.
  final NiceStepperStrings strings;

  /// The nearest scoped strings, if any.
  static NiceStepperStrings? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<NiceStepperStringsScope>()
      ?.strings;

  @override
  bool updateShouldNotify(NiceStepperStringsScope oldWidget) =>
      oldWidget.strings != strings;
}
