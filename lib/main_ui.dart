// lib/main_ui.dart

import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';

class VetraNeonApp extends StatelessWidget {
  const VetraNeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // ----- THEME FIX -----
      // If your AppTheme has ThemeData get methods (recommended)
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,

      // ----- ROUTER FIX -----
      routerConfig: AppRouter.router,
    );
  }
}
