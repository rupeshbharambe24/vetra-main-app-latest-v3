// lib/screens/more/settings_screen.dart
import 'package:flutter/material.dart';
import '../../core/widgets/vetra_back_button.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  bool _dark = false;
  bool _autoSync = false;

  @override
  Widget build(BuildContext context) {
    return VetraGradientScaffold(
      appBar: AppBar(
        leading: const VetraBackButton(color: Colors.white),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SwitchListTile(
            value: _dark,
            onChanged: (v) => setState(() => _dark = v),
            title: const Text('Dark mode (UI only)', style: TextStyle(color: Colors.white)),
            activeColor: Theme.of(context).colorScheme.secondary,
          ),
          SwitchListTile(
            value: _autoSync,
            onChanged: (v) => setState(() => _autoSync = v),
            title: const Text('Auto-sync when online', style: TextStyle(color: Colors.white)),
            activeColor: Theme.of(context).colorScheme.secondary,
          ),
          const ListTile(
            title: Text('About this app', style: TextStyle(color: Colors.white)),
            subtitle: Text('VETRA v1.0', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
