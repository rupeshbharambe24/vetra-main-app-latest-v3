import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';
import '../../core/widgets/vetra_back_button.dart';
import '../../core/widgets/primary_button.dart';
import '../../auth/local_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final user = await LocalAuthService().getCurrentUser();
    if (mounted) {
      setState(() {
        _username = user;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await LocalAuthService().logout();
    _checkLogin(); // Refresh state
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final isLoggedIn = _username != null;

    return VetraGradientScaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        leading: const VetraBackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white24,
                child: Icon(isLoggedIn ? Icons.person : Icons.person_outline, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                isLoggedIn ? 'Welcome, $_username' : 'Welcome Guest',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                isLoggedIn ? 'Manage your account and settings' : 'Login to access full features',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isLoggedIn ? 'Account Actions' : 'Get Started', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    if (isLoggedIn) ...[
                       PrimaryButton(
                        label: 'Logout',
                        onPressed: _logout,
                        expanded: true,
                        backgroundColor: Colors.red,
                      ),
                    ] else ...[
                      PrimaryButton(
                        label: 'Login',
                        onPressed: () => context.push('/login').then((_) => _checkLogin()),
                        expanded: true,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).primaryColor),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => context.push('/signup').then((_) => _checkLogin()), // Assuming signup route
                        child: const Text('Create New Account'),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
