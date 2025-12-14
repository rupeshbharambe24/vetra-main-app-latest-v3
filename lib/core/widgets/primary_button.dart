import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool expanded;
  final Color? backgroundColor;

  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.expanded = true,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: backgroundColor != null ? ElevatedButton.styleFrom(backgroundColor: backgroundColor) : null,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      ),
    );

    if (expanded) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}
