import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/storage_service.dart';
import '../premium/premium_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storage;
  const SettingsScreen({super.key, required this.storage});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StorageService get storage => widget.storage;
  bool _isThemesDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    widget.storage.addListener(_onStorageChanged);
  }

  @override
  void dispose() {
    widget.storage.removeListener(_onStorageChanged);
    super.dispose();
  }

  void _onStorageChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings ⚙️')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Mini Card
          CustomCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Text('🎓', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storage.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: storage.isLifetimeUltimate
                              ? const Color(0xFF06B6D4).withValues(alpha: 0.15)
                              : (storage.isProStudent
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                                  : (storage.currentPlan == UserPlan.removeAds
                                      ? const Color(0xFF64748B).withValues(alpha: 0.15)
                                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)))),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: storage.isLifetimeUltimate
                                ? const Color(0xFF06B6D4).withValues(alpha: 0.4)
                                : (storage.isProStudent
                                    ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                                    : (storage.currentPlan == UserPlan.removeAds
                                        ? const Color(0xFF64748B).withValues(alpha: 0.4)
                                        : Colors.transparent)),
                          ),
                        ),
                        child: Text(
                          storage.isLifetimeUltimate
                              ? 'Diamond Plan 💎'
                              : (storage.isProStudent
                                  ? 'Gold Plan 🥇'
                                  : (storage.currentPlan == UserPlan.removeAds
                                      ? 'Silver Plan 🥈'
                                      : 'Free Plan')),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: storage.isLifetimeUltimate
                                ? const Color(0xFF06B6D4)
                                : (storage.isProStudent
                                    ? const Color(0xFFF59E0B)
                                    : (storage.currentPlan == UserPlan.removeAds
                                        ? const Color(0xFF94A3B8)
                                        : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                  tooltip: 'Edit Name',
                  onPressed: () => _editNameDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Upgrade to Gold Banner if not Gold/Diamond
          if (!storage.isProStudent) ...[
            CustomCard(
              gradient: LinearGradient(
                colors: storage.currentPlan == UserPlan.removeAds
                    ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                    : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  storage.currentPlan == UserPlan.removeAds ? Icons.workspace_premium : Icons.stars_rounded,
                  color: Colors.amberAccent,
                  size: 32,
                ),
                title: Text(
                  storage.currentPlan == UserPlan.removeAds
                      ? 'Upgrade to Gold Plan (+₹50) 🥇'
                      : 'Silver & Gold Plans from ₹39',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  storage.currentPlan == UserPlan.removeAds
                      ? '₹39 already credited! Pay only ₹50 to unlock all Gold features'
                      : 'Silver (₹39) • Gold (₹89) • Lifetime access',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFD97706)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumScreen(storage: storage))),
                  child: Text(storage.currentPlan == UserPlan.removeAds ? 'Upgrade (+₹50)' : 'View Plans'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Preferences Group
          const Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'App Theme',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choose your preferred appearance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildThemeModeChip(
                            context: context,
                            label: 'System',
                            mode: 'system',
                            icon: Icons.brightness_auto_outlined,
                          ),
                          const SizedBox(width: 8),
                          _buildThemeModeChip(
                            context: context,
                            label: 'Light',
                            mode: 'light',
                            icon: Icons.light_mode_outlined,
                          ),
                          const SizedBox(width: 8),
                          _buildThemeModeChip(
                            context: context,
                            label: 'Dark',
                            mode: 'dark',
                            icon: Icons.dark_mode_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // 10 App Themes & Color Palettes
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.palette_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App Themes & Colors',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Applies across entire app UI',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: storage.isProStudent
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                                  : Colors.amber.shade700.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              storage.isProStudent ? 'GOLD UNLOCKED 🥇' : 'GOLD (₹89) 🔒',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: storage.isProStudent ? const Color(0xFFD97706) : Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildThemeDropdown(context, isDark),
                    ],
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_outlined, color: AppColors.secondary),
                  title: const Text('Local Notifications'),
                  subtitle: const Text('Reminders for classes and deadlines'),
                  value: storage.notificationsEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => storage.setNotificationsEnabled(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Privacy & Offline Promise
          const Text('PRIVACY & OFFLINE ARCHITECTURE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          CustomCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.success, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Data Stays on Your Device', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        'Student Utility Hub requires zero user account, no password, and does not upload your grades, notes, or schedules to any server. 100% offline and safe.',
                        style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About & Maintenance
          const Text('DATA & BACKUP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download_for_offline_outlined, color: AppColors.success),
                  title: const Text('Backup Data (JSON Export)'),
                  subtitle: const Text('Export all grades, attendance, and notes safely'),
                  onTap: () => _exportBackupDialog(context),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.upload_file_outlined, color: AppColors.secondary),
                  title: const Text('Restore Data (JSON Import)'),
                  subtitle: const Text('Restore data from a previously exported backup file'),
                  onTap: () => _importBackupDialog(context),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cloud_sync_outlined, color: Color(0xFFF59E0B)),
                  title: Row(
                    children: [
                      const Text('Cloud Sync & Backup'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'COMING SOON (₹149)',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: const Text('Lifetime Ultimate feature: Multi-device sync & cloud backup'),
                  onTap: () => _showCloudSyncInfo(context),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0 (Build 1) — Production Ready'),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever_outlined, color: AppColors.error),
                  title: const Text('Clear All User Data'),
                  subtitle: const Text('Permanently wipe saved timetable, attendance, and notes'),
                  onTap: () => _confirmResetDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editNameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: storage.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'First Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                storage.setUserName(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Application Data?'),
        content: const Text('This will permanently delete your custom saved semesters, attendance, timetable, notes, and expenses. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              storage.resetAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data has been cleared.')));
            },
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }

  void _exportBackupDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final jsonStr = storage.exportDataAsJson();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('JSON Backup Ready 📦'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Your complete offline database has been generated in JSON format.'),
            SizedBox(height: 8),
            Text('• Semesters & CGPA History\n• Tracked Attendance\n• Class Timetable\n• Assignments & Exams\n• Notes & Checklists', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup copied to clipboard!')));
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy JSON'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Share.share(jsonStr);
            },
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share File/Text'),
          ),
        ],
      ),
    );
  }

  void _importBackupDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from JSON Backup 📥'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Paste your previously exported JSON backup below:'),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: '{\n  "version": "1.0.0",\n  "semesters": [...]\n}',
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              final success = await storage.importDataFromJson(text);
              if (context.mounted) {
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎉 Database successfully restored!'), backgroundColor: AppColors.success),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('⚠️ Invalid backup format. Please verify the JSON string.'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeChip({
    required BuildContext context,
    required String label,
    required String mode,
    required IconData icon,
  }) {
    final isSelected = storage.themeMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            storage.setThemeMode(mode);
          },
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.transparent,
          splashColor: primaryColor.withValues(alpha: 0.15),
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor
                  : (isDark ? const Color(0xFF162032) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (isDark ? Colors.white.withValues(alpha: 0.4) : primaryColor)
                    : (isDark ? Colors.white24 : Colors.black12),
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeDropdown(BuildContext context, bool isDark) {
    final activePreset = AppTheme.getPreset(storage.themePresetId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dropdown trigger header
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isThemesDropdownOpen = !_isThemesDropdownOpen;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF162032) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isThemesDropdownOpen
                      ? activePreset.primaryColor
                      : (isDark ? Colors.white24 : Colors.black12),
                  width: _isThemesDropdownOpen ? 1.8 : 1.0,
                ),
                boxShadow: _isThemesDropdownOpen
                    ? [
                        BoxShadow(
                          color: activePreset.primaryColor.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Color dot
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: activePreset.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: activePreset.primaryColor.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  // Name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              activePreset.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: activePreset.primaryColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: activePreset.primaryColor.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: activePreset.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activePreset.styleDescription,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Expand / collapse chevron
                  Icon(
                    _isThemesDropdownOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _isThemesDropdownOpen
                        ? activePreset.primaryColor
                        : (isDark ? Colors.white70 : Colors.black54),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Dropdown menu list view
        if (_isThemesDropdownOpen) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D31) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: AppTheme.presets.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 0.8,
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                ),
                itemBuilder: (context, index) {
                  final preset = AppTheme.presets[index];
                  final isSelected = storage.themePresetId == preset.id;
                  final isLocked = !preset.isFree && !storage.isProStudent;

                  return Material(
                    color: isSelected
                        ? preset.primaryColor.withValues(alpha: isDark ? 0.22 : 0.1)
                        : Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (isLocked) {
                          showFeatureLockedDialog(
                            context,
                            featureTitle: '${preset.name} Theme 🎨',
                            requiredPlanTitle: 'GOLD PLAN (₹89)',
                            description:
                                'The ${preset.name} theme ("${preset.styleDescription}") is part of the Gold Plan.\n\nUpgrade to Gold Plan (₹89) or add +₹50 from Silver to unlock all 7 exclusive pro themes across the entire app!',
                            storage: storage,
                            planPrice: '₹89',
                          );
                          return;
                        }
                        storage.setThemePreset(preset.id);
                        setState(() {
                          _isThemesDropdownOpen = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✨ ${preset.name} theme applied across entire app!'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: preset.primaryColor,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            // Theme color dot
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: preset.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: preset.primaryColor.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                                  : (isLocked
                                      ? const Icon(Icons.lock, size: 11, color: Colors.white)
                                      : null),
                            ),
                            const SizedBox(width: 12),
                            // Theme Name and Style
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset.name,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected
                                          ? (isDark ? Colors.white : preset.primaryColor)
                                          : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    preset.styleDescription,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? preset.primaryColor.withValues(alpha: 0.25)
                                    : (preset.isFree
                                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                        : const Color(0xFFF59E0B).withValues(alpha: 0.15)),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? preset.primaryColor.withValues(alpha: 0.6)
                                      : (preset.isFree
                                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                          : const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                isSelected
                                    ? 'ACTIVE ✓'
                                    : (preset.isFree
                                        ? 'FREE'
                                        : (storage.isProStudent ? 'GOLD 🥇' : 'GOLD 🔒')),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? (isDark ? Colors.white : preset.primaryColor)
                                      : (preset.isFree
                                          ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                                          : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showCloudSyncInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.cloud_sync, color: Color(0xFFF59E0B), size: 24),
            SizedBox(width: 8),
            Text('Cloud Sync & Backup'),
          ],
        ),
        content: const Text(
          'Cloud sync and automated multi-device backup is part of the upcoming Lifetime Ultimate Plan (₹149).\n\nYour current data remains 100% private, safe, and stored locally offline on your device.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got It'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PremiumScreen(storage: storage)),
              );
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }
}
