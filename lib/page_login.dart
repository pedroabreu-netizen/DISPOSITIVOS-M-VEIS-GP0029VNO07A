import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'page_cadastro.dart';
import 'page_home.dart';
import 'page_esqueci_senha.dart';
import 'services/auth_service.dart';
import 'utils/app_colors.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/social_login_button.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool esconderSenha = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 42, 28, 36),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Não tem uma conta?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CadastroPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Clique para cadastrar nova conta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.link,
                        ),
                      ),
                    ),
                    const SizedBox(height: 46),
                    _label('Email'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Digite seu email',
                    ),
                    const SizedBox(height: 28),
                    _label('Senha'),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: senhaController,
                      hintText: '*******',
                      obscureText: esconderSenha,
                      suffixIcon: IconButton(
                        icon: Icon(
                          esconderSenha
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.mutedIcon,
                        ),
                        onPressed: () {
                          setState(() {
                            esconderSenha = !esconderSenha;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 26),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.link,
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: senhaController.text.trim(),
                                );

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.message ?? 'Erro ao fazer login',
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBackground,
                          foregroundColor: AppColors.buttonText,
                          shadowColor: AppColors.buttonBackground.withValues(
                            alpha: 0.35,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.buttonText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(
                            color: AppColors.fieldBorder,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Text(
                            'Ou',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.fieldBorder,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    SocialLoginButton(onPressed: _entrarComGoogle),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _entrarComGoogle() async {
    try {
      await AuthService().entrarComGoogle();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on GoogleSignInException catch (e) {
      _mostrarErro(_mensagemErroGoogle(e));
    } on FirebaseAuthException catch (e) {
      _mostrarErro(_mensagemErroFirebase(e));
    } on PlatformException catch (e) {
      _mostrarErro(_mensagemErroPlataforma(e));
    } catch (_) {
      _mostrarErro(
        'Não foi possível entrar com Google. Verifique sua conexão e tente novamente.',
      );
    }
  }

  String _mensagemErroGoogle(GoogleSignInException e) {
    switch (e.code) {
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
        return e.description ?? 'Erro ao entrar com Google.';
    }
  }

  String _mensagemErroFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet e tente novamente.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Credencial inválida.';
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com esse e-mail usando outro método de login.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Login com Google cancelado.';
      default:
        return e.message ?? 'Erro ao entrar com Google.';
    }
  }

  String _mensagemErroPlataforma(PlatformException e) {
    final codigo = e.code.toLowerCase();

    if (codigo.contains('network')) {
      return 'Falha de conexão. Verifique sua internet e tente novamente.';
    }

    if (codigo.contains('canceled') || codigo.contains('cancelled')) {
      return 'Login com Google cancelado.';
    }

    return e.message ?? 'Erro ao entrar com Google.';
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Widget _label(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 18,
          color: AppColors.secondaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
