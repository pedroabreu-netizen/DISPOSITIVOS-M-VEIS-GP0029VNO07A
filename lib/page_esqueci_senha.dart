import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Cores do design system extraídas do Figma
  static const Color _gradientStart = Color(0xFF59C87D);
  static const Color _gradientEnd = Color(0xFF1CE6D8);
  static const Color _primaryGreen = Color(0xFF59C87D);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF8A8A9A);
  static const Color _cardBg = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSendEmail() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, insira um e-mail válido.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      setState(() {
        _emailSent = true;
      });

      _animationController.reset();
      _animationController.forward();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Erro ao enviar e-mail.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_gradientStart, _gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: _emailSent
                          ? _buildSuccessCard()
                          : _buildFormCard(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ícone ilustrativo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_gradientStart, _gradientEnd],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 24),

          // Título
          const Text(
            'Esqueceu a senha?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Subtítulo
          Text(
            'Informe seu e-mail cadastrado para redefinir sua senha.',
            style: TextStyle(fontSize: 14, color: _textMuted, height: 1.55),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Campo de e-mail
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'E-mail',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textDark.withOpacity(0.75),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildEmailField(),
          const SizedBox(height: 28),

          // Botão principal
          _buildSendButton(),
          const SizedBox(height: 20),

          // Link voltar ao login
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: RichText(
              text: TextSpan(
                text: 'Lembrou a senha? ',
                style: TextStyle(fontSize: 14, color: _textMuted),
                children: const [
                  TextSpan(
                    text: 'Fazer login',
                    style: TextStyle(
                      color: _primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
        fontSize: 15,
        color: _textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'seuemail@exemplo.com',
        hintStyle: TextStyle(
          color: _textMuted.withOpacity(0.7),
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryGreen, width: 1.8),
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: _textMuted.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_gradientStart, _gradientEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryGreen.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSendEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Enviar instruções',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ícone de sucesso
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_gradientStart, _gradientEnd],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'E-mail enviado!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: _textMuted, height: 1.6),
              children: [
                const TextSpan(text: 'Enviamos as instruções para '),
                TextSpan(
                  text: _emailController.text,
                  style: const TextStyle(
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text: '. Verifique sua caixa de entrada e a pasta de spam.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Botão voltar ao login
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_gradientStart, _gradientEnd],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Voltar ao login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Reenviar e-mail
          GestureDetector(
            onTap: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: _emailController.text.trim(),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('E-mail reenviado com sucesso!'),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? 'Erro ao reenviar e-mail'),
                  ),
                );
              }
            },
            child: Text(
              'Não recebeu? Reenviar e-mail',
              style: TextStyle(
                fontSize: 14,
                color: _primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
