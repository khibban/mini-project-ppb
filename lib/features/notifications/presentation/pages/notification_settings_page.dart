import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_reminder_app/core/constants/app_colors.dart';
import 'package:water_reminder_app/core/constants/app_constants.dart';
import 'package:water_reminder_app/features/notifications/presentation/providers/notification_provider.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enable/disable
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: provider.isEnabled
                              ? AppColors.primaryBlue.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          provider.isEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: provider.isEnabled
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Water Reminders',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              provider.isEnabled
                                  ? 'Reminders are active'
                                  : 'Reminders are disabled',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: provider.isEnabled,
                        onChanged: (value) => provider.toggleEnabled(value),
                        activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.5),
                        activeThumbColor: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (provider.isEnabled) ...[
                  // Interval
                  Text(
                    'Reminder Interval',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How often should we remind you?',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.reminderIntervals.map((interval) {
                      final isSelected =
                          provider.intervalMinutes == interval;
                      final label = interval < 60
                          ? '${interval}min'
                          : '${interval ~/ 60}h${interval % 60 > 0 ? " ${interval % 60}m" : ""}';
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => provider.setInterval(interval),
                        selectedColor:
                            AppColors.primaryBlue.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color:
                              isSelected ? AppColors.primaryBlue : null,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Active hours
                  Text(
                    'Active Hours',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reminders will only be sent during these hours',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _TimePickerCard(
                          label: 'Start',
                          hour: provider.startHour,
                          onChanged: (hour) =>
                              provider.setStartHour(hour),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.arrow_forward,
                            color: AppColors.textSecondary),
                      ),
                      Expanded(
                        child: _TimePickerCard(
                          label: 'End',
                          hour: provider.endHour,
                          onChanged: (hour) =>
                              provider.setEndHour(hour),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Test notification
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => provider.sendTestNotification(),
                      icon: const Icon(Icons.notifications),
                      label: const Text('Send Test Notification'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TimePickerCard extends StatelessWidget {
  final String label;
  final int hour;
  final Function(int) onChanged;

  const _TimePickerCard({
    required this.label,
    required this.hour,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: 0),
          builder: (context, child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (time != null) {
          onChanged(time.hour);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
