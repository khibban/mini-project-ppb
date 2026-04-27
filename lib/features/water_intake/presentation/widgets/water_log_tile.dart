import 'package:flutter/material.dart';
import 'package:water_reminder_app/core/constants/app_colors.dart';
import 'package:water_reminder_app/core/utils/date_utils.dart';
import 'package:water_reminder_app/features/water_intake/domain/entities/water_log.dart';

class WaterLogTile extends StatelessWidget {
  final WaterLog log;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WaterLogTile({
    super.key,
    required this.log,
    this.onEdit,
    this.onDelete,
  });

  IconData _getDrinkIcon() {
    switch (log.drinkType.toLowerCase()) {
      case 'tea':
        return Icons.emoji_food_beverage;
      case 'coffee':
        return Icons.coffee;
      case 'juice':
        return Icons.local_bar;
      case 'milk':
        return Icons.local_drink;
      default:
        return Icons.water_drop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDrinkIcon(),
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.amount} ml',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.drinkType} • ${AppDateUtils.toDisplayTime(log.timestamp)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (log.isSynced)
            Icon(
              Icons.cloud_done,
              size: 16,
              color: AppColors.success.withValues(alpha: 0.6),
            ),
          if (onEdit != null || onDelete != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
