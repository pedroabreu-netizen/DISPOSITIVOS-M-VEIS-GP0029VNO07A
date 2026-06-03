import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioAtual => _auth.currentUser;

  Future<UserCredential> cadastrar({
    required String email,
    required String senha,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );
  } on FirebaseAuthException catch (e) {
    print('Código: ${e.code}');
    print('Mensagem: ${e.message}');
    rethrow;
  }
  }

  Future<UserCredential> entrar({
    required String email,
    required String senha,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print('Código: ${e.code}');
      print('Mensagem: ${e.message}');
      rethrow;
    }
  }

  Future<void> sair() async {
    await _auth.signOut();
  }
}