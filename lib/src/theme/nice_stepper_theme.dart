import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Every colour, text style and size a `NiceStepper` uses.
///
/// Steppers resolve their theme in this order: an explicit `theme`
/// argument, the nearest [NiceStepperThemeScope], a `NiceStepperTheme`
/// registered as a [ThemeExtension] on the app theme, and finally
/// [NiceStepperTheme.fromColorScheme], which derives everything from
/// `Theme.of(context)` so dark mode and brand colours work with zero
/// configuration.
///
/// The text styles carry no colour of their own: each is painted in the
/// colour slot its documentation names, so `copyWith(accent: brand)`
/// recolours everything the accent touches.
class NiceStepperTheme extends ThemeExtension<NiceStepperTheme> {
  /// Creates a theme. Prefer [NiceStepperTheme.fromTheme] or
  /// [NiceStepperTheme.fromColorScheme] and `copyWith` the slots you need.
  const NiceStepperTheme({
    required this.surface,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.completed,
    required this.onCompleted,
    required this.track,
    required this.upcomingFill,
    required this.upcomingBorder,
    required this.upcomingForeground,
    required this.foreground,
    required this.mutedForeground,
    required this.labelTextStyle,
    required this.eyebrowTextStyle,
    required this.counterTextStyle,
    required this.titleTextStyle,
    required this.numberTextStyle,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.showBorder = true,
    this.shadow,
    this.dotSize = 30,
    this.ringGap = 3,
    this.ringWidth = 1.2,
    this.trackThickness = 4,
    this.connectorProgress = 0.45,
    this.animationDuration = const Duration(milliseconds: 250),
  });

  /// Derives a theme from a [ColorScheme] and [TextTheme].
  ///
  /// This is the single place the defaults live; [fromTheme] delegates
  /// here. The current step takes `scheme.primary`; the completed green is
  /// fixed, since Material's colour scheme has no success role.
  factory NiceStepperTheme.fromColorScheme(
    ColorScheme scheme, {
    TextTheme? textTheme,
  }) {
    final dark = scheme.brightness == Brightness.dark;
    final on = scheme.onSurface;
    final surface = dark ? scheme.surfaceContainerLow : scheme.surface;
    final small = textTheme?.labelSmall ?? const TextStyle(fontSize: 11);
    return NiceStepperTheme(
      surface: surface,
      border: on.withValues(alpha: dark ? 0.12 : 0.10),
      accent: scheme.primary,
      onAccent: scheme.onPrimary,
      completed: dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
      onCompleted: dark ? const Color(0xFF052E16) : Colors.white,
      track: on.withValues(alpha: dark ? 0.14 : 0.10),
      upcomingFill: surface,
      upcomingBorder: on.withValues(alpha: dark ? 0.28 : 0.22),
      upcomingForeground: on.withValues(alpha: dark ? 0.50 : 0.44),
      foreground: on,
      mutedForeground: on.withValues(alpha: dark ? 0.64 : 0.58),
      labelTextStyle:
          (textTheme?.bodySmall ?? const TextStyle(fontSize: 12)).copyWith(
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      eyebrowTextStyle: small.copyWith(
        fontSize: 8,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
      counterTextStyle: small.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
      titleTextStyle: (textTheme?.bodyMedium ?? const TextStyle(fontSize: 14))
          .copyWith(fontWeight: FontWeight.w700),
      numberTextStyle:
          (textTheme?.labelMedium ?? const TextStyle(fontSize: 12)).copyWith(
        fontWeight: FontWeight.w700,
        height: 1,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  /// Derives a theme from a full [ThemeData], honouring a registered
  /// `NiceStepperTheme` extension when present.
  factory NiceStepperTheme.fromTheme(ThemeData theme) =>
      theme.extension<NiceStepperTheme>() ??
      NiceStepperTheme.fromColorScheme(
        theme.colorScheme,
        textTheme: theme.textTheme,
      );

  /// The theme for [context]: the nearest [NiceStepperThemeScope], else
  /// one derived from the ambient [Theme].
  static NiceStepperTheme of(BuildContext context) =>
      NiceStepperThemeScope.maybeOf(context) ??
      NiceStepperTheme.fromTheme(Theme.of(context));

  /// Background of the card both forms of the stepper sit on.
  final Color surface;

  /// Hairline edge of the card, when [showBorder] is on.
  final Color border;

  /// The current step: its dot and ring, the lit part of the line after
  /// it, the compact bar's counter and progress.
  final Color accent;

  /// Glyph on the current step's dot.
  final Color onAccent;

  /// A completed step: its dot and the line after it.
  final Color completed;

  /// The check on a completed step's dot.
  final Color onCompleted;

  /// The unlit part of a connector and of the compact bar's progress.
  final Color track;

  /// Fill of an upcoming step's dot.
  final Color upcomingFill;

  /// Edge of an upcoming step's dot.
  final Color upcomingBorder;

  /// An upcoming step's glyph, label and eyebrow.
  final Color upcomingForeground;

  /// Strong foreground: the labels of completed and current steps.
  final Color foreground;

  /// Muted foreground: the eyebrow of completed and current steps, the
  /// compact bar's chevron, the "optional" tag and the steps still to
  /// come in the list.
  final Color mutedForeground;

  /// A step's label under its dot, in [foreground] or
  /// [upcomingForeground].
  final TextStyle labelTextStyle;

  /// The "STEP 2" eyebrow over a label, in [mutedForeground] or
  /// [upcomingForeground].
  final TextStyle eyebrowTextStyle;

  /// The compact bar's "STEP 2 OF 5" counter, in [accent].
  final TextStyle counterTextStyle;

  /// The current step's name in the compact bar and the rows of the list
  /// of steps, in [foreground] or [mutedForeground].
  final TextStyle titleTextStyle;

  /// The number in a dot, in the dot's foreground.
  final TextStyle numberTextStyle;

  /// Corner radius of the card.
  final BorderRadius borderRadius;

  /// Whether to draw the card's edge.
  final bool showBorder;

  /// Optional shadow under the card.
  final List<BoxShadow>? shadow;

  /// Diameter of a dot's disc.
  final double dotSize;

  /// Gap between the current dot's disc and the ring around it.
  final double ringGap;

  /// Stroke of the ring around the current dot and of a dot's own edge.
  final double ringWidth;

  /// Thickness of the connectors and of the compact bar's progress.
  final double trackThickness;

  /// How much of the line after the current step is lit, from 0 to 1: the
  /// step is under way.
  final double connectorProgress;

  /// Duration of the dots', connectors' and progress' transitions; they
  /// are instant when the platform asks for no animations.
  final Duration animationDuration;

  /// The room a dot takes with its ring, which is always reserved so the
  /// row never shifts when a step becomes current.
  double get dotExtent => dotSize + 2 * (ringGap + ringWidth);

  @override
  NiceStepperTheme copyWith({
    Color? surface,
    Color? border,
    Color? accent,
    Color? onAccent,
    Color? completed,
    Color? onCompleted,
    Color? track,
    Color? upcomingFill,
    Color? upcomingBorder,
    Color? upcomingForeground,
    Color? foreground,
    Color? mutedForeground,
    TextStyle? labelTextStyle,
    TextStyle? eyebrowTextStyle,
    TextStyle? counterTextStyle,
    TextStyle? titleTextStyle,
    TextStyle? numberTextStyle,
    BorderRadius? borderRadius,
    bool? showBorder,
    List<BoxShadow>? shadow,
    double? dotSize,
    double? ringGap,
    double? ringWidth,
    double? trackThickness,
    double? connectorProgress,
    Duration? animationDuration,
  }) =>
      NiceStepperTheme(
        surface: surface ?? this.surface,
        border: border ?? this.border,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        completed: completed ?? this.completed,
        onCompleted: onCompleted ?? this.onCompleted,
        track: track ?? this.track,
        upcomingFill: upcomingFill ?? this.upcomingFill,
        upcomingBorder: upcomingBorder ?? this.upcomingBorder,
        upcomingForeground: upcomingForeground ?? this.upcomingForeground,
        foreground: foreground ?? this.foreground,
        mutedForeground: mutedForeground ?? this.mutedForeground,
        labelTextStyle: labelTextStyle ?? this.labelTextStyle,
        eyebrowTextStyle: eyebrowTextStyle ?? this.eyebrowTextStyle,
        counterTextStyle: counterTextStyle ?? this.counterTextStyle,
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
        numberTextStyle: numberTextStyle ?? this.numberTextStyle,
        borderRadius: borderRadius ?? this.borderRadius,
        showBorder: showBorder ?? this.showBorder,
        shadow: shadow ?? this.shadow,
        dotSize: dotSize ?? this.dotSize,
        ringGap: ringGap ?? this.ringGap,
        ringWidth: ringWidth ?? this.ringWidth,
        trackThickness: trackThickness ?? this.trackThickness,
        connectorProgress: connectorProgress ?? this.connectorProgress,
        animationDuration: animationDuration ?? this.animationDuration,
      );

  @override
  NiceStepperTheme lerp(ThemeExtension<NiceStepperTheme>? other, double t) {
    if (other is! NiceStepperTheme) return this;
    return NiceStepperTheme(
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      completed: Color.lerp(completed, other.completed, t)!,
      onCompleted: Color.lerp(onCompleted, other.onCompleted, t)!,
      track: Color.lerp(track, other.track, t)!,
      upcomingFill: Color.lerp(upcomingFill, other.upcomingFill, t)!,
      upcomingBorder: Color.lerp(upcomingBorder, other.upcomingBorder, t)!,
      upcomingForeground:
          Color.lerp(upcomingForeground, other.upcomingForeground, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      labelTextStyle: TextStyle.lerp(labelTextStyle, other.labelTextStyle, t)!,
      eyebrowTextStyle:
          TextStyle.lerp(eyebrowTextStyle, other.eyebrowTextStyle, t)!,
      counterTextStyle:
          TextStyle.lerp(counterTextStyle, other.counterTextStyle, t)!,
      titleTextStyle: TextStyle.lerp(titleTextStyle, other.titleTextStyle, t)!,
      numberTextStyle:
          TextStyle.lerp(numberTextStyle, other.numberTextStyle, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      showBorder: t < 0.5 ? showBorder : other.showBorder,
      shadow: t < 0.5 ? shadow : other.shadow,
      dotSize: lerpDouble(dotSize, other.dotSize, t)!,
      ringGap: lerpDouble(ringGap, other.ringGap, t)!,
      ringWidth: lerpDouble(ringWidth, other.ringWidth, t)!,
      trackThickness: lerpDouble(trackThickness, other.trackThickness, t)!,
      connectorProgress:
          lerpDouble(connectorProgress, other.connectorProgress, t)!,
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
    );
  }
}

/// Overrides the [NiceStepperTheme] for every stepper in [child].
class NiceStepperThemeScope extends InheritedWidget {
  /// Creates a theme scope.
  const NiceStepperThemeScope({
    required this.theme,
    required super.child,
    super.key,
  });

  /// The theme to apply.
  final NiceStepperTheme theme;

  /// The nearest scoped theme, if any.
  static NiceStepperTheme? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<NiceStepperThemeScope>()
      ?.theme;

  @override
  bool updateShouldNotify(NiceStepperThemeScope oldWidget) =>
      oldWidget.theme != theme;
}
