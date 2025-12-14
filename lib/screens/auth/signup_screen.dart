import 'package:flutter/material.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'Enter phone number';
    // basic check
    if (!RegExp(r'^\d{10,15}$').hasMatch(v)) return 'Enter valid phone number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return VetraGradientScaffold(
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v == null || v.isEmpty ? 'Enter email' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone number'), keyboardType: TextInputType.phone, validator: _validatePhone),
                  const SizedBox(height: 12),
                  TextFormField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true, validator: (v) => v == null || v.length < 6 ? 'Password min 6 chars' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _confirm, decoration: const InputDecoration(labelText: 'Confirm password'), obscureText: true, validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm password';
                    if (v != _pass.text) return 'Passwords do not match';
                    return null;
                  }),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                    onPressed: _loading ? null : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _loading = true);
                      await Future.delayed(const Duration(milliseconds: 800));
                      setState(() => _loading = false);
                      // after creation navigate back to login
                      if (mounted) Navigator.of(context).pop();
                    },
                    child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create account'),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
