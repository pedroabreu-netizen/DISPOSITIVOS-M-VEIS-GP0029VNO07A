import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'page_cadastro.dart';
import 'page_home.dart';
import 'page_esqueci_senha.dart';
import 'services/auth_service.dart';
import 'utils/app_colors.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/entrar_com_google_button.dart';

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 390;
              final isShort = constraints.maxHeight < 720;
              final pagePadding = EdgeInsets.symmetric(
                horizontal: isCompact ? 12 : 16,
                vertical: isShort ? 14 : 20,
              );
              final cardPadding = EdgeInsets.fromLTRB(
                isCompact ? 18 : 22,
                isShort ? 28 : 36,
                isCompact ? 18 : 22,
                isShort ? 26 : 34,
              );

              return Center(
                child: SingleChildScrollView(
                  padding: pagePadding,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Container(
                      padding: cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: AppColors.title,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Não tem uma conta? ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CadastroPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Clique para cadastrar nova conta',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.link,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isShort ? 28 : 34),
                          _label('Email'),
                          const SizedBox(height: 10),
                          _loginTextField(
                            controller: emailController,
                            hintText: 'Digite seu email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: isShort ? 18 : 22),
                          _label('Senha'),
                          const SizedBox(height: 10),
                          _loginTextField(
                            controller: senhaController,
                            hintText: 'Digite sua senha',
                            obscureText: esconderSenha,
                            suffixIcon: IconButton(
                              iconSize: 30,
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
                          const SizedBox(height: 18),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
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
                          SizedBox(height: isShort ? 24 : 30),
                          SizedBox(
                            width: double.infinity,
                            height: 66,
                            child: ElevatedButton(
                              onPressed: () {
                                _autenticar(() async {
                                  await AuthService().entrar(
                                    email: emailController.text.trim(),
                                    senha: senhaController.text.trim(),
                                  );
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonBackground,
                                foregroundColor: AppColors.buttonText,
                                shadowColor: AppColors.buttonBackground
                                    .withValues(alpha: 0.28),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 31,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.buttonText,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isShort ? 26 : 32),
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
                                    fontSize: 22,
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
                          SizedBox(height: isShort ? 26 : 32),
                          EntrarComGoogleButton(
                            onPressed: () {
                              _autenticar(() async {
                                await AuthService().entrarComGoogle();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _autenticar(Future<void> Function() login) async {
    try {
      await login();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      _mostrarErro(_mensagemErro(e));
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  String _mensagemErro(Object erro) {
    if (erro is FirebaseAuthException) {
      return erro.message ?? 'Erro ao fazer login.';
    }

    return erro.toString().replaceFirst('Exception: ', '');
  }

  Widget _loginTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      obscureText: obscureText,
      keyboardType: keyboardType,
      suffixIcon: suffixIcon,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.fieldText,
      ),
      hintStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.secondaryText,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
