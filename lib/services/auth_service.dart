import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static Future<void>? _googleSignInInitFuture;

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
      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
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
      debugPrint('Código: ${e.code}');
      debugPrint('Mensagem: ${e.message}');
      rethrow;
    }
  }

  Future<UserCredential> entrarComGoogle() async {
    if (kIsWeb) {
      return await _auth.signInWithPopup(GoogleAuthProvider());
    }

    await _inicializarGoogleSignIn();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw FirebaseAuthException(
        code: 'google-sign-in-unavailable',
        message: 'Login com Google indisponível nesta plataforma.',
      );
    }

    final contaGoogle = await _googleSignIn.authenticate();
    final autenticacaoGoogle = contaGoogle.authentication;
    final idToken = autenticacaoGoogle.idToken;

    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: 'Não foi possível obter a credencial do Google.',
      );
    }

    final credencial = GoogleAuthProvider.credential(idToken: idToken);

    return await _auth.signInWithCredential(credencial);
  }

  Future<void> sair() async {
    await _auth.signOut();
  }

  Future<void> _inicializarGoogleSignIn() {
    final initFuture = _googleSignInInitFuture;
    if (initFuture != null) {
      return initFuture;
    }

    final novoInitFuture = _googleSignIn.initialize().catchError((Object erro) {
      _googleSignInInitFuture = null;
      throw erro;
    });

    _googleSignInInitFuture = novoInitFuture;
    return novoInitFuture;
  }
}
