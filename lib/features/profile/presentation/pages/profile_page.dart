import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_reminder_app/core/constants/app_colors.dart';
import 'package:water_reminder_app/core/utils/date_utils.dart';
import 'package:water_reminder_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:water_reminder_app/features/sync/presentation/providers/sync_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sync = context.watch<SyncProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (auth.user?.email.substring(0, 1) ?? 'U').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              auth.user?.email ?? 'Unknown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 32),

            // Sync Status Card
            Container(
              width: double.infinity,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        sync.isConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: sync.isConnected
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sync.isConnected ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: sync.isConnected
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (sync.lastSyncTime != null)
                    Text(
                      'Last synced: ${AppDateUtils.toFullDisplay(sync.lastSyncTime!)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  if (sync.lastSyncMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      sync.lastSyncMessage!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: sync.isSyncing
                          ? null
                          : () {
                              final userId = auth.user?.uid;
                              if (userId != null) {
                                sync.syncNow(userId).then((result) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result.success
                                          ? '✅ Synced ${result.totalSynced} items'
                                          : '❌ ${result.message}'),
                                      backgroundColor: result.success
                                          ? AppColors.success
                                          : AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                });
                              }
                            },
                      icon: sync.isSyncing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.sync),
                      label: Text(sync.isSyncing ? 'Syncing...' : 'Sync Now'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Menu items
            _ProfileMenuItem(
              icon: Icons.flag,
              title: 'Goal Settings',
              subtitle: 'Set your daily water target',
              onTap: () => Navigator.pushNamed(context, '/goals'),
            ),
            _ProfileMenuItem(
              icon: Icons.notifications,
              title: 'Notification Settings',
              subtitle: 'Configure water reminders',
              onTap: () => Navigator.pushNamed(context, '/notifications'),
            ),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Logout'),
                      content:
                          const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryBlue, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
