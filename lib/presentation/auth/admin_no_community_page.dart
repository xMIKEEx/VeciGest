import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminNoCommunityPage extends StatelessWidget {
  const AdminNoCommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibe los argumentos del usuario si existen
    final args = ModalRoute.of(context)?.settings.arguments;
    Map<String, dynamic>? userArgs;
    if (args != null && args is Map<String, dynamic>) {
      userArgs = args;
      print(
        'DEBUG: AdminNoCommunityPage recibió argumentos: $userArgs',
      );
    } else {
      print('DEBUG: AdminNoCommunityPage no recibió argumentos');
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Crear comunidad')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_work, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Necesitas crear una comunidad para continuar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Como administrador, debes crear una comunidad para poder gestionar tu vecindario.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  print('DEBUG: Botón Crear comunidad ahora pulsado');
                  if (userArgs != null) {
                    print(
                      'DEBUG: Navegando a /create-community con argumentos: $userArgs',
                    );
                    Navigator.of(
                      context,
                    ).pushNamed('/create-community', arguments: userArgs);
                  } else {
                    // Fallback: obtener usuario actual
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      print(
                        'DEBUG: Fallback, navegando a /create-community con usuario actual',
                      );
                      Navigator.of(context).pushNamed(
                        '/create-community',
                        arguments: {
                          'userId': user.uid,
                          'userEmail': user.email,
                          'displayName': user.displayName,
                        },
                      );
                    } else {
                      print('DEBUG: Fallback, sin usuario, navegando a /login');
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Crear comunidad ahora'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await Navigator.of(context).pushNamed('/login');
                },
                child: const Text('Volver al inicio de sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
