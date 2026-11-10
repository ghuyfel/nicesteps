import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nicesteps/nicesteps.dart';
import 'package:nicesteps_example/main.dart';

Future<void> loadRoboto() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      (await Process.run('where', ['flutter']))
          .stdout
          .toString()
          .split('\n')
          .first
          .trim()
          .replaceAll(RegExp(r'[\\/]bin[\\/]flutter(\.bat)?\s*$'), '');
  final dir = Directory('$flutterRoot/bin/cache/artifacts/material_fonts');
  final loader = FontLoader('Roboto');
  for (final name in [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf'
  ]) {
    final f = File('${dir.path}/$name');
    if (f.existsSync()) {
      final bytes = await f.readAsBytes();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
  }
  await loader.load();
  // Material icons.
  final icons = File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final il = FontLoader('MaterialIcons')
      ..addFont(
          Future.value(ByteData.view((await icons.readAsBytes()).buffer)));
    await il.load();
  }
}

Future<void> snap(WidgetTester tester, String name) async {
  // Real async engine work only completes inside runAsync.
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary).first);
    final image =
        await boundary.toImage(pixelRatio: tester.view.devicePixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final out = Platform.environment['SNAP_DIR'] ?? '.';
    File('$out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// Bounded alternative to pumpAndSettle (never hangs on repeating animations).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Shows the gallery, started afresh, in a [width] by [height] window at
/// twice the pixels, inside a boundary around the whole app so the bottom
/// sheet's route is in the picture too.
Future<void> open(
  WidgetTester tester,
  String name,
  double width,
  double height,
) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = Size(width * 2, height * 2);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RepaintBoundary(child: GalleryApp(key: ValueKey(name))),
  );
  await settle(tester);
}

/// Renders the gallery to the PNG files the README and the package's
/// pub.dev page show (`screenshots/` at the package root, listed in its
/// `pubspec.yaml`).
///
/// Opt in with `SNAP_DIR=<folder> flutter test test/screenshot_test.dart`
/// (and `FLUTTER_ROOT` so real fonts load); it is skipped otherwise. From
/// `example/`, `SNAP_DIR=../screenshots` rewrites the package's own.
void main() {
  final snapDir = Platform.environment['SNAP_DIR'];
  testWidgets('render the gallery', skip: snapDir == null, (tester) async {
    await tester.runAsync(loadRoboto);

    // The strip, as the gallery opens: icons, the second step current.
    await open(tester, 'desktop', 1100, 660);
    expect(find.byType(NiceStepStrip), findsOneWidget);
    await snap(tester, 'strip');

    // The same in dark mode, with numbers and one step further.
    await tester.tap(find.widgetWithText(FilterChip, 'Icons'));
    await tester.tap(find.text('Next'));
    await tester.tap(find.byTooltip('Toggle dark mode'));
    await settle(tester);
    await snap(tester, 'strip_dark');

    // The compact bar, at a phone's width.
    await open(tester, 'phone', 390, 700);
    expect(find.byType(NiceStepBar), findsOneWidget);
    await snap(tester, 'compact');

    // The list of steps it opens, with the brand theme in dark mode.
    await tester.tap(find.widgetWithText(FilterChip, 'Brand theme'));
    await tester.tap(find.byTooltip('Toggle dark mode'));
    await settle(tester);
    await tester.tap(find.byType(NiceStepBar));
    await settle(tester);
    expect(find.byType(NiceStepsSheet), findsOneWidget);
    await snap(tester, 'steps_sheet');
  });
}
