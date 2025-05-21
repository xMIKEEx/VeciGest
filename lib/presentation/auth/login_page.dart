import 'package:flutter/material.dart';
import 'package:vecigest/data/services/auth_service.dart';
import 'package:vecigest/data/services/user_role_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;
  bool _showPassword = false;
  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userRole = await UserRoleService().getUserRoleAndCommunity(
          user.uid,
        );

        if (userRole != null && mounted) {
          if (userRole['role'] == 'admin') {
            // Si es admin, verificamos si tiene comunidad
            if (userRole['communityId'] == null ||
                userRole['communityId'].isEmpty) {
              print(
                'DEBUG: Admin sin comunidad detectado, navegando a /admin-no-community',
              );
              // No tiene comunidad, redirigir a la página informativa y pasar argumentos
              Navigator.of(context).pushReplacementNamed(
                '/admin-no-community',
                arguments: {
                  'userId': user.uid,
                  'userEmail': user.email,
                  'displayName': user.displayName,
                },
              );
            } else {
              print('DEBUG: Admin con comunidad, navegando a /home');
              // Tiene comunidad, va a la home de admin
              Navigator.of(context).pushReplacementNamed('/home');
            }
          } else {
            // Es usuario normal, va al dashboard de usuario
            Navigator.of(context).pushReplacementNamed('/user-dashboard');
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
      // Quita la flecha hacia atrás
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword,
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(onPressed: _login, child: const Text('Entrar')),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Image.asset(
                'assets/google_logo.png',
                height: 24,
                width: 24,
              ),
              label: const Text('Iniciar sesión con Google'),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                try {
                  final userCredential = await _authService.signInWithGoogle();
                  if (userCredential != null && mounted) {
                    // Al hacer login con Google, mejor ir al splash que decidirá a dónde dirigir
                    Navigator.of(context).pushReplacementNamed('/');
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
