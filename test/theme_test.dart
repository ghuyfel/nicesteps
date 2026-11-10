import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nicesteps/nicesteps.dart';

const _steps = [
  NiceStep(label: 'Company'),
  NiceStep(label: 'Client'),
  NiceStep(label: 'Status'),
];

const _violet = Color(0xFF7C3AED);
const _teal = Color(0xFF0D9488);

NiceStepperTheme _derived([Brightness brightness = Brightness.light]) =>
    NiceStepperTheme.fromColorScheme(
      ColorScheme.fromSeed(seedColor: Colors.blue, brightness: brightness),
    );

/// The fill of the disc inside the dot of step [number].
Color? discColor(WidgetTester tester, int number) {
  final dot =
      find.byWidgetPredicate((w) => w is NiceStepDot && w.number == number);
  final disc = tester.widget<AnimatedContainer>(
    find.descendant(of: dot, matching: find.byType(AnimatedContainer)).last,
  );
  return (disc.decoration! as BoxDecoration).color;
}

void main() {
  test('the derived theme follows the colour scheme and flips with it', () {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);
    final light = NiceStepperTheme.fromColorScheme(scheme);
    expect(light.accent, scheme.primary);
    expect(light.onAccent, scheme.onPrimary);
    expect(light.surface, scheme.surface);
    expect(light.foreground, scheme.onSurface);
    expect(light.dotExtent, 30 + 2 * (3 + 1.2));

    final dark = _derived(Brightness.dark);
    expect(dark.completed, isNot(light.completed));
    expect(dark.onCompleted, isNot(light.onCompleted));
  });

  test('copyWith replaces the given slots and keeps the rest', () {
    final base = _derived();
    final copy = base.copyWith(accent: _violet, dotSize: 36, showBorder: false);
    expect(copy.accent, _violet);
    expect(copy.dotSize, 36);
    expect(copy.showBorder, isFalse);
    expect(copy.completed, base.completed);
    expect(copy.labelTextStyle, base.labelTextStyle);
    expect(copy.animationDuration, base.animationDuration);
  });

  test('lerp meets both ends and blends between them', () {
    final a = _derived().copyWith(accent: _violet, dotSize: 30);
    final b = _derived(Brightness.dark).copyWith(accent: _teal, dotSize: 40);
    expect(a.lerp(b, 0).accent, _violet);
    expect(a.lerp(b, 1).accent, _teal);
    expect(a.lerp(b, 0.5).dotSize, 35);
    expect(a.lerp(null, 0.5), same(a));
  });

  testWidgets('an extension on the app theme reaches the stepper',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [_derived().copyWith(accent: _violet)]),
        home: const Scaffold(
          body: NiceStepper(steps: _steps, currentIndex: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(discColor(tester, 2), _violet);
  });

  testWidgets('a scope wins over the extension, and the argument over both',
      (tester) async {
    final extension = _derived().copyWith(accent: _violet);
    final scoped = _derived().copyWith(accent: _teal);
    final explicit = _derived().copyWith(accent: Colors.black);

    Widget app({NiceStepperTheme? theme}) => MaterialApp(
          theme: ThemeData(extensions: [extension]),
          home: Scaffold(
            body: NiceStepperThemeScope(
              theme: scoped,
              child: NiceStepper(steps: _steps, currentIndex: 1, theme: theme),
            ),
          ),
        );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(discColor(tester, 2), _teal);

    await tester.pumpWidget(app(theme: explicit));
    await tester.pumpAndSettle();
    expect(discColor(tester, 2), Colors.black);
  });

  testWidgets('the card takes its surface, edge and radius from the theme',
      (tester) async {
    final theme = _derived().copyWith(
      surface: _teal,
      border: _violet,
      borderRadius: BorderRadius.circular(20),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NiceStepper(steps: _steps, currentIndex: 0, theme: theme),
        ),
      ),
    );
    final card = tester.widget<Material>(
      find.descendant(
        of: find.byType(NiceStepperCard),
        matching: find.byType(Material),
      ),
    );
    expect(card.color, _teal);
    final shape = card.shape! as RoundedRectangleBorder;
    expect(shape.side.color, _violet);
    expect(shape.borderRadius, BorderRadius.circular(20));
  });

  testWidgets('the list of steps keeps the theme of the stepper that opened it',
      (tester) async {
    final theme = _derived().copyWith(accent: _violet);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 375,
              child: NiceStepper(steps: _steps, currentIndex: 1, theme: theme),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NiceStepBar));
    await tester.pumpAndSettle();

    final sheet = find.byType(NiceStepsSheet);
    expect(sheet, findsOneWidget);
    final current = find.descendant(
      of: sheet,
      matching:
          find.byWidgetPredicate((w) => w is NiceStepDot && w.number == 2),
    );
    final disc = tester.widget<AnimatedContainer>(
      find
          .descendant(of: current, matching: find.byType(AnimatedContainer))
          .last,
    );
    expect((disc.decoration! as BoxDecoration).color, _violet);
  });
}
