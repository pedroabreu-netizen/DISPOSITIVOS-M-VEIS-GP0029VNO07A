import 'package:flutter/material.dart';

import 'page_cadastro.dart';
import 'page_home.dart';
import 'utils/app_colors.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/social_login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool esconderSenha = true;

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
                    const CustomTextField(hintText: 'Digite seu email'),
                    const SizedBox(height: 28),
                    _label('Senha'),
                    const SizedBox(height: 8),
                    CustomTextField(
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
                        debugPrint('Esqueceu a senha');
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
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
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
                    SocialLoginButton(
                      onPressed: () {
                        debugPrint('Continuar com Google');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
