import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_reminder_app/core/constants/app_colors.dart';
import 'package:water_reminder_app/core/constants/app_constants.dart';
import 'package:water_reminder_app/core/utils/date_utils.dart';
import 'package:water_reminder_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:water_reminder_app/features/goals/presentation/providers/goal_provider.dart';

class GoalSettingsPage extends StatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  State<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends State<GoalSettingsPage> {
  double _sliderValue = AppConstants.defaultDailyGoalMl.toDouble();
  final _customController = TextEditingController();
  bool _useSlider = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goal = context.read<GoalProvider>().currentGoal;
      if (goal != null) {
        setState(() {
          _sliderValue = goal.dailyTargetMl.toDouble();
        });
      }
      final userId = context.read<AuthProvider>().user?.uid;
      if (userId != null) {
        context.read<GoalProvider>().loadGoalHistory(userId);
      }
    });
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _saveGoal() async {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;

    int targetMl;
    if (_useSlider) {
      targetMl = _sliderValue.toInt();
    } else {
      targetMl = int.tryParse(_customController.text) ?? 0;
      if (targetMl < AppConstants.minGoalMl ||
          targetMl > AppConstants.maxGoalMl) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Goal must be between ${AppConstants.minGoalMl}ml and ${AppConstants.maxGoalMl}ml'),
          ),
        );
        return;
      }
    }

    final success = await context.read<GoalProvider>().setGoal(
          userId: userId,
          dailyTargetMl: targetMl,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily goal set to ${targetMl}ml! 🎯'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goal Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current goal card
            Consumer<GoalProvider>(
              builder: (context, provider, _) {
                final goal = provider.currentGoal;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.flag, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '${goal?.dailyTargetMl ?? AppConstants.defaultDailyGoalMl} ml',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Daily Goal',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Set new goal
            Text(
              'Set New Goal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Toggle slider / custom input
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Slider'),
                  selected: _useSlider,
                  onSelected: (_) => setState(() => _useSlider = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: !_useSlider,
                  onSelected: (_) => setState(() => _useSlider = false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_useSlider) ...[
              Center(
                child: Text(
                  '${_sliderValue.toInt()} ml',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              Slider(
                value: _sliderValue,
                min: AppConstants.minGoalMl.toDouble(),
                max: AppConstants.maxGoalMl.toDouble(),
                divisions:
                    (AppConstants.maxGoalMl - AppConstants.minGoalMl) ~/
                        AppConstants.goalStepMl,
                label: '${_sliderValue.toInt()} ml',
                onChanged: (value) {
                  setState(() => _sliderValue = value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${AppConstants.minGoalMl}ml',
                      style: TextStyle(color: AppColors.textSecondary)),
                  Text('${AppConstants.maxGoalMl}ml',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ] else ...[
              TextField(
                controller: _customController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Daily Target',
                  hintText: 'Enter amount in ml',
                  suffixText: 'ml',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveGoal,
                icon: const Icon(Icons.save),
                label: const Text('Save Goal'),
              ),
            ),
            const SizedBox(height: 32),

            // Goal history
            Text(
              'Goal History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            Consumer<GoalProvider>(
              builder: (context, provider, _) {
                if (provider.goalHistory.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No goal history yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.goalHistory.length,
                  itemBuilder: (context, index) {
                    final goal = provider.goalHistory[index];
                    final isActive = goal.endDate == null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: isActive
                            ? Border.all(color: AppColors.primaryBlue, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isActive ? Icons.flag : Icons.flag_outlined,
                              color: isActive
                                  ? AppColors.primaryBlue
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${goal.dailyTargetMl} ml/day',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? AppColors.primaryBlue
                                        : null,
                                  ),
                                ),
                                Text(
                                  isActive
                                      ? 'Active since ${AppDateUtils.toDisplayDate(goal.startDate)}'
                                      : '${AppDateUtils.toDisplayDate(goal.startDate)} — ${AppDateUtils.toDisplayDate(goal.endDate!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
