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

/// Renders the gallery to PNG files for visual checks.
///
/// Opt in with `SNAP_DIR=<folder> flutter test test/screenshot_test.dart`
/// (and `FLUTTER_ROOT` so real fonts load); it is skipped otherwise.
void main() {
  final snapDir = Platform.environment['SNAP_DIR'];
  testWidgets('render the gallery', skip: snapDir == null, (tester) async {
    await tester.runAsync(loadRoboto);
    for (final (dpr, w, h, label) in [
      (1.0, 1100.0, 640.0, 'desktop'),
      (2.0, 390.0, 700.0, 'phone'),
    ]) {
      tester.view.devicePixelRatio = dpr;
      tester.view.physicalSize = Size(w * dpr, h * dpr);
      addTearDown(tester.view.reset);
      // A boundary around the whole app, so the bottom sheet's route is
      // in the picture too.
      await tester.pumpWidget(
        RepaintBoundary(child: GalleryApp(key: ValueKey(label))),
      );
      await settle(tester);
      await snap(tester, '${label}_light');

      // Numbers instead of icons, one step further.
      await tester.tap(find.widgetWithText(FilterChip, 'Icons'));
      await tester.tap(find.text('Next'));
      await settle(tester);
      await snap(tester, '${label}_numbers');

      // The brand theme, in dark mode.
      await tester.tap(find.widgetWithText(FilterChip, 'Icons'));
      await tester.tap(find.widgetWithText(FilterChip, 'Brand theme'));
      await tester.tap(find.byTooltip('Toggle dark mode'));
      await settle(tester);
      await snap(tester, '${label}_dark_brand');

      // The list of steps, where the compact bar is showing.
      if (find.byType(NiceStepBar).evaluate().isNotEmpty) {
        await tester.tap(find.byType(NiceStepBar));
        await settle(tester);
        await snap(tester, '${label}_sheet');
        await tester.tapAt(const Offset(10, 10));
        await settle(tester);
      }
    }
  });
}
