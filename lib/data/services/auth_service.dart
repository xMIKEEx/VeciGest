import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Registro unificado para usuario o admin
  Future<UserCredential> register({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? communityData,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (role == 'admin') {
      // Crea comunidad y asocia admin
      final communityRef = await FirebaseFirestore.instance
          .collection('communities')
          .add({
            ...?communityData,
            'adminId': userCred.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
            ...?userData,
            'role': 'admin',
            'communityId': communityRef.id,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
            ...?userData,
            'role': 'user',
            'communityId': userData?['communityId'],
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });
    }
    return userCred;
  }

  // Usuario tester para pruebas
  static const String testerEmail = 'tester@vecigest.com';
  static const String testerPassword = 'tester1234';
}
