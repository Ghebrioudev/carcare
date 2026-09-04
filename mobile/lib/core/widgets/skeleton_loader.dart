import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF141416),
      highlightColor: const Color(0xFF222228),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF141416),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerSkeleton(width: double.infinity, height: 180, borderRadius: 24),
          const SizedBox(height: 20),
          const ShimmerSkeleton(width: 140, height: 20, borderRadius: 6),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: ShimmerSkeleton(width: double.infinity, height: 80, borderRadius: 18)),
              SizedBox(width: 12),
              Expanded(child: ShimmerSkeleton(width: double.infinity, height: 80, borderRadius: 18)),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerSkeleton(width: 170, height: 20, borderRadius: 6),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface1,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 1),
                ),
                child: const Row(
                  children: [
                    ShimmerSkeleton(width: 44, height: 44, borderRadius: 14),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerSkeleton(width: 130, height: 16, borderRadius: 6),
                          SizedBox(height: 6),
                          ShimmerSkeleton(width: 90, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                    ShimmerSkeleton(width: 60, height: 16, borderRadius: 6),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class VehiclesSkeleton extends StatelessWidget {
  const VehiclesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface1,
          border: Border.all(color: AppTheme.border, width: 1),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          children: [
            ShimmerSkeleton(width: 72, height: 72, borderRadius: 16),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(width: 140, height: 18, borderRadius: 6),
                  SizedBox(height: 8),
                  ShimmerSkeleton(width: 90, height: 13, borderRadius: 4),
                  SizedBox(height: 8),
                  ShimmerSkeleton(width: 120, height: 12, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaintenanceSkeleton extends StatelessWidget {
  const MaintenanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface1,
          border: Border.all(color: AppTheme.border, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            ShimmerSkeleton(width: 44, height: 44, borderRadius: 14),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(width: 110, height: 16, borderRadius: 6),
                  SizedBox(height: 6),
                  ShimmerSkeleton(width: 150, height: 12, borderRadius: 4),
                ],
              ),
            ),
            ShimmerSkeleton(width: 64, height: 16, borderRadius: 6),
          ],
        ),
      ),
    );
  }
}
