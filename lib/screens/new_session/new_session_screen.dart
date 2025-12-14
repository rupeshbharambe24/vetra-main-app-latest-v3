import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/vetra_gradient_scaffold.dart';

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final _tagController = TextEditingController(text: 'TAG-001');
  String _species = 'Cow';

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VetraGradientScaffold(
      appBar: AppBar(
        title: const Text('New Session', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(controller: _tagController, decoration: const InputDecoration(labelText: 'Animal ID / Tag')),
                const SizedBox(height: 12),
                Row(children: [
                  const Text('Species:'),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _species,
                    items: const [
                      DropdownMenuItem(value: 'Cow', child: Text('Cow')),
                      DropdownMenuItem(value: 'Buffalo', child: Text('Buffalo')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _species = v ?? 'Cow'),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(maxLines: 3, decoration: const InputDecoration(labelText: 'Notes (optional)')),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: Center(child: Text('Tap Create to start guided capture', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)))),
          Row(children: [
            Expanded(child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
              onPressed: () => context.pop(), 
              child: const Text('Cancel')
            )),
            const SizedBox(width: 12),
            Expanded(child: PrimaryButton(label: 'Create Session', onPressed: () => context.go('/pro_mode'), expanded: true)),
          ]),
        ]),
      ),
    );
  }
}
