import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VetraGradientScaffold(
      appBar: AppBar(
        title: const Text('Welcome', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Expanded(
              child: PageView(
                children: [
                  _page(context, Icons.camera_alt, 'Capture multi-view photos', 'Follow the guided capture workflow to collect consistent views.'),
                  _page(context, Icons.data_array, 'Offline first', 'Sessions are saved locally and sync later when online.'),
                  _page(context, Icons.developer_mode, 'Pro Mode coming', '3D reconstruction & AR depth support in future updates.'),
                ],
              ),
            ),
            PrimaryButton(label: 'Get started', onPressed: () => context.go('/new_session')),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  Widget _page(BuildContext c, IconData icon, String title, String desc) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 110, color: Colors.white),
      const SizedBox(height: 20),
      Text(title, style: Theme.of(c).textTheme.titleLarge?.copyWith(color: Colors.white), textAlign: TextAlign.center),
      const SizedBox(height: 10),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70))),
    ]);
  }
}
