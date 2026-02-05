import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Theme Settings Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: WastecColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          _buildThemeSettingsTile(context),
          const Divider(height: 24),
          
          // More settings can be added here
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'General',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: WastecColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Wastec Bank'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettingsTile(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          children: [
            ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.orange : Colors.blue,
              ),
              title: const Text('Theme'),
              subtitle: Text(
                themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
              ),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) async {
                  debugPrint('🎨 Switch onChange triggered with value: $value');
                  debugPrint('🎨 Current isDarkMode: ${themeProvider.isDarkMode}');
                  debugPrint('🎨 Current themeMode: ${themeProvider.themeMode}');
                  await themeProvider.toggleTheme();
                  debugPrint('🎨 After toggle - isDarkMode: ${themeProvider.isDarkMode}');
                },
                activeColor: WastecColors.primaryGreen,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('Auto Theme'),
              subtitle: const Text('Follow system theme'),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.system,
                onChanged: (value) async {
                  if (value) {
                    await themeProvider.setThemeMode(ThemeMode.system);
                  } else {
                    await themeProvider.setThemeMode(ThemeMode.light);
                  }
                },
                activeColor: WastecColors.primaryGreen,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Wastec Bank',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Wastec Bank. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Wastec Bank is an eco-friendly waste management and scrap recycling app that connects users with local waste dealers for sustainable waste disposal.',
        ),
      ],
    );
  }
}
