import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'utils/app_colors.dart';
import 'utils/phone_input_formatter.dart';
import 'widgets/custom_text_field.dart';
import '../services/auth_service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  PhoneCountry _selectedPhoneCountry = phoneCountries.first;
  bool esconderSenha = true;
  String _tipoUsuario = 'idoso';

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _dataController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.title,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Cadastro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Já tem uma conta? ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).maybePop();
                          },
                          child: const Text(
                            'Entre aqui',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.link,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _label('Nome Completo'),
                    const SizedBox(height: 8),
                    _cadastroTextField(
                      controller: _nomeController,
                      hintText: 'Digite seu nome completo',
                    ),
                    const SizedBox(height: 18),
                    _label('Email'),
                    const SizedBox(height: 8),
                    _cadastroTextField(
                      controller: _emailController,
                      hintText: 'Digite seu email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    _label('Data de nascimento'),
                    const SizedBox(height: 8),
                    _cadastroTextField(
                      controller: _dataController,
                      hintText: 'DD/MM/AAAA',
                      keyboardType: TextInputType.datetime,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.mutedIcon,
                        ),
                        onPressed: () async {
                          final data = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (data != null) {
                            _dataController.text =
                                '${data.day.toString().padLeft(2, '0')}/'
                                '${data.month.toString().padLeft(2, '0')}/'
                                '${data.year}';
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    _label('Número de telefone'),
                    const SizedBox(height: 8),
                    _cadastroTextField(
                      controller: _telefoneController,
                      hintText: _selectedPhoneCountry.hint,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        PhoneInputFormatter(_selectedPhoneCountry),
                      ],
                      prefixIcon: _phonePrefix(),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 104,
                        minHeight: 48,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _label('Tipo de usuário'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tipoUsuario = 'idoso'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _tipoUsuario == 'idoso'
                                    ? AppColors.buttonBackground
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _tipoUsuario == 'idoso'
                                      ? AppColors.buttonBackground
                                      : AppColors.fieldBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.elderly,
                                    color: _tipoUsuario == 'idoso'
                                        ? Colors.white
                                        : AppColors.mutedIcon,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Idoso / Paciente',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _tipoUsuario == 'idoso'
                                          ? Colors.white
                                          : AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _tipoUsuario = 'cuidador'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _tipoUsuario == 'cuidador'
                                    ? AppColors.buttonBackground
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _tipoUsuario == 'cuidador'
                                      ? AppColors.buttonBackground
                                      : AppColors.fieldBorder,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.health_and_safety,
                                    color: _tipoUsuario == 'cuidador'
                                        ? Colors.white
                                        : AppColors.mutedIcon,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cuidador',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _tipoUsuario == 'cuidador'
                                          ? Colors.white
                                          : AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _label('Escolha uma senha'),
                    const SizedBox(height: 8),
                    _cadastroTextField(
                      controller: _senhaController,
                      hintText: 'Digite sua senha',
                      obscureText: esconderSenha,
                      suffixIcon: IconButton(
                        icon: Icon(
                          esconderSenha
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.mutedIcon,
                        ),
                        onPressed: () {
                          setState(() {
                            esconderSenha = !esconderSenha;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                        try {
                          final credencial = await AuthService().cadastrar(
                            email: _emailController.text.trim(),
                            senha: _senhaController.text.trim(),
                          );

                          await FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(credencial.user!.uid)
                              .set({
                                'nome': _nomeController.text.trim(),
                                'email': _emailController.text.trim(),
                                'telefone': _telefoneController.text.trim(),
                                'dataNascimento': _dataController.text.trim(),
                                'tipoUsuario': _tipoUsuario,
                              });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Cadastro realizado com sucesso!',
                              ),
                            ),
                          );

                          Navigator.of(context).maybePop();
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.message ?? 'Erro ao cadastrar usuário',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                              color: AppColors.buttonBorder,
                              width: 2,
                            ),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: AppColors.buttonText,
                          ),
                        ),
                      ),
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

  Widget _cadastroTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    BoxConstraints? prefixIconConstraints,
    Widget? suffixIcon,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixIconConstraints,
      suffixIcon: suffixIcon,
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.fieldText,
      ),
      hintStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.secondaryText,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _phonePrefix() {
    return PopupMenuButton<PhoneCountry>(
      tooltip: 'Selecionar país',
      initialValue: _selectedPhoneCountry,
      onSelected: (country) {
        setState(() {
          _selectedPhoneCountry = country;
          _telefoneController.clear();
        });
      },
      itemBuilder: (context) {
        return phoneCountries.map((country) {
          return PopupMenuItem(
            value: country,
            child: Text(
              '${country.symbol} ${country.name} ${country.dialCode}',
            ),
          );
        }).toList();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedPhoneCountry.symbol,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              _selectedPhoneCountry.dialCode,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.fieldText,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.title,
            ),
            const SizedBox(width: 8),
            const SizedBox(
              height: 22,
              child: VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.fieldBorder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
