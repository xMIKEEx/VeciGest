import 'package:flutter/material.dart';
import 'package:vecigest/data/services/role_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompleteUserDataPage extends StatefulWidget {
  const CompleteUserDataPage({super.key});

  @override
  State<CompleteUserDataPage> createState() => _CompleteUserDataPageState();
}

class _CompleteUserDataPageState extends State<CompleteUserDataPage> {
  final RoleService _roleService = RoleService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _flatController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _save() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No autenticado');
      await _roleService.updateUserData(user.uid, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'flat': _flatController.text.trim(),
      });
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completa tus datos (Usuario)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _flatController,
              decoration: const InputDecoration(labelText: 'Piso/Vivienda'),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
