import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../config/theme.dart';

/// Dialog allowing the user to configure the backend server IP / URL
class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ServerSettingsDialog(),
    );
  }

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConfig.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isNotEmpty) {
      await ApiConfig.setBaseUrl(newUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server URL set to: ${ApiConfig.baseUrl}')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _reset() async {
    await ApiConfig.resetToDefault();
    setState(() {
      _urlController.text = ApiConfig.baseUrl;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server URL reset to default (10.0.2.2:5000)')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.dns_outlined, color: AppTheme.primaryColor),
          SizedBox(width: 8),
          Text('Server Configuration', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify the backend REST API URL:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://192.168.1.X:5000/api',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ActionChip(
                  label: const Text('Android Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    setState(() {
                      _urlController.text = 'http://10.0.2.2:5000/api';
                    });
                  },
                ),
                ActionChip(
                  label: const Text('Localhost ADB (127.0.0.1)', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    setState(() {
                      _urlController.text = 'http://127.0.0.1:5000/api';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Text(
                'Tip: If running on a real physical phone, enter your PC\'s Wi-Fi IP address (e.g. http://192.168.1.100:5000/api).',
                style: TextStyle(fontSize: 11, color: Colors.brown),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _reset,
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
