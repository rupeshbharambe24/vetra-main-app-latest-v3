import 'package:flutter/material.dart';

class ViewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback? onTap;

  const ViewCard({
    required this.title,
    required this.subtitle,
    this.statusLabel = 'Pending',
    this.statusColor = Colors.orange,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.photo_camera_outlined, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
