import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> registrar(
    String email, String contrasenya) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: contrasenya,
    );
  }

  Future<UserCredential> login(
    String email, String contrasenya) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: contrasenya,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}