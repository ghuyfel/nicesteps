/// Which form the stepper takes.
enum NiceStepperLayout {
  /// The horizontal strip of dots and labels, whatever the width.
  strip,

  /// The compact one-line bar over a progress track, whatever the width.
  compact,

  /// Whichever the width allows (the default): the bar below
  /// `NiceStepper.compactBreakpoint`, or when the strip's dots would not
  /// fit, the strip otherwise.
  auto,
}
