import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_reminder_app/core/constants/app_colors.dart';
import 'package:water_reminder_app/core/utils/date_utils.dart';
import 'package:water_reminder_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:water_reminder_app/features/water_intake/presentation/providers/water_intake_provider.dart';
import 'package:water_reminder_app/features/water_intake/presentation/widgets/water_log_tile.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;
    context.read<WaterIntakeProvider>().loadAllLogs(userId);
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
                _loadData();
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
                _loadData();
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
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Consumer<WaterIntakeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.allLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group logs by date
          final grouped = <String, List<dynamic>>{};
          for (final log in provider.allLogs) {
            final dateKey = log.date;
            grouped.putIfAbsent(dateKey, () => []).add(log);
          }

          final sortedDates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final logs = grouped[date]!;
                final total = logs.fold<int>(0, (sum, l) => sum + (l.amount as int));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppDateUtils.toDisplayDate(
                                AppDateUtils.fromDateString(date)),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$total ml',
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...logs.map((log) => WaterLogTile(
                          log: log,
                          onEdit: () => _showEditDialog(log),
                          onDelete: () => _confirmDelete(log.id!),
                        )),
                    if (index < sortedDates.length - 1)
                      Divider(
                        height: 24,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
