import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes and navigate accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) {
          Navigator.of(context).pushReplacementNamed('/login');
        } else if (!user.emailVerified) {
          Navigator.of(context).pushReplacementNamed('/register');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
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
