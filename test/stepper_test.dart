import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nicestepper/nicestepper.dart';

const _steps = [
  NiceStep(label: 'Company'),
  NiceStep(label: 'Client'),
  NiceStep(label: 'Duress', optional: true),
  NiceStep(label: 'Details'),
  NiceStep(label: 'Status'),
];

Widget wrap(Widget child, {double? width, bool dark = false}) => MaterialApp(
      theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
      home: Scaffold(
        body: width == null
            ? child
            : Center(child: SizedBox(width: width, child: child)),
      ),
    );

Future<void> pump(
  WidgetTester tester, {
  required double width,
  int currentIndex = 1,
  ValueChanged<int>? onStepTapped,
  NiceStepperLayout layout = NiceStepperLayout.auto,
  List<NiceStep> steps = _steps,
}) async {
  await tester.pumpWidget(
    wrap(
      width: width,
      NiceStepper(
        steps: steps,
        currentIndex: currentIndex,
        onStepTapped: onStepTapped,
        layout: layout,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

NiceStepDot dotOf(WidgetTester tester, int number) =>
    tester.widget<NiceStepDot>(
      find.byWidgetPredicate((w) => w is NiceStepDot && w.number == number),
    );

void main() {
  test('a step is completed before the index, current at it, upcoming after',
      () {
    expect(NiceStepState.of(0, 2), NiceStepState.completed);
    expect(NiceStepState.of(2, 2), NiceStepState.current);
    expect(NiceStepState.of(3, 2), NiceStepState.upcoming);
    expect(NiceStepState.of(2, 2, done: true), NiceStepState.completed);
    expect(NiceStepState.of(4, 2, done: true), NiceStepState.completed);
  });

  testWidgets(
      'the strip draws completed, current and upcoming steps differently',
      (tester) async {
    await pump(tester, width: 760, currentIndex: 1);

    expect(find.byType(NiceStepStrip), findsOneWidget);
    expect(dotOf(tester, 1).state, NiceStepState.completed);
    expect(dotOf(tester, 2).state, NiceStepState.current);
    expect(dotOf(tester, 3).state, NiceStepState.upcoming);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget,
        reason: 'one completed step, one check');
    expect(find.text('2'), findsOneWidget,
        reason: 'the current step shows its number');
    expect(find.text('1'), findsNothing,
        reason: 'a completed step shows a check, not its number');
    // Every label fits at 142 px per cell.
    for (final step in _steps) {
      expect(find.text(step.label), findsOneWidget);
    }
    expect(find.textContaining('STEP'), findsNothing,
        reason: 'numbered dots carry no "STEP N" eyebrow');
  });

  testWidgets(
      'done draws every step completed, the last one included, and nothing '
      'is tappable', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(
      wrap(
        NiceStepper(
          steps: _steps,
          currentIndex: 4,
          onStepTapped: tapped.add,
          done: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(5));
    expect(dotOf(tester, 5).state, NiceStepState.completed);
    await tester.tap(find.text('Company'));
    expect(tapped, isEmpty);

    // Compact: the track is full.
    await tester.pumpWidget(
      wrap(
        width: 375,
        const NiceStepper(steps: _steps, currentIndex: 4, done: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      1,
    );
  });

  testWidgets(
      'a step with an icon shows it on the dot and the "STEP N" eyebrow '
      'under it', (tester) async {
    await tester.pumpWidget(
      wrap(
        const NiceStepper(
          steps: [
            NiceStep(label: 'Company', icon: Icons.business_rounded),
            NiceStep(label: 'Client', icon: Icons.person_rounded),
            NiceStep(label: 'Status', icon: Icons.flag_rounded),
          ],
          currentIndex: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget,
        reason: 'the completed step shows a check, not its icon');
    expect(find.byIcon(Icons.business_rounded), findsNothing);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
    expect(find.text('2'), findsNothing);
    for (final eyebrow in ['STEP 1', 'STEP 2', 'STEP 3']) {
      expect(find.text(eyebrow), findsOneWidget);
    }
  });

  testWidgets(
      'a completed step is a button that reports its index; an upcoming one '
      'is not', (tester) async {
    final tapped = <int>[];
    await pump(tester, width: 760, currentIndex: 2, onStepTapped: tapped.add);

    await tester.tap(find.text('Company'));
    expect(tapped, [0]);
    await tester.tap(find.text('Details'));
    expect(tapped, [0], reason: 'upcoming steps cannot be jumped to');

    final cells =
        tester.widgetList<NiceStepCell>(find.byType(NiceStepCell)).toList();
    expect(cells[0].onTap, isNotNull);
    expect(cells[2].onTap, isNull, reason: 'the current step is not a button');
    expect(cells[3].onTap, isNull);
  });

  testWidgets('without a tap handler nothing is a button', (tester) async {
    await pump(tester, width: 760, currentIndex: 2);
    for (final cell
        in tester.widgetList<NiceStepCell>(find.byType(NiceStepCell))) {
      expect(cell.onTap, isNull);
    }
  });

  testWidgets(
      'narrow cells drop every label but the current one, which the dots '
      'keep as tooltips', (tester) async {
    // 5 steps in 400 px: 70 px a cell, under the 120 px a label needs.
    await pump(tester,
        width: 400, currentIndex: 1, layout: NiceStepperLayout.strip);
    expect(find.text('Client'), findsOneWidget);
    expect(find.text('Company'), findsNothing);
    expect(find.text('Details'), findsNothing);
    expect(find.byTooltip('Company'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'the strip fits');
  });

  testWidgets('the strip never scrolls: it fills the width it is given',
      (tester) async {
    await pump(tester, width: 700, currentIndex: 0);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.getRect(find.byType(NiceStepStrip)).width, 700);
  });

  testWidgets(
      'auto takes the compact bar below 560 px, with the counter, the name '
      'and the progress', (tester) async {
    await pump(tester, width: 375, currentIndex: 1);
    expect(find.byType(NiceStepBar), findsOneWidget);
    expect(find.byType(NiceStepStrip), findsNothing);
    expect(find.text('STEP 2 OF 5'), findsOneWidget,
        reason: 'the eyebrow is upper-cased');
    expect(find.text('Client'), findsOneWidget);
    final progress = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(progress.value, closeTo(2 / 5, 0.001));
  });

  testWidgets('the breakpoint is the host\'s to move', (tester) async {
    await tester.pumpWidget(
      wrap(
        width: 600,
        const NiceStepper(
          steps: _steps,
          currentIndex: 1,
          compactBreakpoint: 640,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NiceStepBar), findsOneWidget);
  });

  testWidgets(
      'auto takes the bar when the dots of a long flow would not fit the '
      'strip', (tester) async {
    final steps = [for (var i = 1; i <= 12; i++) NiceStep(label: 'Step $i')];
    // Twelve dots need 720 px; 600 is past the breakpoint but short of it.
    await pump(tester, width: 600, steps: steps);
    expect(find.byType(NiceStepBar), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pump(tester, width: 720, steps: steps);
    expect(find.byType(NiceStepStrip), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'nothing overflows');
  });

  testWidgets(
      'the bar opens the list of steps, where a completed one goes back',
      (tester) async {
    final tapped = <int>[];
    await pump(tester, width: 375, currentIndex: 2, onStepTapped: tapped.add);

    await tester.tap(find.byType(NiceStepBar));
    await tester.pumpAndSettle();
    expect(find.byType(NiceStepsSheet), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('optional'), findsNothing,
        reason: 'the optional step is the current one, no longer to come');

    await tester.tap(find.text('Company'));
    await tester.pumpAndSettle();
    expect(tapped, [0]);
    expect(find.byType(NiceStepsSheet), findsNothing,
        reason: 'the sheet closes on the choice');
  });

  testWidgets('the list tags a step still to come that may be skipped',
      (tester) async {
    await pump(tester, width: 375, currentIndex: 0);
    await tester.tap(find.byType(NiceStepBar));
    await tester.pumpAndSettle();
    expect(find.text('optional'), findsOneWidget);
  });

  testWidgets('the strip is announced as one step of many', (tester) async {
    await pump(tester, width: 760, currentIndex: 1);
    final strip = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byType(NiceStepStrip),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(strip.properties.label, 'Step 2 of 5, Client');
    expect(strip.container, isTrue);
  });

  testWidgets(
      'each step is its own node, named once: a completed one is a way '
      'back, and the strip around them is not a button', (tester) async {
    final handle = tester.ensureSemantics();
    // A single completed step: merged into the strip's node, it would
    // make the whole strip one button.
    await pump(tester, width: 760, currentIndex: 1, onStepTapped: (_) {});

    expect(
      tester.getSemantics(find.bySemanticsLabel('Go back to Company')),
      isSemantics(isButton: true, hasTapAction: true),
    );
    expect(find.bySemanticsLabel('Client'), findsOneWidget);
    expect(find.bySemanticsLabel('Details'), findsOneWidget);
    expect(find.bySemanticsLabel('Go back to Details'), findsNothing);
    for (final label in ['Step 2 of 5, Client', 'Client', 'Details']) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(label)),
        isNot(isSemantics(hasTapAction: true)),
        reason: '"$label" is not a button',
      );
    }
    handle.dispose();
  });

  testWidgets('the bar is one button, announced as one step of many',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, width: 375, currentIndex: 1);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Step 2 of 5, Client')),
      isSemantics(isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('the index is clamped into the list', (tester) async {
    await pump(tester, width: 760, currentIndex: 42);
    expect(dotOf(tester, 5).state, NiceStepState.current);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nothing animates when the platform asks for no animations',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(800, 600),
          disableAnimations: true,
        ),
        child: wrap(const NiceStepper(steps: _steps, currentIndex: 1)),
      ),
    );
    await tester.pump();
    for (final box in tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))) {
      expect(box.duration, Duration.zero);
    }
  });

  testWidgets('both forms render in dark mode at every width', (tester) async {
    for (final width in [280.0, 375.0, 559.0, 560.0, 760.0, 1200.0]) {
      await tester.pumpWidget(
        wrap(
          width: width,
          dark: true,
          const NiceStepper(steps: _steps, currentIndex: 3),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'at $width px');
    }
  });
}
