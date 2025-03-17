import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Audio settings
          _buildSectionHeader(context, 'Audio Settings'),
          SwitchListTile(
            title: const Text('Enable Audio Feedback'),
            subtitle: const Text('Voice prompts during your run'),
            value: settingsProvider.audioEnabled,
            onChanged: (value) => settingsProvider.setAudioEnabled(value),
          ),
          ListTile(
            title: const Text('Audio Volume'),
            subtitle: Slider(
              value: settingsProvider.audioVolume,
              onChanged: (value) => settingsProvider.setAudioVolume(value),
              divisions: 10,
              label: '${(settingsProvider.audioVolume * 100).round()}%',
            ),
          ),
          ListTile(
            title: const Text('Voice Type'),
            subtitle: const Text('Select voice for audio feedback'),
            trailing: DropdownButton<String>(
              value: settingsProvider.voiceType,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setVoiceType(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'default',
                  child: Text('Default'),
                ),
                DropdownMenuItem(
                  value: 'coach',
                  child: Text('Coach'),
                ),
                DropdownMenuItem(
                  value: 'zombie',
                  child: Text('Zombie'),
                ),
              ],
            ),
          ),

          const Divider(),

          // UI settings
          _buildSectionHeader(context, 'Display Settings'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: settingsProvider.darkModeEnabled,
            onChanged: (value) => settingsProvider.setDarkModeEnabled(value),
          ),
          ListTile(
            title: const Text('Distance Unit'),
            subtitle: const Text('Choose your preferred unit of measurement'),
            trailing: DropdownButton<String>(
              value: settingsProvider.distanceUnit,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setDistanceUnit(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'km',
                  child: Text('Kilometers'),
                ),
                DropdownMenuItem(
                  value: 'miles',
                  child: Text('Miles'),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Theme Color'),
            subtitle: const Text('Choose app accent color'),
            trailing: DropdownButton<String>(
              value: settingsProvider.themeColor,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setThemeColor(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'blue',
                  child: Text('Blue'),
                ),
                DropdownMenuItem(
                  value: 'green',
                  child: Text('Green'),
                ),
                DropdownMenuItem(
                  value: 'purple',
                  child: Text('Purple'),
                ),
                DropdownMenuItem(
                  value: 'orange',
                  child: Text('Orange'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Notification settings
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive app notifications'),
            value: settingsProvider.notificationsEnabled,
            onChanged: (value) =>
                settingsProvider.setNotificationsEnabled(value),
          ),
          SwitchListTile(
            title: const Text('Milestone Notifications'),
            subtitle: const Text('Get notified when you reach milestones'),
            value: settingsProvider.milestoneNotifications,
            onChanged: settingsProvider.notificationsEnabled
                ? (value) => settingsProvider.setMilestoneNotifications(value)
                : null,
          ),
          SwitchListTile(
            title: const Text('Weekly Recap'),
            subtitle: const Text('Receive weekly summary of your runs'),
            value: settingsProvider.weeklyRecapEnabled,
            onChanged: settingsProvider.notificationsEnabled
                ? (value) => settingsProvider.setWeeklyRecapEnabled(value)
                : null,
          ),

          const Divider(),

          // Privacy settings
          _buildSectionHeader(context, 'Privacy'),
          SwitchListTile(
            title: const Text('Share Run Data'),
            subtitle:
                const Text('Allow anonymous data sharing for app improvement'),
            value: settingsProvider.shareRunData,
            onChanged: (value) => settingsProvider.setShareRunData(value),
          ),
          SwitchListTile(
            title: const Text('Store Location History'),
            subtitle: const Text('Save your run routes for future reference'),
            value: settingsProvider.locationHistoryEnabled,
            onChanged: (value) =>
                settingsProvider.setLocationHistoryEnabled(value),
          ),

          const Divider(),

          // About section
          _buildSectionHeader(context, 'About'),
          const ListTile(
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),

          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show terms of service
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show privacy policy
            },
          ),

          const SizedBox(height: 24),

          // Save button
          ElevatedButton(
            onPressed: () {
              settingsProvider.saveSettings();
              Navigator.pop(context);
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
