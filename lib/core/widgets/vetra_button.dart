// lib/core/widgets/vetra_button.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VetraButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;
  final double radius;
  final double fontSize;

  const VetraButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.height = 48,
    this.radius = 12,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                  ),
                ),
        ),
      ),
    );
  }
}
