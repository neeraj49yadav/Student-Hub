import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'features/home/home_screen.dart';
import 'features/tools_hub_screen.dart';
import 'features/study_hub_screen.dart';
import 'features/tasks_hub_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();
  runApp(StudentUtilityHubApp(storage: storageService));
}

class StudentUtilityHubApp extends StatefulWidget {
  final StorageService storage;
  const StudentUtilityHubApp({super.key, required this.storage});

  @override
  State<StudentUtilityHubApp> createState() => _StudentUtilityHubAppState();
}

class _StudentUtilityHubAppState extends State<StudentUtilityHubApp> {
  @override
  void initState() {
    super.initState();
    widget.storage.addListener(_onStorageChange);
  }

  @override
  void dispose() {
    widget.storage.removeListener(_onStorageChange);
    super.dispose();
  }

  void _onStorageChange() {
    if (mounted) setState(() {});
  }

  ThemeMode _getThemeMode() {
    switch (widget.storage.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final preset = AppTheme.getPreset(widget.storage.themePresetId);
    AppTheme.applyPreset(preset);

    return MaterialApp(
      key: ValueKey('${preset.id}_${widget.storage.themeMode}'),
      title: 'Student HUb',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(preset),
      darkTheme: AppTheme.getDarkTheme(preset),
      themeMode: _getThemeMode(),
      home: MainNavigationShell(storage: widget.storage),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final StorageService storage;
  const MainNavigationShell({super.key, required this.storage});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        storage: widget.storage,
        onNavigateToTools: () => setState(() => _currentIndex = 1),
        onNavigateToStudy: () => setState(() => _currentIndex = 2),
        onNavigateToTasks: () => setState(() => _currentIndex = 3),
      ),
      ToolsHubScreen(storage: widget.storage),
      StudyHubScreen(storage: widget.storage),
      TasksHubScreen(storage: widget.storage),
      SettingsScreen(storage: widget.storage),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          elevation: 0,
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          indicatorColor: AppColors.primary.withValues(alpha: 0.16),
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = idx);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.calculate_outlined),
              selectedIcon: Icon(Icons.calculate, color: AppColors.primary),
              label: 'Tools',
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
              label: 'Study',
            ),
            NavigationDestination(
              icon: const Icon(Icons.task_alt_outlined),
              selectedIcon: Icon(Icons.task_alt, color: AppColors.primary),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: AppColors.primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
