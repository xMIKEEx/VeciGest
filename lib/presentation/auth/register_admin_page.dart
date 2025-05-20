import 'package:flutter/material.dart';
import 'package:vecigest/data/services/auth_service.dart';
import 'package:vecigest/data/services/role_service.dart';

class RegisterAdminPage extends StatefulWidget {
  const RegisterAdminPage({super.key});

  @override
  State<RegisterAdminPage> createState() => _RegisterAdminPageState();
}

class _RegisterAdminPageState extends State<RegisterAdminPage> {
  final AuthService _authService = AuthService();
  final RoleService _roleService = RoleService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _adminKeyController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _communityIdController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  bool _showPassword = false;

  void _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final communityId = _communityIdController.text.trim();
    final adminKey = _adminKeyController.text.trim();
    if (communityId.isEmpty || adminKey.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Debes introducir el ID de comunidad y la clave de admin.';
      });
      return;
    }
    // Validar clave de admin contra la comunidad en Firestore
    final communityDoc = await _roleService.getCommunityById(communityId);
    if (communityDoc == null || communityDoc['adminKey'] != adminKey) {
      setState(() {
        _isLoading = false;
        _error = 'Clave de administrador o ID de comunidad incorrectos.';
      });
      return;
    }
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _isLoading = false;
        _error = 'Las contraseñas no coinciden.';
      });
      return;
    }
    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'admin',
        userData: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'communityId': communityId,
        },
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/complete-admin-data');
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
      appBar: AppBar(title: const Text('Registro Administrador')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed:
                      () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
              ),
            ),
            const SizedBox(height: 16),
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
              controller: _adminKeyController,
              decoration: const InputDecoration(
                labelText: 'Clave de administrador',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _communityIdController,
              decoration: const InputDecoration(labelText: 'ID de comunidad'),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
