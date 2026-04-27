import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:water_reminder_app/core/constants/app_colors.dart';

class WaterProgressCircle extends StatelessWidget {
  final int currentMl;
  final int goalMl;
  final double size;

  const WaterProgressCircle({
    super.key,
    required this.currentMl,
    required this.goalMl,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = goalMl > 0 ? (currentMl / goalMl).clamp(0.0, 1.0) : 0.0;
    final color = AppColors.getWaterLevelColor(percentage);

    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: 14,
      percent: percentage,
      animation: true,
      animationDuration: 800,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: color,
      backgroundColor: color.withValues(alpha: 0.15),
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.water_drop,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            '$currentMl',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            'of $goalMl ml',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
