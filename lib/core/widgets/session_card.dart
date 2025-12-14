import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  final String id;
  final String subtitle;
  final VoidCallback? onResume;

  const SessionCard({
    required this.id,
    required this.subtitle,
    this.onResume,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.pets, size: 34),
        title: Text(id, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: onResume,
          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
          child: const Text('Resume'),
        ),
      ),
    );
  }
}
