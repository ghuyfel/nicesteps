## 1.0.0

First stable release.

- `NiceStepper`: where the reader is in a multi-step flow, from a list of
  `NiceStep`s (label, optional icon, optional flag) and the index the flow
  is at. Stateless and without buttons: Previous and Next are the host's.
  A completed step is tappable when `onStepTapped` is given; `done` draws
  every step completed, the last one included, with nothing tappable.
- Two forms, picked by `layout`: the strip (`NiceStepStrip`), one cell per
  step with its dot, a connector to the next and its label, which fills
  the width it is given and never scrolls; and the compact bar
  (`NiceStepBar`), a "STEP 2 OF 5" counter, the current step's name and a
  progress track, which opens the list of steps (`NiceStepsSheet`) as a
  bottom sheet. `NiceStepperLayout.auto` takes the bar below
  `compactBreakpoint` (560 px), or when the dots of a long flow would not
  fit the strip.
- Dots in three looks (completed, current, upcoming) with a check, the
  step's icon or its number; connectors lit in full after a completed
  step and in part after the current one. Narrow cells drop every label
  but the current one and keep the others as tooltips.
- `NiceStepperTheme` derived from the app `ColorScheme` and `TextTheme`,
  dark-mode aware, registrable as a `ThemeExtension`, scoped with
  `NiceStepperThemeScope` or passed to one stepper: colours, text styles,
  the card's radius, edge and shadow, dot and track sizes, the animation
  duration.
- `NiceStepperStrings`: the counter, the eyebrow, the list's title, the
  "optional" tag and the screen-reader labels in one object, English by
  default, scoped with `NiceStepperStringsScope` or passed to one stepper.
  The list of steps keeps the theme and the strings of the stepper that
  opened it.
- Accessible: the strip is announced as "Step 2 of 5, Company" with one
  node per step, a completed step as the button "Go back to Company", the
  bar as a single button. Transitions are instant when the platform asks
  for no animations.
- The parts are exported for layouts the stepper does not cover:
  `NiceStepCell`, `NiceStepDot`, `NiceStepConnector`, `NiceStepperCard`.
