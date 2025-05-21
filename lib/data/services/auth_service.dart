import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to listen to auth state changes
  Stream<User?> get onAuthStateChanged => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reautenticación para acciones críticas
  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Usuario no autenticado');
    }
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(cred);
  }

  // Revocación inmediata (deshabilitar usuario)
  Future<void> disableUser(String uid) async {
    await _auth.currentUser
        ?.delete(); // Solo el propio usuario puede borrarse en cliente
    // Para revocación inmediata de otros usuarios, usar Cloud Functions (no posible desde cliente por seguridad)
  }

  // Usuario tester para pruebas
  static const String testerEmail = 'tester@vecigest.com';
  static const String testerPassword = 'tester1234';

  // Métodos simulados para envío de emails
  Future<void> sendWelcomeEmail(String email) async {
    // Aquí deberías integrar un servicio externo o Cloud Function para enviar emails reales
    // Por ahora, solo simula el envío
    print('Enviando email de bienvenida a $email');
  }

  Future<void> sendInviteNotification(String email, String link) async {
    // Simulación de notificación por email
    print('Enviando invitación a $email con enlace: $link');
  }
}
