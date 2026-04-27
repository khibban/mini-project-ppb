import 'package:flutter/material.dart';
import 'package:water_reminder_app/core/constants/app_colors.dart';
import 'package:water_reminder_app/core/constants/app_constants.dart';

class QuickAddButtons extends StatelessWidget {
  final Function(int amount) onAdd;

  const QuickAddButtons({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppConstants.quickAddAmounts.map((amount) {
            return _QuickAddChip(
              amount: amount,
              onTap: () => onAdd(amount),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickAddChip extends StatefulWidget {
  final int amount;
  final VoidCallback onTap;

  const _QuickAddChip({required this.amount, required this.onTap});

  @override
  State<_QuickAddChip> createState() => _QuickAddChipState();
}

class _QuickAddChipState extends State<_QuickAddChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onTap();
    });
  }

  IconData _getIcon() {
    if (widget.amount <= 150) return Icons.local_cafe;
    if (widget.amount <= 250) return Icons.coffee;
    return Icons.local_drink;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withValues(alpha: 0.1),
                  AppColors.accentCyan.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getIcon(), size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 6),
                Text(
                  '+${widget.amount}ml',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
