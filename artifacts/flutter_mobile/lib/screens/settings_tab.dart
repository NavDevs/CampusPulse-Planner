import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../widgets/glass_card.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final pending = store.assignments.where((a) => !a.completed).length;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Preferences', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Class, assignment & exam reminders'),
                  value: store.settings.notificationsEnabled,
                  onChanged: (v) => store.updateSettings(notificationsEnabled: v),
                  activeColor: theme.colorScheme.primary,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Class Reminder', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Alert before class starts'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: store.settings.classReminderMinutes,
                        items: const [10, 15, 30].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
                        onChanged: (v) => store.updateSettings(classReminderMinutes: v ?? 15),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('App Theme', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Light, dark, or system default'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ThemeMode>(
                        value: store.settings.darkMode,
                        items: const [
                          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                        ],
                        onChanged: (v) => store.updateSettings(darkMode: v ?? ThemeMode.system),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Data Overview', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildStatTile(context, 'Classes Scheduled', '${store.timetable.length}', Icons.menu_book),
                const Divider(height: 1),
                _buildStatTile(context, 'Total Assignments', '${store.assignments.length}', Icons.assignment),
                const Divider(height: 1),
                _buildStatTile(context, 'Pending Assignments', '$pending', Icons.pending_actions, isAlert: pending > 5),
                const Divider(height: 1),
                _buildStatTile(context, 'Exams Scheduled', '${store.exams.length}', Icons.school),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              'CampusPulse Planner v2.0.0',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String title, String val, IconData icon, {bool isAlert = false}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (isAlert ? theme.colorScheme.error : theme.colorScheme.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: isAlert ? theme.colorScheme.error : theme.colorScheme.primary),
      ),
      title: Text(title),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12)),
        child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
