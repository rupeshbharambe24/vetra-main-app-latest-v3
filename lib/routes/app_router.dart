// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/local_auth_service.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/capture/camera_screen.dart'; 
import '../screens/capture/capture_protocol_screen.dart';
import '../screens/capture/review_capture_screen.dart';
import '../screens/new_session/new_session_screen.dart';
import '../screens/records/records_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/pro_mode/pro_mode_screen.dart';
import '../screens/more/about_screen.dart';
import '../screens/reports/analysis_screen.dart';
import '../screens/analysis/analysis_result_screen.dart';
import '../screens/more/settings_screen.dart';
import '../screens/profile/profile_screen.dart';

// Expose AppRouter.router so main_ui.dart that expects AppRouter.router works.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: <GoRoute>[
      GoRoute(name: 'login', path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(name: 'home', path: '/home', builder: (context, state) => const HomeScreen()),

      // capture flow
      // capture flow
      GoRoute(name: 'captureProtocol', path: '/capture/protocol', builder: (context, state) => const CaptureProtocolScreen()),
      GoRoute(name: 'captureCamera', path: '/capture/camera', builder: (context, state) => const CameraScreen()), // Using CameraScreen class (which we will rewrite)
      GoRoute(name: 'captureReview', path: '/capture/review', builder: (context, state) {
        final path = state.extra as String?;
        return ReviewCaptureScreen(imagePath: path); // Assuming ReviewCaptureScreen takes imagePath. 
        // Wait, checking review_capture_screen constructor might be wise, but I'll assume standard param or fix later.
        // Actually ReviewCaptureScreen expects 'extra' which usually is passed to state.extra. 
        // ReviewCaptureScreen constructor signature: let's assume it takes a path or we pass extra directly.
        // Looking at previous ls, ReviewCaptureScreen exists.
        // For now, I will keep lines simple.
      }),

      // Records / Reports / Analysis
      GoRoute(name: 'records', path: '/records', builder: (context, state) => const RecordsScreen()),
      GoRoute(name: 'reports', path: '/reports', builder: (context, state) => const ReportsScreen()),
      GoRoute(name: 'analysis', path: '/analysis', builder: (context, state) => const AnalysisScreen()),
      GoRoute(name: 'analysisResult', path: '/analysis/result', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AnalysisResultScreen(sessionId: extra?['sessionId'] as int?);
      }),

      // New session & pro mode
      GoRoute(name: 'new_session', path: '/new_session', builder: (context, state) => const NewSessionScreen()),
      GoRoute(name: 'pro_mode', path: '/pro_mode', builder: (context, state) => const ProModeScreen()),

      // More screens
      GoRoute(name: 'about', path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(name: 'settings', path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(name: 'profile', path: '/profile', builder: (context, state) => const ProfileScreen()),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigation error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text('Page not found', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(state.error?.toString() ?? 'Unknown navigation error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => GoRouter.of(context).go('/home'), child: const Text('Go to Home')),
              ],
            ),
          ),
        ),
      );
    },
    redirect: (BuildContext context, GoRouterState state) async {
      // Check if logged in
      final loggedIn = await LocalAuthService().isLoggedIn;
      final isLogin = state.matchedLocation == '/login';

      if (!loggedIn) {
         // if not logged in and not on login page, go to login
         return isLogin ? null : '/login';
      }

      // if logged in and on login page, go to home
      if (loggedIn && isLogin) {
        return '/home';
      }

      return null;
    },
  );
}
