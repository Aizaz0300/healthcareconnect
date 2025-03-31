import 'package:flutter/material.dart';
import '/constants/app_colors.dart';

class SettingsManagementScreen extends StatefulWidget {
  const SettingsManagementScreen({super.key});

  @override
  State<SettingsManagementScreen> createState() => _SettingsManagementScreenState();
}

class _SettingsManagementScreenState extends State<SettingsManagementScreen> {
  bool enableNotifications = true;
  bool enableEmails = true;
  double commissionRate = 15.0;
  String selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGeneralSettings(),
          const SizedBox(height: 24),
          _buildPaymentSettings(),
          const SizedBox(height: 24),
          _buildNotificationSettings(),
          const SizedBox(height: 24),
          _buildSecuritySettings(),
          const SizedBox(height: 24),
          _buildMaintenanceSettings(),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return _SettingsCard(
      title: 'General Settings',
      children: [
        _buildDropdownSetting(
          'Default Language',
          ['English', 'Spanish', 'French'],
          'English',
          (value) {},
        ),
        const SizedBox(height: 16),
        _buildDropdownSetting(
          'Time Zone',
          ['UTC', 'UTC+1', 'UTC-5'],
          'UTC',
          (value) {},
        ),
      ],
    );
  }

  Widget _buildPaymentSettings() {
    return _SettingsCard(
      title: 'Payment Settings',
      children: [
        _buildDropdownSetting(
          'Currency',
          ['USD', 'EUR', 'GBP'],
          selectedCurrency,
          (value) {
            setState(() => selectedCurrency = value!);
          },
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Commission Rate (%)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Slider(
              value: commissionRate,
              min: 0,
              max: 30,
              divisions: 30,
              label: commissionRate.round().toString(),
              onChanged: (value) {
                setState(() => commissionRate = value);
              },
            ),
            Text(
              '${commissionRate.round()}%',
              style: const TextStyle(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return _SettingsCard(
      title: 'Notification Settings',
      children: [
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Enable system notifications'),
          value: enableNotifications,
          onChanged: (value) {
            setState(() => enableNotifications = value);
          },
        ),
        SwitchListTile(
          title: const Text('Email Notifications'),
          subtitle: const Text('Enable email notifications'),
          value: enableEmails,
          onChanged: (value) {
            setState(() => enableEmails = value);
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return _SettingsCard(
      title: 'Security Settings',
      children: [
        ListTile(
          title: const Text('Change Admin Password'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showChangePasswordDialog(),
        ),
        ListTile(
          title: const Text('Two-Factor Authentication'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _show2FADialog(),
        ),
      ],
    );
  }

  Widget _buildMaintenanceSettings() {
    return _SettingsCard(
      title: 'Maintenance',
      children: [
        ListTile(
          title: const Text('Backup Database'),
          trailing: const Icon(Icons.backup),
          onTap: () => _showBackupDialog(),
        ),
        ListTile(
          title: const Text('Clear Cache'),
          trailing: const Icon(Icons.cleaning_services),
          onTap: () => _showClearCacheDialog(),
        ),
      ],
    );
  }

  Widget _buildDropdownSetting(
    String label,
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password change
              Navigator.pop(context);
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _show2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: const Text('Configure 2FA settings here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Database'),
        content: const Text('Start database backup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
} 