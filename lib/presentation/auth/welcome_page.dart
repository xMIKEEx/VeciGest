import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const String empresaEmail =
      'empresa@vecigest.com'; // Cambia por el email exclusivo

  @override
  Widget build(BuildContext context) {
    final user = null; // Aquí deberías obtener el usuario logueado si lo hay
    final isEmpresa = user?.email == empresaEmail;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 100),
                const SizedBox(height: 32),
                const Text(
                  'Bienvenido a VeciGest',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gestiona tu comunidad de vecinos de forma fácil y segura.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (isEmpresa)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.business),
                    label: const Text('Crear comunidad (Empresa)'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/create-community');
                    },
                  ),
                if (isEmpresa) const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Soy Administrador/Presidente'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder:
                          (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.login),
                                title: const Text('Iniciar sesión'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/login-admin');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.app_registration),
                                title: const Text('Registrarse'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/register-admin');
                                },
                              ),
                            ],
                          ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text('Soy Vecino/Usuario'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder:
                          (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.login),
                                title: const Text('Iniciar sesión'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/login-user');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.app_registration),
                                title: const Text('Registrarse'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/register-neighbor');
                                },
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
