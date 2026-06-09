import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/validacao_dominio.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static Future<void>? _googleSignInInitFuture;

  User? get usuarioAtual => _auth.currentUser;

  Future<UserCredential> cadastrar({
    required String email,
    required String senha,
  }) async {
    if (!isDomainValid(email)) {
      throw Exception('Utilize um e-mail @souunit.com.br');
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
      throw Exception('Acesso permitido apenas para contas @souunit.com.br');
    }

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
    try {
      if (kIsWeb) {
        final credencial = await _auth.signInWithPopup(GoogleAuthProvider());
        return await _validarDominioGoogle(credencial);
      }

      await _inicializarGoogleSignIn();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw FirebaseAuthException(
          code: 'google-sign-in-unavailable',
          message: 'Login com Google indisponível nesta plataforma.',
        );
      }

      final contaGoogle = await _googleSignIn.authenticate();
      final idToken = contaGoogle.authentication.idToken;

      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Não foi possível obter a credencial do Google.',
        );
      }

      final credencial = GoogleAuthProvider.credential(idToken: idToken);
      final credencialUsuario = await _auth.signInWithCredential(credencial);

      return await _validarDominioGoogle(credencialUsuario);
    } on GoogleSignInException catch (e) {
      throw Exception(_mensagemErroGoogle(e));
    }
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

  Future<UserCredential> _validarDominioGoogle(
    UserCredential credencial,
  ) async {
    if (isDomainValid(credencial.user?.email)) {
      return credencial;
    }

    await _auth.signOut();

    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }

    throw Exception('Acesso permitido apenas para contas @souunit.com.br');
  }

  String _mensagemErroGoogle(GoogleSignInException erro) {
    switch (erro.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Login com Google cancelado.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Login com Google interrompido. Tente novamente.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google Sign-In não está configurado corretamente.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Não foi possível abrir a seleção de conta Google.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Credencial Google inválida para este usuário.';
      default:
        return erro.description ?? 'Erro ao entrar com Google.';
    }
  }
}
