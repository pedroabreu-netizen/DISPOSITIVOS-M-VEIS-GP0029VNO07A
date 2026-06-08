import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services/vinculo_service.dart';
import 'utils/app_colors.dart';
import 'widgets/custom_text_field.dart';

class PageVinculo extends StatefulWidget {
  const PageVinculo({required this.tipoUsuario, super.key});

  final String tipoUsuario;

  @override
  State<PageVinculo> createState() => _PageVinculoState();
}

class _PageVinculoState extends State<PageVinculo> {
  final VinculoService _vinculoService = VinculoService();
  final TextEditingController _codigoController = TextEditingController();

  bool _carregando = true;
  bool _processando = false;
  String? _codigoGerado;
  String? _nomeVinculado;

  @override
  void initState() {
    super.initState();
    _carregarVinculo();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _carregarVinculo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final vinculado = await _vinculoService.buscarUsuarioVinculado(
      uid,
      widget.tipoUsuario,
    );

    if (!mounted) return;

    setState(() {
      _nomeVinculado = vinculado?['nome'] as String?;
      _carregando = false;
    });
  }

  Future<void> _gerarCodigo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _processando = true);

    try {
      final codigo = await _vinculoService.gerarCodigo(uid);
      if (!mounted) return;
      setState(() => _codigoGerado = codigo);
    } catch (e) {
      _mostrarMensagem(_mensagemErro(e));
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _vincular() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      _mostrarMensagem('Informe o código fornecido pelo idoso.');
      return;
    }

    setState(() => _processando = true);

    try {
      await _vinculoService.vincularComCodigo(cuidadorUid: uid, codigo: codigo);
      if (!mounted) return;
      _mostrarMensagem('Vínculo realizado com sucesso!');
      await _carregarVinculo();
    } catch (e) {
      _mostrarMensagem(_mensagemErro(e));
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  String _mensagemErro(Object erro) {
    return erro.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vínculo')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: _nomeVinculado != null
                  ? _buildVinculoAtivo()
                  : (widget.tipoUsuario == 'idoso'
                        ? _buildGeradorDeCodigo()
                        : _buildEntradaDeCodigo()),
            ),
    );
  }

  Widget _buildVinculoAtivo() {
    final outroTipo = widget.tipoUsuario == 'idoso' ? 'cuidador' : 'idoso';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.link, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conectado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Vinculado ao $outroTipo $_nomeVinculado'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeradorDeCodigo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gere um código e compartilhe com seu cuidador para concluir o vínculo.',
          style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 24),
        if (_codigoGerado != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Column(
              children: [
                Text(
                  _codigoGerado!,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Este código expira em 10 minutos.',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _processando ? null : _gerarCodigo,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBackground,
            foregroundColor: AppColors.buttonText,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size.fromHeight(50),
          ),
          child: _processando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_codigoGerado == null ? 'Gerar código' : 'Gerar novo código'),
        ),
      ],
    );
  }

  Widget _buildEntradaDeCodigo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Peça ao idoso o código de vínculo gerado no app dele e digite abaixo.',
          style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          hintText: 'Código de vínculo',
          controller: _codigoController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _processando ? null : _vincular,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBackground,
            foregroundColor: AppColors.buttonText,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size.fromHeight(50),
          ),
          child: _processando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Vincular'),
        ),
      ],
    );
  }
}
