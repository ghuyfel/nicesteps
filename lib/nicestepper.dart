/// Theme-aware steppers for multi-step flows in Flutter.
///
/// Start with [NiceStepper]: hand it your [NiceStep]s and the index the
/// flow is at, and it draws the strip of dots and labels on wide layouts
/// and the compact progress bar on narrow ones. It holds no state and has
/// no buttons; Previous and Next are yours. All looks live in
/// [NiceStepperTheme], derived from your app theme by default; all text
/// the stepper draws itself lives in [NiceStepperStrings], English by
/// default.
///
/// The parts are exported too ([NiceStepStrip], [NiceStepBar],
/// [NiceStepsSheet], [NiceStepCell], [NiceStepDot], [NiceStepConnector],
/// [NiceStepperCard]) for layouts the stepper does not cover.
library;

export 'src/model/nice_step.dart';
export 'src/model/nice_step_state.dart';
export 'src/model/nice_stepper_layout.dart';
export 'src/model/nice_stepper_strings.dart';
export 'src/theme/nice_stepper_theme.dart';
export 'src/widgets/nice_step_bar.dart';
export 'src/widgets/nice_step_cell.dart';
export 'src/widgets/nice_step_connector.dart';
export 'src/widgets/nice_step_dot.dart';
export 'src/widgets/nice_step_strip.dart';
export 'src/widgets/nice_stepper.dart';
export 'src/widgets/nice_stepper_card.dart';
export 'src/widgets/nice_steps_sheet.dart';
