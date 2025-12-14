// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/vetra_back_button.dart';
import '../../core/widgets/vetra_button.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';
import '../../core/widgets/vetra_feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      context.push('/camera');
    } else if (status.isDenied) {
      _showDialog(context, 'Camera permission required to capture images.');
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, 'Camera permission permanently denied. Open settings to enable it.');
    }
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(title: const Text('Permission required'), content: Text(message), actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))
      ]),
    );
  }

  void _showSettingsDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Open settings'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => openAppSettings(), child: const Text('Open Settings')),
        ],
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final Uri u = Uri.parse(url);
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return VetraGradientScaffold(
      // floatingActionButton removed
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar (White text on gradient)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the title if back button is gone
                children: [
                  Text(
                    'VETRA',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello!', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(
                      'Vetra empowers you with AI-driven veterinary diagnostics and secure record management.',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),

                    // Feature Actions
                    Column(
                      children: [
                        // Large Rectangular "Vetra AI" Button
                        SizedBox(
                          width: double.infinity,
                          child: AspectRatio(
                            aspectRatio: 2.2, // Rectangular shape
                            child: VetraFeatureCard(
                              title: 'VETRA AI', 
                              subtitle: 'Analyze images & get report', 
                              icon: Icons.biotech_outlined, 
                              color: theme.colorScheme.primary, 
                              onTap: () => context.push('/capture/protocol'),
                              isCentered: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Reports and Records
                        Row(
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1.1, // Near square
                                child: VetraFeatureCard(
                                  title: 'Records', 
                                  subtitle: 'Past sessions', 
                                  icon: Icons.folder_open, 
                                  color: theme.colorScheme.secondary, 
                                  onTap: () => context.push('/records')
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1.1, // Near square
                                child: VetraFeatureCard(
                                  title: 'Reports', 
                                  subtitle: 'Downloads', 
                                  icon: Icons.picture_as_pdf, 
                                  color: Colors.teal, 
                                  onTap: () => context.push('/reports')
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Quick access tiles
                    Text('Quick access', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 12),
                    
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: AspectRatio(aspectRatio: 1.1, child: _quickTile(context, Icons.phone_in_talk, 'Helpline', '24/7 support', onTap: () async {
                              final uri = Uri.parse('tel:+911234567890');
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            }))),
                            const SizedBox(width: 12),
                            Expanded(child: AspectRatio(aspectRatio: 1.1, child: _quickTile(context, Icons.show_chart_outlined, 'Analysis', 'View charts', onTap: () => context.push('/analysis')))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                             Expanded(child: AspectRatio(aspectRatio: 1.1, child: _quickTile(context, Icons.info_outline, 'About', 'About VETRA', onTap: () => context.push('/about')))),
                             const SizedBox(width: 12),
                             Expanded(child: AspectRatio(aspectRatio: 1.1, child: _quickTile(context, Icons.book, 'Schemes', 'Gov schemes', onTap: () => _openLink('https://www.google.com')))),
                          ],
                        ),
                      ],
                    ),
  
                    const SizedBox(height: 24),
                    
                    // What VETRA Measures
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('What VETRA Measures', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _bulletPoint(theme, 'Body Length'),
                          _bulletPoint(theme, 'Withers Height'),
                          _bulletPoint(theme, 'Heart Girth'),
                          _bulletPoint(theme, 'Hip Width'),
                          _bulletPoint(theme, 'Body Weight (Estimated)'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tips for Best Results
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tips for Best Results', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _bulletPoint(theme, 'Ensure good lighting conditions'),
                          _bulletPoint(theme, 'Position animal sideways (profile view)'),
                          _bulletPoint(theme, 'Keep animal stable and standing'),
                          _bulletPoint(theme, 'Maintain clear view of body outline'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Center(child: Text('Tap any option to open', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 78,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, Icons.home, 'Home', () => context.go('/home')),
              _navItem(context, Icons.folder, 'Data', () => context.go('/records')),
              _navItem(context, Icons.person, 'Profile', () => context.push('/profile')),
            ],
          ),
        ),
      ),
    );
  }

  // Update _quickTile to take full space or rely on parent AspectRatio
  Widget _quickTile(BuildContext context, IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    // Removed fixed width 115
    return InkWell(
        onTap: onTap,
        child: Container(
          // width: 115, // Removed fixed width
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: AppTheme.borderRadius(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.grey[800]),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[800]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  Widget _bulletPoint(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: theme.colorScheme.secondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]))),
        ],
      ),
    );
  }
}
