import 'package:flutter/material.dart';

import '../theme/nice_stepper_theme.dart';

/// The surface both forms of the stepper sit on: a rounded card with a
/// hairline edge, so the stepper reads as a panel of the page rather than
/// loose dots over the background.
class NiceStepperCard extends StatelessWidget {
  /// Creates the stepper's card around [child].
  const NiceStepperCard({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(10, 12, 10, 10),
    super.key,
  });

  /// What the card holds.
  final Widget child;

  /// Room between the card's edge and [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = NiceStepperTheme.of(context);
    final card = Material(
      color: t.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: t.borderRadius,
        side: t.showBorder ? BorderSide(color: t.border) : BorderSide.none,
      ),
      child: Padding(padding: padding, child: child),
    );
    final shadow = t.shadow;
    if (shadow == null || shadow.isEmpty) return card;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: t.borderRadius,
        boxShadow: shadow,
      ),
      child: card,
    );
  }
}
