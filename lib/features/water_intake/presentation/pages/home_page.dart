import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_reminder_app/core/constants/app_colors.dart';
import 'package:water_reminder_app/core/constants/app_constants.dart';
import 'package:water_reminder_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:water_reminder_app/features/goals/presentation/providers/goal_provider.dart';
import 'package:water_reminder_app/features/water_intake/presentation/providers/water_intake_provider.dart';
import 'package:water_reminder_app/features/water_intake/presentation/widgets/water_progress_circle.dart';
import 'package:water_reminder_app/features/water_intake/presentation/widgets/quick_add_buttons.dart';
import 'package:water_reminder_app/features/water_intake/presentation/widgets/water_log_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;

    context.read<WaterIntakeProvider>().loadTodayData(userId);
    context.read<GoalProvider>().loadCurrentGoal(userId);
  }

  void _handleQuickAdd(int amount) {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;

    context.read<WaterIntakeProvider>().addWaterLog(
          userId: userId,
          amount: amount,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.water_drop, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('+${amount}ml added!'),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAddCustomDialog() {
    final controller = TextEditingController();
    String selectedType = 'Water';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Add Water Intake',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount (ml)',
                        prefixIcon: const Icon(Icons.water_drop),
                        suffixText: 'ml',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Drink Type',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.drinkTypes.map((type) {
                        final isSelected = selectedType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (_) {
                            setDialogState(() => selectedType = type);
                          },
                          selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryBlue : null,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final amount = int.tryParse(controller.text);
                          if (amount == null || amount <= 0 || amount > 2000) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid amount (1-2000 ml)'),
                              ),
                            );
                            return;
                          }
                          final userId =
                              context.read<AuthProvider>().user?.uid;
                          if (userId == null) return;

                          context.read<WaterIntakeProvider>().addWaterLog(
                                userId: userId,
                                amount: amount,
                                drinkType: selectedType,
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('+${amount}ml $selectedType added!'),
                              backgroundColor: AppColors.primaryBlue,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Add'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(dynamic log) {
    final controller = TextEditingController(text: log.amount.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Water Log'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount (ml)',
              suffixText: 'ml',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(controller.text);
                if (amount == null || amount <= 0) return;

                final userId = context.read<AuthProvider>().user?.uid;
                if (userId == null) return;

                context.read<WaterIntakeProvider>().updateWaterLog(
                      log.copyWith(amount: amount),
                      userId,
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(int logId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Log'),
          content: const Text('Are you sure you want to delete this log?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final userId = context.read<AuthProvider>().user?.uid;
                if (userId == null) return;

                context
                    .read<WaterIntakeProvider>()
                    .deleteWaterLog(logId, userId);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello! 💧',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stay hydrated today',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              AppColors.primaryBlue.withValues(alpha: 0.1),
                          child: Text(
                            (auth.user?.email.substring(0, 1) ?? 'U')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Circle
                Center(
                  child: Consumer2<WaterIntakeProvider, GoalProvider>(
                    builder: (context, intake, goal, _) {
                      final goalMl = goal.currentGoal?.dailyTargetMl ??
                          AppConstants.defaultDailyGoalMl;
                      return WaterProgressCircle(
                        currentMl: intake.todayTotal,
                        goalMl: goalMl,
                        size: 220,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Stats row
                Consumer2<WaterIntakeProvider, GoalProvider>(
                  builder: (context, intake, goal, _) {
                    final goalMl = goal.currentGoal?.dailyTargetMl ??
                        AppConstants.defaultDailyGoalMl;
                    final remaining = intake.getRemaining(goalMl);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCard(
                          icon: Icons.water_drop,
                          label: 'Consumed',
                          value: '${intake.todayTotal} ml',
                          color: AppColors.primaryBlue,
                        ),
                        _StatCard(
                          icon: Icons.flag,
                          label: 'Remaining',
                          value: '$remaining ml',
                          color: remaining > 0
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                        _StatCard(
                          icon: Icons.format_list_numbered,
                          label: 'Entries',
                          value: '${intake.todayLogs.length}',
                          color: AppColors.accentTeal,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Quick Add Buttons
                QuickAddButtons(onAdd: _handleQuickAdd),
                const SizedBox(height: 28),

                // Recent Logs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Logs',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppColors.primaryBlue),
                      onPressed: _showAddCustomDialog,
                      tooltip: 'Add custom amount',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Consumer<WaterIntakeProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (provider.todayLogs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.water_drop_outlined,
                                size: 48,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No water logs yet today.\nTap a button above to start!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.todayLogs.length,
                      itemBuilder: (context, index) {
                        final log = provider.todayLogs[index];
                        return WaterLogTile(
                          log: log,
                          onEdit: () => _showEditDialog(log),
                          onDelete: () => _confirmDelete(log.id!),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 80), // Space for FAB/nav
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Water'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
