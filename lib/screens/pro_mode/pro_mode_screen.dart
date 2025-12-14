import 'package:flutter/material.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';
import '../../core/widgets/vetra_back_button.dart';

class ProModeScreen extends StatelessWidget {
  const ProModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VetraGradientScaffold(
      appBar: AppBar(
        title: const Text('Pro Mode', style: TextStyle(color: Colors.white)),
        leading: const VetraBackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('3D reconstruction (coming soon)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('This screen will let you register your device and run ARCore depth-based captures.'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () {}, child: const Text('Register device (placeholder)')),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Notes: Pro Mode requires ARCore depth API. Implementation will be added later.', style: TextStyle(color: Colors.white70)),
        ]),
      ),
    );
  }
}
