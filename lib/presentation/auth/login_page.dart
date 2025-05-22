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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a VeciGest'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Registrar administrador'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _GeneralLoginForm(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Iniciar sesión general'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const _TokenLoginForm()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Entrar por vivienda (token)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneralLoginForm extends StatefulWidget {
  const _GeneralLoginForm();
  @override
  State<_GeneralLoginForm> createState() => _GeneralLoginFormState();
}

class _GeneralLoginFormState extends State<_GeneralLoginForm> {
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
            if (userRole['communityId'] == null ||
                userRole['communityId'].isEmpty) {
              Navigator.of(context).pushReplacementNamed(
                '/admin-no-community',
                arguments: {
                  'userId': user.uid,
                  'userEmail': user.email,
                  'displayName': user.displayName,
                },
              );
            } else {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          } else {
            // Residentes también van al home
            if (userRole['viviendaId'] != null &&
                userRole['viviendaId'].toString().isNotEmpty) {
              Navigator.of(context).pushReplacementNamed('/home');
            } else {
              setState(() {
                _error = 'No tienes ninguna vivienda asignada.';
              });
              await FirebaseAuth.instance.signOut();
            }
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
      appBar: AppBar(title: const Text('Iniciar sesión general')),
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
          ],
        ),
      ),
    );
  }
}

class _TokenLoginForm extends StatefulWidget {
  const _TokenLoginForm();
  @override
  State<_TokenLoginForm> createState() => _TokenLoginFormState();
}

class _TokenLoginFormState extends State<_TokenLoginForm> {
  final TextEditingController _tokenController = TextEditingController();
  String? _error;
  bool _loading = false;

  void _checkToken() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() {
        _error = 'El token no puede estar vacío.';
        _loading = false;
      });
      return;
    }
    // Debug print to verify token value
    print('[DEBUG] Navigating to /invite-register with token: "$token"');
    try {
      Navigator.of(
        context,
      ).pushReplacementNamed('/invite-register', arguments: token);
    } catch (e) {
      setState(() {
        _error = 'Token inválido o expirado.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar por vivienda (token)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Introduce el token de invitación',
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_loading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _checkToken,
                child: const Text('Validar y registrarse'),
              ),
          ],
        ),
      ),
    );
  }
}
