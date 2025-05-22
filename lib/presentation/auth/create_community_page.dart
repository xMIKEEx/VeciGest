import 'package:flutter/material.dart';
import 'package:vecigest/data/services/community_service.dart';
import 'package:vecigest/data/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  // Propiedades para el usuario administrador
  String? _userId;
  String? _userEmail;
  String? _displayName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _userId = args['userId'];
      _userEmail = args['userEmail'];
      _displayName = args['displayName'];
      if (_userEmail != null && _emailCtrl.text.isEmpty) {
        _emailCtrl.text = _userEmail!;
      }
    } else {
      // Fallback: obtener usuario actual de FirebaseAuth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
        _userEmail = user.email;
        _displayName = user.displayName ?? user.email?.split('@')[0];
        if (_userEmail != null && _emailCtrl.text.isEmpty) {
          _emailCtrl.text = _userEmail!;
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final community = await CommunityService().createCommunity(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
        createdBy: _userId!,
      );
      // Asociar el usuario admin a la comunidad creada
      if (_userId != null && _userEmail != null && _displayName != null) {
        await UserService().createAdminUser(
          uid: _userId!,
          email: _userEmail!,
          displayName: _displayName!,
          communityId: community.id,
        );
        // Navegar a la home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _error = 'Faltan datos de usuario para asociar admin a comunidad';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al crear la comunidad: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear comunidad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la comunidad',
                ),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email de contacto',
                ),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Crear comunidad'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
