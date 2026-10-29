// Skeleton shimmer loading states per `docs/DESIGN.md` §Motion touchpoint 6:
// "Skeleton shimmer placeholders matching the real content's shape (card
// outlines, text-line bars) while data loads." Used by the Transaksi,
// Analytics, Goals, and Aset list screens' `loading:` branches.
//
// Given Isar's sub-50ms query time this will rarely be visible in practice
// (per the spec) — no artificial minimum display duration is added here,
// it simply renders for however many frames the provider is actually
// loading.
//
// The shimmer sweep is intentionally BOUNDED (a finite `repeat(count: ...)`)
// rather than an infinite loop: an infinite `AnimationController` left
// ticking while a widget test's `pumpAndSettle()` happens to catch the
// loading frame would never "settle" and hang the test. A bounded sweep
// still reads as a shimmer effect in the (rare, real-world) case it's
// visible, while staying test-safe.
import 'package:flutter/material.dart';

import '../../motion/motion_durations.dart';
import '../../theme/app_colors.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      if (!isReducedMotion(context)) {
        _controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1000),
        )..repeat(count: 8);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final highlight = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    Widget buildBox(double shift) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(-1 + shift, 0),
            end: Alignment(1 + shift, 0),
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return buildBox(0);
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => buildBox(-2 + controller.value * 4),
    );
  }
}

/// A card-shaped shimmer block: a few text-line bars inside a bordered
/// container, matching the general `.card` shape used across the app.
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(width: 120, height: 16),
              ShimmerBox(width: 48, height: 16),
            ],
          ),
          const SizedBox(height: 14),
          const ShimmerBox(width: double.infinity, height: 10),
          for (var i = 1; i < lines; i++) ...[
            const SizedBox(height: 10),
            ShimmerBox(width: i.isOdd ? 180 : 140, height: 10),
          ],
        ],
      ),
    );
  }
}

/// Transaksi list loading placeholder: date-group header + a few rows.
class TransactionsSkeletonList extends StatelessWidget {
  const TransactionsSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('transactions_loading_indicator'),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(width: 140, height: 12),
              for (var i = 0; i < 3; i++) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const ShimmerBox(width: 36, height: 36, borderRadius: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(width: 90, height: 12),
                          SizedBox(height: 6),
                          ShimmerBox(width: 60, height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const ShimmerBox(width: 64, height: 14),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Goals list loading placeholder: overview card + a couple of goal cards.
class GoalsSkeletonList extends StatelessWidget {
  const GoalsSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('goals_loading_indicator'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      children: const [
        _SkeletonCard(lines: 2),
        _SkeletonCard(lines: 4),
        _SkeletonCard(lines: 4),
      ],
    );
  }
}

/// Aset list loading placeholder: portfolio overview card + asset cards.
class AssetsSkeletonList extends StatelessWidget {
  const AssetsSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('assets_loading_indicator'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: const [
        _SkeletonCard(lines: 3),
        _SkeletonCard(lines: 4),
        _SkeletonCard(lines: 4),
      ],
    );
  }
}

/// Analytics loading placeholder: ratio card + chart-shaped block.
class AnalyticsSkeletonList extends StatelessWidget {
  const AnalyticsSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('analytics_loading_indicator'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        const _SkeletonCard(lines: 3),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor),
          ),
          child: const Column(
            children: [
              ShimmerBox(width: double.infinity, height: 140, borderRadius: 70),
              SizedBox(height: 16),
              ShimmerBox(width: 160, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
