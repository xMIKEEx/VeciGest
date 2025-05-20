import 'package:flutter/material.dart';
import 'package:vecigest/data/services/auth_service.dart';
import 'package:vecigest/data/services/role_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginUserPage extends StatefulWidget {
  const LoginUserPage({super.key});

  @override
  State<LoginUserPage> createState() => _LoginUserPageState();
}

class _LoginUserPageState extends State<LoginUserPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final RoleService _roleService = RoleService();

  bool _isLoading = false;
  String? _error;
  bool _showPassword = false;

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userCredential = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      final user = userCredential.user;
      if (user != null) {
        final role = await _roleService.getUserRole(user.uid);
        if (role != 'user') {
          await _authService.signOut();
          setState(() {
            _error = 'Solo los usuarios pueden iniciar sesión aquí.';
          });
          return;
        }
        // Redirigir a completar datos si faltan
        final userData = await _roleService.getUserData(user.uid);
        if (userData == null ||
            userData['name'] == null ||
            userData['flat'] == null) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/complete-user-data');
          }
        } else {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
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
      appBar: AppBar(title: const Text('Login Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
