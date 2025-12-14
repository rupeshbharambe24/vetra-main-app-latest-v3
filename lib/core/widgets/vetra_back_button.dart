// lib/core/widgets/vetra_back_button.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetraBackButton extends StatelessWidget {
  final Color? color;
  final double size;
  final EdgeInsets padding;

  const VetraBackButton({
    this.color,
    this.size = 24,
    this.padding = const EdgeInsets.all(4),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).iconTheme.color;
    return Padding(
      padding: padding,
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: size, color: iconColor),
        onPressed: () {
          // If navigator can pop, pop. Otherwise, go to home as fallback.
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            // use go_router fallback to home
            context.go('/home');
          }
        },
        tooltip: 'Back',
      ),
    );
  }
}
