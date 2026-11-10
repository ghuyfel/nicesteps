import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nicesteps/nicesteps.dart';

void main() => runApp(const GalleryApp());

/// Gallery for nicesteps: one sign-up flow driven by Previous and Next,
/// with switches for the stepper's form, its dots, its width and its theme.
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF06102A); // navy, matching the nicetables gallery
    return MaterialApp(
      title: 'nicesteps gallery',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          primary: const Color(0xFF60A5FA),
          surface: const Color(0xFF0B1220),
        ),
        scaffoldBackgroundColor: const Color(0xFF060B16),
      ),
      home: GalleryPage(
        mode: _mode,
        onToggleMode: () => setState(
          () => _mode =
              _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Demo flow
// ---------------------------------------------------------------------------

const _flow = <({String label, IconData icon, bool optional, String blurb})>[
  (
    label: 'Account',
    icon: Icons.person_outline_rounded,
    optional: false,
    blurb: 'Who is signing up, and how to reach them.',
  ),
  (
    label: 'Company',
    icon: Icons.business_rounded,
    optional: false,
    blurb: 'The legal entity the workspace belongs to.',
  ),
  (
    label: 'Security',
    icon: Icons.shield_outlined,
    optional: true,
    blurb: 'Two-factor sign-in and a recovery contact. Can be set up later.',
  ),
  (
    label: 'Billing',
    icon: Icons.credit_card_rounded,
    optional: false,
    blurb: 'The plan, and the card it is charged to.',
  ),
  (
    label: 'Review',
    icon: Icons.fact_check_outlined,
    optional: false,
    blurb: 'Everything entered so far, before it is submitted.',
  ),
];

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class GalleryPage extends StatefulWidget {
  const GalleryPage({
    super.key,
    required this.mode,
    required this.onToggleMode,
  });

  final ThemeMode mode;
  final VoidCallback onToggleMode;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  int _index = 1;
  bool _done = false;
  NiceStepperLayout _layout = NiceStepperLayout.auto;
  bool _icons = true;
  bool _brand = false;
  double _width = 960;

  bool get _last => _index == _flow.length - 1;

  void _next() => setState(() {
        if (_done) {
          _done = false;
          _index = 0;
        } else if (_last) {
          _done = true;
        } else {
          _index++;
        }
      });

  void _previous() => setState(() {
        if (_done) {
          _done = false;
        } else if (_index > 0) {
          _index--;
        }
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = [
      for (final s in _flow)
        NiceStep(
          label: s.label,
          icon: _icons ? s.icon : null,
          optional: s.optional,
        ),
    ];
    // Per-stepper theming: start from the ambient theme, change a few slots.
    final brand = NiceStepperTheme.of(context).copyWith(
      accent: const Color(0xFF7C3AED),
      onAccent: Colors.white,
      borderRadius: BorderRadius.circular(20),
      dotSize: 34,
      trackThickness: 6,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wraps onto several lines on narrow windows.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    'nicesteps',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SegmentedButton<NiceStepperLayout>(
                        segments: const [
                          ButtonSegment(
                            value: NiceStepperLayout.auto,
                            label: Text('Auto'),
                          ),
                          ButtonSegment(
                            value: NiceStepperLayout.strip,
                            label: Text('Strip'),
                          ),
                          ButtonSegment(
                            value: NiceStepperLayout.compact,
                            label: Text('Compact'),
                          ),
                        ],
                        selected: {_layout},
                        showSelectedIcon: false,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                        onSelectionChanged: (s) =>
                            setState(() => _layout = s.first),
                      ),
                      FilterChip(
                        label: const Text('Icons'),
                        selected: _icons,
                        onSelected: (v) => setState(() => _icons = v),
                      ),
                      FilterChip(
                        label: const Text('Brand theme'),
                        selected: _brand,
                        onSelected: (v) => setState(() => _brand = v),
                      ),
                      IconButton(
                        tooltip: 'Toggle dark mode',
                        onPressed: widget.onToggleMode,
                        icon: Icon(
                          widget.mode == ThemeMode.light
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Width', style: theme.textTheme.labelMedium),
                  Expanded(
                    child: Slider(
                      value: _width,
                      min: 280,
                      max: 1200,
                      onChanged: (v) => setState(() => _width = v),
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: Text(
                      '${_width.round()} px',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) => Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: math.min(_width, constraints.maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NiceStepper(
                          steps: steps,
                          currentIndex: _index,
                          done: _done,
                          layout: _layout,
                          theme: _brand ? brand : null,
                          onStepTapped: (i) => setState(() => _index = i),
                        ),
                        const SizedBox(height: 24),
                        _StepBody(index: _index, done: _done),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            if (_index > 0 || _done)
                              TextButton.icon(
                                onPressed: _previous,
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18,
                                ),
                                label: const Text('Previous'),
                              ),
                            const Spacer(),
                            FilledButton(
                              onPressed: _next,
                              child: Text(
                                _done
                                    ? 'Start over'
                                    : _last
                                        ? 'Submit'
                                        : 'Next',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A stand-in for the current step's form.
class _StepBody extends StatelessWidget {
  const _StepBody({required this.index, required this.done});

  final int index;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final step = _flow[index];
    return Material(
      color: scheme.brightness == Brightness.dark
          ? scheme.surfaceContainerLow
          : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              done ? 'All done' : step.label,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              done
                  ? 'The flow finished: every step is drawn completed, the '
                      'last one included, and none can be tapped.'
                  : step.blurb,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            // Placeholder fields.
            for (final widthFactor in const [1.0, 1.0, 0.6])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
