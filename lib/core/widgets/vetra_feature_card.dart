// lib/core/widgets/vetra_feature_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VetraFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final bool isCentered;

  const VetraFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
    this.isCentered = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              // icon circle
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.withOpacity(0.95), AppTheme.accent.withOpacity(0.9)]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: c.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 6))],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
