import 'package:flutter/material.dart';

/// Widget shimmer loading — efek cahaya berjalan di atas placeholder
class ShimmerLoading extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    Key? key,
    this.width,
    this.height = 80,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 2, 0),
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.6),
                Colors.white.withOpacity(0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder shimmer untuk kartu summary
class SummaryCardShimmer extends StatelessWidget {
  const SummaryCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: ShimmerLoading(height: 180, borderRadius: 24),
    );
  }
}

/// Placeholder shimmer untuk list item transaksi
class TransactionListShimmer extends StatelessWidget {
  final int count;
  const TransactionListShimmer({Key? key, this.count = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: ShimmerLoading(height: 72, borderRadius: 16),
        ),
      ),
    );
  }
}
