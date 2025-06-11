import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vecigest/data/services/user_role_service.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes and navigate accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user == null) {
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          // Verificamos si el usuario es un admin y si tiene comunidad asociada
          final userRole = await UserRoleService().getUserRoleAndCommunity(
            user.uid,
          );

          if (userRole != null) {
            if (userRole['role'] == 'admin') {
              if (userRole['communityId'] == null ||
                  userRole['communityId'].isEmpty) {
                // Es un admin pero no tiene comunidad, lo enviamos a la página informativa
                Navigator.of(
                  context,
                ).pushReplacementNamed('/admin-no-community');
              } else {
                // Es admin y tiene comunidad, va a la home de admin
                Navigator.of(context).pushReplacementNamed('/home');
              }
            } else {
              // Es un usuario normal, va al home
              Navigator.of(context).pushReplacementNamed('/home');
            }
          } else {
            // El usuario no tiene perfil en Firestore, lo enviamos a crear uno
            Navigator.of(context).pushReplacementNamed('/register');
          }
        }
      });
    });
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo con animación y sombra
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo1.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              // Título de la app
              Text(
                'VeciGest',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 2.0,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Gestión inteligente de comunidades',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 60),

              // Indicador de carga moderno
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Iniciando aplicación...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
