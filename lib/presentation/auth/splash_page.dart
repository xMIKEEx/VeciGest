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
              // Es un usuario normal, va al dashboard de usuario
              Navigator.of(context).pushReplacementNamed('/user-dashboard');
            }
          } else {
            // El usuario no tiene perfil en Firestore, lo enviamos a crear uno
            Navigator.of(context).pushReplacementNamed('/register');
          }
        }
      });
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your logo if available
            FlutterLogo(size: 100),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
