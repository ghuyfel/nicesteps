import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nicestepper/nicestepper.dart';

const _steps = [
  NiceStep(label: 'Société', icon: Icons.business_rounded),
  NiceStep(label: 'Client', icon: Icons.person_rounded),
  NiceStep(label: 'Options', icon: Icons.tune_rounded, optional: true),
];

final _french = NiceStepperStrings(
  steps: 'Étapes',
  optional: 'facultatif',
  stepNumber: (step) => 'Étape $step',
  stepCounter: (step, count) => 'Étape $step sur $count',
  stepOf: (step, count, label) => 'Étape $step sur $count, $label',
  goBackTo: (label) => 'Revenir à $label',
);

Widget app(Widget child, {double width = 760}) => MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );

void main() {
  test('the defaults are English', () {
    const strings = NiceStepperStrings();
    expect(strings.steps, 'Steps');
    expect(strings.optional, 'optional');
    expect(strings.stepNumber(2), 'Step 2');
    expect(strings.stepCounter(2, 5), 'Step 2 of 5');
    expect(strings.stepOf(2, 5, 'Client'), 'Step 2 of 5, Client');
    expect(strings.goBackTo('Company'), 'Go back to Company');
  });

  testWidgets('a scope translates the strip', (tester) async {
    await tester.pumpWidget(
      app(
        NiceStepperStringsScope(
          strings: _french,
          child: NiceStepper(
            steps: _steps,
            currentIndex: 1,
            onStepTapped: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ÉTAPE 2'), findsOneWidget);
    expect(find.textContaining('STEP'), findsNothing);
    expect(find.bySemanticsLabel('Revenir à Société'), findsOneWidget);
    expect(find.bySemanticsLabel('Étape 2 sur 3, Client'), findsOneWidget);
  });

  testWidgets('the argument wins over the scope', (tester) async {
    await tester.pumpWidget(
      app(
        NiceStepperStringsScope(
          strings: _french,
          child: NiceStepper(
            steps: _steps,
            currentIndex: 1,
            strings: NiceStepperStrings(stepNumber: (step) => 'Paso $step'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PASO 2'), findsOneWidget);
    expect(find.textContaining('ÉTAPE'), findsNothing);
  });

  testWidgets(
      'the bar and the list of steps it opens speak the stepper\'s language',
      (tester) async {
    await tester.pumpWidget(
      app(
        width: 375,
        NiceStepper(steps: _steps, currentIndex: 0, strings: _french),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ÉTAPE 1 SUR 3'), findsOneWidget);

    await tester.tap(find.byType(NiceStepBar));
    await tester.pumpAndSettle();
    expect(find.text('Étapes'), findsOneWidget);
    expect(find.text('facultatif'), findsOneWidget);
    expect(find.text('Steps'), findsNothing);
  });

  testWidgets('a scope above the navigator reaches the list of steps too',
      (tester) async {
    await tester.pumpWidget(
      NiceStepperStringsScope(
        strings: _french,
        child: app(
          width: 375,
          const NiceStepper(steps: _steps, currentIndex: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NiceStepBar));
    await tester.pumpAndSettle();
    expect(find.text('Étapes'), findsOneWidget);
  });
}
