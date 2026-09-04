import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Premium dark automotive frosted glass card.
/// Uses high-performance gradient translucency by default and optional selective backdrop blur.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 22,
    this.blur = 0,
    this.backgroundColor,
    this.borderColor,
    this.gradient,
    this.hasGlow = false,
    this.glowColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final bool hasGlow;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (gradient == null ? AppTheme.surface1 : null),
        gradient: backgroundColor == null ? (gradient ?? AppTheme.glassGradient) : null,
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: borderColor ?? AppTheme.border,
          width: 1.0,
        ),
        boxShadow: [
          ...AppTheme.subtleShadow,
          if (hasGlow)
            BoxShadow(
              color: (glowColor ?? AppTheme.primary).withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
        ],
      ),
      child: child,
    );

    if (blur > 0) {
      content = ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    if (onTap == null) {
      return Padding(padding: margin, child: content);
    }

    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          splashColor: AppTheme.primary.withValues(alpha: 0.12),
          highlightColor: AppTheme.primary.withValues(alpha: 0.05),
          child: content,
        ),
      ),
    );
  }
}

/// Frosted glass pill/badge container for automotive metrics & status
class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.color,
    this.borderColor,
    this.borderRadius = 999,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface2.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppTheme.border,
          width: 1.0,
        ),
      ),
      child: child,
    );
  }
}
