import 'package:firebase_auth/firebase_auth.dart';
import '../utils/validacao_dominio.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioAtual => _auth.currentUser;

  Future<UserCredential> cadastrar({
    required String email,
    required String senha,
  }) async {
    if (!isDomainValid(email)) {
      throw Exception(
        'Utilize um e-mail @souunit.com.br',
      );
    } 
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

    if (!isDomainValid(email)) {
      throw Exception(
        'Acesso permitido apenas para contas @souunit.com.br',
      );
    }

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