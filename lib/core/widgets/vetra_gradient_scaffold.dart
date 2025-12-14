import 'package:flutter/material.dart';

/// A Scaffold wrapper that applies the VETRA signature gradient background
/// (Primary Blue -> Secondary Green) to the entire screen.
class VetraGradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;

  const VetraGradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = true,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Using the same colors as the original LoginScreen gradient
    final blue = theme.colorScheme.primary;
    final green = theme.colorScheme.secondary;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            blue.withOpacity(0.95),
            green.withOpacity(0.95),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let gradient show through
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
