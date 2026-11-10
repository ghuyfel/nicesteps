# nicestepper

Theme-aware steppers for multi-step flows in Flutter, with gorgeous
defaults.

A wizard needs one thing from its stepper: to show which steps are done,
which is current and which are to come, at any width. `NiceStepper` does
that from a list of steps and an index, and leaves the rest of the wizard
to you: it holds no state and has no buttons.

```dart
import 'package:nicestepper/nicestepper.dart';

NiceStepper(
  steps: const [
    NiceStep(label: 'Account', icon: Icons.person_outline_rounded),
    NiceStep(label: 'Company', icon: Icons.business_rounded),
    NiceStep(label: 'Security', icon: Icons.shield_outlined, optional: true),
    NiceStep(label: 'Review', icon: Icons.fact_check_outlined),
  ],
  currentIndex: index,
  onStepTapped: (i) => setState(() => index = i),
)
```

That gives you a strip of dots and labels joined by progress lines on a
card that fills its width, and, below 560 px, a one-line bar with a
"STEP 2 OF 4" counter and a progress track that opens the list of steps
in a bottom sheet. Dark mode and brand colours come from
`Theme.of(context)` with no setup.

## Features

- **Pure Flutter.** No native code and no dependencies beyond the SDK.
  Web, desktop and mobile.
- **Stateless.** You pass `currentIndex`; Previous, Next and validation
  stay in your wizard, with whatever state management you use.
- **Two forms.** The strip (`NiceStepStrip`) for wide layouts and the
  compact bar (`NiceStepBar`) for narrow ones. `NiceStepperLayout.auto`
  picks by width, and also takes the bar when the dots of a long flow
  would not fit the strip; `strip` and `compact` force one.
- **Three states at a glance.** Completed steps are a green disc with a
  check and a full line after them; the current one is an accent disc
  with a ring and a line lit part of the way; upcoming ones are muted.
- **Icons or numbers.** A step shows its `icon`, or its number without
  one. Steps with icons get a small "STEP 2" eyebrow over the label.
- **Never scrolls, never overflows.** The strip shares its width between
  the steps. When cells get narrow, only the current step keeps its
  label; the others keep their dot, with the label as a tooltip.
- **Go back.** With `onStepTapped`, completed steps are buttons (in the
  strip and in the bar's list). Upcoming steps never are. Whether a tap
  actually goes back is your call.
- **Done.** `done: true` draws every step completed, the last one
  included, and makes nothing tappable: for the success screen after a
  submission.
- **Theme.** `NiceStepperTheme` derives from your `ColorScheme` and
  `TextTheme`, flips with dark mode, and is a `ThemeExtension`, so you can
  register one app-wide, scope one with `NiceStepperThemeScope` or pass
  one to a single stepper.
- **Localisable.** The few words the stepper writes itself live in
  `NiceStepperStrings`, English by default.
- **Accessible.** The strip is announced as "Step 2 of 4, Company" with
  one node per step; a completed step as the button "Go back to Account";
  the bar as a single button. Transitions are instant when the platform
  asks for no animations.

## Installation

```bash
flutter pub add nicestepper
```

Requires Flutter 3.27 or newer. No other dependencies.

## Usage

### A wizard

The stepper goes on top; the step's body and the buttons are yours.

```dart
class SignUpWizard extends StatefulWidget {
  const SignUpWizard({super.key});

  @override
  State<SignUpWizard> createState() => _SignUpWizardState();
}

class _SignUpWizardState extends State<SignUpWizard> {
  static const _steps = [
    NiceStep(label: 'Account'),
    NiceStep(label: 'Company'),
    NiceStep(label: 'Review'),
  ];

  int _index = 0;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final last = _index == _steps.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NiceStepper(
          steps: _steps,
          currentIndex: _index,
          done: _done,
          onStepTapped: (i) => setState(() => _index = i),
        ),
        const SizedBox(height: 24),
        Expanded(child: _bodyFor(_index)),
        Row(
          children: [
            if (_index > 0 && !_done)
              TextButton(
                onPressed: () => setState(() => _index--),
                child: const Text('Previous'),
              ),
            const Spacer(),
            if (!_done)
              FilledButton(
                onPressed: () => setState(() {
                  if (last) {
                    _done = true;
                  } else {
                    _index++;
                  }
                }),
                child: Text(last ? 'Submit' : 'Next'),
              ),
          ],
        ),
      ],
    );
  }
}
```

`currentIndex` is clamped into the list, so an index one past the end
does not throw. Give the stepper a bounded width (it fills it); its
height is its own.

### Steps

```dart
const NiceStep(label: 'Company')                         // numbered dot
const NiceStep(label: 'Company', icon: Icons.business)   // icon, "STEP 2" eyebrow
const NiceStep(label: 'Security', optional: true)        // tagged "optional" in the list
```

Labels are short and already translated: they sit under a 30 px dot and
wrap onto two lines at most.

### Layout

```dart
NiceStepper(layout: NiceStepperLayout.auto)     // the default
NiceStepper(layout: NiceStepperLayout.strip)    // always dots and labels
NiceStepper(layout: NiceStepperLayout.compact)  // always the one-line bar

NiceStepper(compactBreakpoint: 720)   // auto takes the bar below 720 px
NiceStepper(labelledCellWidth: 96)    // labels stay down to 96 px per step
```

The width that counts is the stepper's own, not the screen's, so a
stepper in a narrow dialog or side panel takes the bar on a wide screen.
A forced `strip` needs about 60 px per step for its dots
(`NiceStepStrip.minWidth` gives the exact figure); `auto` checks that for
you.

### Theming

```dart
// App-wide, via ThemeExtension:
ThemeData(
  extensions: [
    NiceStepperTheme.fromColorScheme(scheme).copyWith(
      accent: scheme.secondary,
      onAccent: scheme.onSecondary,
      completed: brandGreen,
      borderRadius: BorderRadius.circular(8),
    ),
  ],
)

// Per subtree:
NiceStepperThemeScope(theme: myStepperTheme, child: ...)

// Per stepper:
NiceStepper(theme: NiceStepperTheme.of(context).copyWith(showBorder: false))
```

Everything is a slot: the card's surface, edge, radius and shadow; the
accent of the current step and the green of completed ones, each with its
foreground; the track; the upcoming dot's fill, edge and glyph; the label,
eyebrow, counter, title and number text styles; the dot size, ring gap and
width, track thickness, how far the current step's line is lit, and the
animation duration. The text styles carry no colour of their own, so
changing `accent` recolours the counter too.

By default the current step takes `colorScheme.primary`. The completed
green is fixed (Material has no success role), a darker one on light
surfaces and a lighter one on dark.

### Localisation

Your step labels are yours. The words the stepper adds live in
`NiceStepperStrings`: the "Step 2 of 5" counter, the "Step 2" eyebrow, the
"Steps" title and "optional" tag of the list, and the screen-reader
labels.

```dart
// App-wide, above your pages:
NiceStepperStringsScope(
  strings: NiceStepperStrings(
    steps: 'Étapes',
    optional: 'facultatif',
    stepNumber: (step) => 'Étape $step',
    stepCounter: (step, count) => 'Étape $step sur $count',
    stepOf: (step, count, label) => 'Étape $step sur $count, $label',
    goBackTo: (label) => 'Revenir à $label',
  ),
  child: child,
)

// Per stepper (wins over the scope):
NiceStepper(strings: myStrings, ...)
```

Numbers reach the function-typed fields as numbers (one-based), so a
translation can place them where its grammar wants. The counter and the
eyebrow are drawn in upper case.

### The parts

The pieces are exported for layouts the stepper does not cover:
`NiceStepStrip` and `NiceStepBar` (the two forms), `NiceStepsSheet` (the
list, `NiceStepsSheet.show(context, ...)`), `NiceStepCell`, `NiceStepDot`,
`NiceStepConnector` and `NiceStepperCard`. `NiceStepState.of(index,
currentIndex, done: done)` gives a step's state.

```dart
// A vertical list of your own, with the package's dots:
for (final (i, step) in steps.indexed)
  ListTile(
    leading: NiceStepDot(
      number: i + 1,
      state: NiceStepState.of(i, currentIndex),
      icon: step.icon,
    ),
    title: Text(step.label),
  )
```

## Example

The `example/` app is a gallery: a five-step sign-up flow driven by
Previous and Next, with switches for the layout, icons or numbers, a
brand theme and dark mode, and a slider for the stepper's width. Run it
with `cd example && flutter run -d chrome`.

## License

MIT
