import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../shared/theme/app_colors.dart';

class ReceiptsStrip extends StatelessWidget {
  final List<String> receiptPaths;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const ReceiptsStrip({
    super.key,
    required this.receiptPaths,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: receiptPaths.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == receiptPaths.length) {
            return _buildAddButton();
          }
          return _buildReceiptThumbnail(index);
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAdd,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: AppColors.borderStrong,
          strokeWidth: 0.5,
          gap: 4,
        ),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(TablerIcons.plus, size: 18, color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildReceiptThumbnail(int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accentContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(TablerIcons.photo, color: AppColors.accent, size: 20),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => onRemove(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderDefault, width: 0.5),
              ),
              child: const Icon(TablerIcons.x, size: 10, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, const Radius.circular(6)));

    final dashPath = Path();
    double distance = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) => false;
}
