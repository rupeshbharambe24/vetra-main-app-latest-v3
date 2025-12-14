// lib/screens/more/about_screen.dart
import 'package:flutter/material.dart';
import '../../core/widgets/vetra_back_button.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return VetraGradientScaffold(
      appBar: AppBar(
        leading: const VetraBackButton(color: Colors.white),
        title: const Text('About VETRA', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
        children: [
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text('Advanced livestock trait extraction using AI technology', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    'VETRA uses AI models trained on thousands of livestock images to extract important traits and provide reliable estimates. '
                    'The system helps smallholder farmers and vets to quickly inspect animals, generate reports and keep historical records.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Why VETRA', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          _featureTile(context, 'Very Fast Results', 'Get classification results in seconds, not hours.'),
          _featureTile(context, 'Always Learning', 'Every image improves model accuracy over time.'),
          _featureTile(context, 'Works for Many Breeds', 'Trained on many breeds of cows & buffalo.'),
        ],
      ),
    );
  }

  Widget _featureTile(BuildContext context, String t, String s) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12), child: Icon(Icons.check, color: Theme.of(context).colorScheme.primary)),
        title: Text(t),
        subtitle: Text(s),
      ),
    );
  }
}
