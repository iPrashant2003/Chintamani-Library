import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/glass_theme.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({super.key, this.width = double.infinity, required this.height, this.shapeBorder = const RoundedRectangleBorder()});
  const ShimmerWidget.circular({super.key, required this.width, required this.height, this.shapeBorder = const CircleBorder()});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class LoadingSkeleton extends StatelessWidget {
  final int count;
  const LoadingSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: count,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: GlassTheme.cardDecoration(opacity: 0.05),
          child: Row(
            children: [
              const ShimmerWidget.circular(width: 50, height: 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget.rectangular(height: 16, width: MediaQuery.of(context).size.width * 0.5, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    ShimmerWidget.rectangular(height: 12, width: MediaQuery.of(context).size.width * 0.3, shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
