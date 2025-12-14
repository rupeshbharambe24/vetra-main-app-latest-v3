// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/local_auth_service.dart';
import '../../core/widgets/vetra_button.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  bool _obscure = true;

  final _auth = LocalAuthService();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    setState(() => _loading = true);

    try {
      bool ok = false;
      if (_isRegister) {
        if (_passwordCtrl.text != _confirmCtrl.text) {
          _showError('Passwords do not match');
          setState(() => _loading = false);
          return;
        }
        ok = await _auth.register(username, password);
        if (!ok) {
          _showError('Username exists — pick another.');
          setState(() => _loading = false);
          return;
        }
        ok = await _auth.login(username, password);
      } else {
        ok = await _auth.login(username, password);
      }

      if (ok) {
        if (!mounted) return;
        context.go('/home');
      } else {
        _showError('Invalid credentials');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String? _validateUsername(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter username';
    if (v.trim().length < 3) return 'Min 3 chars';
    return null;
  }

  String? _validatePhone(String? v) {
    if (_isRegister) {
      if (v == null || v.trim().isEmpty) return 'Enter phone number';
      final digits = v.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 7) return 'Enter a valid phone';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (v.length < 4) return 'At least 4 chars';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using VetraGradientScaffold for full screen background
    return VetraGradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header: Transparent container just for spacing/logo now
            // The gradient is already everywhere.
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.30,
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   Image.asset('assets/vetra_cow.png', height: 80, fit: BoxFit.contain),
                    const SizedBox(height: 12),
                    Text(
                      'VETRA',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white, fontSize: 46, fontWeight: FontWeight.w800, letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRegister ? 'Create your account' : 'Welcome back',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // White form card overlapping or just sitting there
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username
                          TextFormField(
                            controller: _usernameCtrl,
                            validator: _validateUsername,
                            decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
                          ),
                          const SizedBox(height: 12),

                          // Phone (only for register)
                          if (_isRegister) ...[
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              validator: _validatePhone,
                              decoration: const InputDecoration(labelText: 'Phone number', prefixIcon: Icon(Icons.phone_android)),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            validator: _validatePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Confirm password (register)
                          if (_isRegister) ...[
                            TextFormField(
                              controller: _confirmCtrl,
                              obscureText: true,
                              validator: (v) {
                                if (_isRegister && (v == null || v.isEmpty)) return 'Confirm password';
                                if (_isRegister && v != _passwordCtrl.text) return 'Passwords do not match';
                                return null;
                              },
                              decoration: const InputDecoration(labelText: 'Confirm password', prefixIcon: Icon(Icons.lock)),
                            ),
                            const SizedBox(height: 12),
                          ],

                          const SizedBox(height: 6),
                          
                          // Button
                          VetraButton(text: _isRegister ? 'Create account' : 'Login', loading: _loading, onPressed: _submit),
                          const SizedBox(height: 12),
                          
                          Center(child: Text('Offline data stored locally', style: theme.textTheme.bodySmall)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Toggle
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isRegister ? 'Already have an account?' : "Don't have an account?", style: const TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () => setState(() {
                      _isRegister = !_isRegister;
                    }),
                    child: Text(_isRegister ? 'Login' : 'Register', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
