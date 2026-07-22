// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
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
      baseColor: Colors.grey[300] ?? const Color(0xFFE0E0E0),
      highlightColor: Colors.grey[100] ?? const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: double.infinity, height: 120, borderRadius: 16),
          const SizedBox(height: 24),
          const SkeletonLoader(width: 150, height: 20),
          const SizedBox(height: 12),
          const SkeletonLoader(width: double.infinity, height: 80, borderRadius: 12),
          const SizedBox(height: 24),
          const SkeletonLoader(width: 180, height: 20),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => Row(
                children: [
                  const SkeletonLoader(width: 48, height: 48, borderRadius: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(width: 120, height: 16),
                        SizedBox(height: 6),
                        SkeletonLoader(width: 80, height: 12),
                      ],
                    ),
                  ),
                  const SkeletonLoader(width: 60, height: 16),
                ],
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
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200] ?? const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const SkeletonLoader(width: 80, height: 60, borderRadius: 8),
                const SizedBox(width: 16),
                Expanded(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(width: 120, height: 18),
                      SizedBox(height: 6),
                      SkeletonLoader(width: 80, height: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonLoader(width: 100, height: 14),
                SkeletonLoader(width: 80, height: 14),
              ],
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
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200] ?? const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(width: 120, height: 18),
                SkeletonLoader(width: 80, height: 16),
              ],
            ),
            const SizedBox(height: 12),
            const SkeletonLoader(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            const SkeletonLoader(width: 160, height: 14),
          ],
        ),
      ),
    );
  }
}
