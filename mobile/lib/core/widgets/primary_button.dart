import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Luxury Apple-inspired automotive primary CTA button with emerald gradient.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 54,
    this.borderRadius = 16,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize = 15,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);
    final isEnabled = onPressed != null && !isLoading;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? (backgroundColor != null
                ? null
                : AppTheme.primaryGradient)
            : null,
        color: isEnabled
            ? backgroundColor
            : AppTheme.surface2,
        borderRadius: effectiveBorderRadius,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: (backgroundColor ?? AppTheme.primary)
                      .withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: effectiveBorderRadius,
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 19,
                          color: foregroundColor ?? Colors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: isEnabled
                              ? (foregroundColor ?? Colors.white)
                              : AppTheme.textMuted,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (!isFullWidth) return content;
    return SizedBox(width: double.infinity, child: content);
  }
}

/// Translucent Liquid Glass button with hairline border
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 50,
    this.borderRadius = 16,
    this.color,
    this.textColor,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);
    final isEnabled = onPressed != null && !isLoading;

    final content = Container(
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface1.withValues(alpha: 0.7),
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: AppTheme.border,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: effectiveBorderRadius,
          splashColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 18,
                          color: textColor ?? AppTheme.textPrimary,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor ?? AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (!isFullWidth) return content;
    return SizedBox(width: double.infinity, child: content);
  }
}
