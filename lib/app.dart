import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_reminder_app/core/theme/app_theme.dart';
import 'package:water_reminder_app/features/auth/presentation/pages/login_page.dart';
import 'package:water_reminder_app/features/auth/presentation/pages/register_page.dart';
import 'package:water_reminder_app/features/auth/presentation/pages/splash_page.dart';
import 'package:water_reminder_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:water_reminder_app/features/goals/presentation/pages/goal_settings_page.dart';
import 'package:water_reminder_app/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:water_reminder_app/features/profile/presentation/pages/profile_page.dart';
import 'package:water_reminder_app/features/water_intake/presentation/pages/history_page.dart';
import 'package:water_reminder_app/features/water_intake/presentation/pages/home_page.dart';

class WaterReminderApp extends StatelessWidget {
  const WaterReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Reminder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const MainNavigationPage(),
        '/goals': (_) => const GoalSettingsPage(),
        '/notifications': (_) => const NotificationSettingsPage(),
      },
    );
  }
}

/// Wrapper that directs users based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.initial:
            return const SplashPage();
          case AuthStatus.authenticated:
            return const MainNavigationPage();
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginPage();
          case AuthStatus.loading:
            return const SplashPage();
        }
      },
    );
  }
}

/// Main page with bottom navigation
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
