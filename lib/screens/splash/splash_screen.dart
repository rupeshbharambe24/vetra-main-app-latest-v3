import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/vetra_gradient_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return VetraGradientScaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.pets, color: Theme.of(context).colorScheme.primary, size: 56),
          ),
          const SizedBox(height: 14),
          const Text('VETRA', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Guided multi-view capture', style: TextStyle(color: Colors.white70, fontSize: 16)),
        ]),
      ),
    );
  }
}
