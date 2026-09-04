import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Premium dark automotive card with subtle hairline border and Liquid Glass lighting.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.margin = EdgeInsets.zero,
    this.borderRadius = 22,
    this.hasShadow = true,
    this.borderColor,
    this.gradient,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final bool hasShadow;
  final Color? borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = BorderRadius.circular(borderRadius);

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? (gradient == null ? AppTheme.surface1 : null),
        gradient: color == null ? (gradient ?? AppTheme.darkCardGradient) : null,
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: borderColor ?? AppTheme.border,
          width: 1.0,
        ),
        boxShadow: hasShadow ? AppTheme.subtleShadow : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: effectiveBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        splashColor: AppTheme.primary.withValues(alpha: 0.12),
        highlightColor: AppTheme.primary.withValues(alpha: 0.04),
        child: card,
      ),
    );
  }
}

/// Metric statistic card with dark automotive styling
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = AppTheme.primary,
    this.iconBackgroundColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (iconBackgroundColor ?? iconColor).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (iconBackgroundColor ?? iconColor).withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header for screen sections with title and optional text CTA button
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (actionLabel != null && onAction != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryLight,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppTheme.primaryLight,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tinted circular container with icon
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppTheme.primary,
    this.size = 50,
    this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: (backgroundColor ?? color).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.35),
        border: Border.all(
          color: (backgroundColor ?? color).withValues(alpha: 0.22),
          width: 1.0,
        ),
      ),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}

/// Pill status chip with optional icon and custom semantic color
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isOutlined = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.12),
        border: Border.all(
          color: isOutlined ? color : color.withValues(alpha: 0.25),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Automotive reminder card with urgency bar and status details
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.title,
    required this.vehicleName,
    required this.reminderType,
    this.date,
    this.mileage,
    this.isOverdue = false,
    this.onTap,
  });

  final String title;
  final String vehicleName;
  final String reminderType;
  final DateTime? date;
  final int? mileage;
  final bool isOverdue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? AppTheme.danger : AppTheme.warning;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$vehicleName · $reminderType',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}
