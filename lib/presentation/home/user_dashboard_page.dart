import 'package:flutter/material.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Vecino')),
      body: const Center(
        child: Text(
          'Bienvenido al panel de usuario. Aquí verás tus incidencias, documentos, encuestas y reservas.',
        ),
      ),
    );
  }
}
