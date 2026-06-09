import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/arquivo_medico.dart';
import 'navigation/nav_index.dart';
import 'page_login.dart';
import 'widgets/nav_bar.dart';

const _kTeal = Color(0xFF5AC87D);

class PageArquivos extends StatefulWidget {
  const PageArquivos({super.key});

  static const routeName = '/idoso/arquivos';

  @override
  State<PageArquivos> createState() => _PageArquivosState();
}

class _PageArquivosState extends State<PageArquivos> {
  // Estado local — substituir por Provider/Bloc ao integrar com backend
  final List<ArquivoMedico> _arquivos = [];
  CategoriaArquivo? _filtroAtivo;
  bool _carregando = false;

  /// Categorias que possuem pelo menos um arquivo, em ordem de definição do enum
  List<CategoriaArquivo> get _categoriasPresentes {
    final cats = <CategoriaArquivo>{};
    for (final a in _arquivos) {
      cats.add(a.categoria);
    }
    return cats.toList()..sort((a, b) => a.index.compareTo(b.index));
  }

  List<ArquivoMedico> get _arquivosFiltrados {
    if (_filtroAtivo == null) return List.unmodifiable(_arquivos);
    return _arquivos.where((a) => a.categoria == _filtroAtivo).toList();
  }

  Future<void> _escolherArquivo() async {
    setState(() => _carregando = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );
      if (!mounted || result == null || result.files.isEmpty) return;

      final f = result.files.first;

      // Verificar tamanho máximo (20 MB)
      if (f.size > 20 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arquivo excede o limite de 20 MB.')),
          );
        }
        return;
      }

      final categoria = await showModalBottomSheet<CategoriaArquivo>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const _SheetCategoria(),
      );
      if (!mounted || categoria == null) return;

      final usuarioAtual = FirebaseAuth.instance.currentUser;
      final emailUsuario = usuarioAtual?.email ?? '';

      setState(() {
        _arquivos.insert(
          0,
          ArquivoMedico(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nome: f.name,
            categoria: categoria,
            dataUpload: DateTime.now(),
            tamanhoBytes: f.size,
            extensao: (f.extension ?? 'arquivo').toLowerCase(),
            criadoPor: emailUsuario,
            caminhoLocal: f.path,
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _excluirArquivo(String id) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Excluir arquivo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza que deseja excluir este arquivo?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _arquivos.removeWhere((a) => a.id == id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 128,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            ),
          ),
        ],
        flexibleSpace: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF62C982), Color(0xFF23D7CC)],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meus Arquivos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Receitas, exames e documentos',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UploadCard(
                      carregando: _carregando,
                      onPressed: _escolherArquivo,
                    ),
                    const SizedBox(height: 16),
                    if (_arquivos.isNotEmpty) ...[
                      _FiltroBar(
                        categorias: _categoriasPresentes,
                        filtroAtivo: _filtroAtivo,
                        onChanged: (f) => setState(() => _filtroAtivo = f),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_arquivos.isEmpty)
                      const _EstadoVazio()
                    else if (_arquivosFiltrados.isEmpty)
                      _EstadoVazioFiltro(
                        onLimpar: () => setState(() => _filtroAtivo = null),
                      )
                    else
                      ..._arquivosFiltrados.map(
                        (a) => _ArquivoCard(
                          arquivo: a,
                          onExcluir: () => _excluirArquivo(a.id),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 3,
        onTap: (index) => navigateByIndex(context, 3, index),
      ),
    );
  }
}

// ── Card de envio ─────────────────────────────────────────────────────────────

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.carregando, required this.onPressed});

  final bool carregando;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          children: [
            const Text(
              'Enviar arquivo',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Receitas, exames, documentos...',
              style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kTeal.withValues(alpha: 0.5),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Escolher arquivo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Máximo: 20 MB',
              style: TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chips de filtro ───────────────────────────────────────────────────────────

class _FiltroBar extends StatelessWidget {
  const _FiltroBar({
    required this.categorias,
    required this.filtroAtivo,
    required this.onChanged,
  });

  final List<CategoriaArquivo> categorias;
  final CategoriaArquivo? filtroAtivo;
  final ValueChanged<CategoriaArquivo?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'Todos',
            selected: filtroAtivo == null,
            onTap: () => onChanged(null),
          ),
          ...categorias.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: cat.chipLabel,
                selected: filtroAtivo == cat,
                onTap: () => onChanged(filtroAtivo == cat ? null : cat),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _kTeal : const Color(0xFFBDBDBD),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF757575),
          ),
        ),
      ),
    );
  }
}

// ── Card de arquivo ───────────────────────────────────────────────────────────

class _ArquivoCard extends StatelessWidget {
  const _ArquivoCard({required this.arquivo, required this.onExcluir});

  final ArquivoMedico arquivo;
  final VoidCallback onExcluir;

  static const Map<CategoriaArquivo, ({Color bg, Color text})> _badgeColors = {
    CategoriaArquivo.exame: (bg: Color(0xFFE3F2FD), text: Color(0xFF1976D2)),
    CategoriaArquivo.prescricao: (
      bg: Color(0xFFF3E5F5),
      text: Color(0xFF7B1FA2),
    ),
    CategoriaArquivo.laudo: (bg: Color(0xFFE8F5E9), text: Color(0xFF2E7D32)),
    CategoriaArquivo.receita: (bg: Color(0xFFFFF8E1), text: Color(0xFFF57F17)),
    CategoriaArquivo.outros: (bg: Color(0xFFF5F5F5), text: Color(0xFF616161)),
  };

  static const _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  String _formatarData(DateTime data) =>
      '${data.day} de ${_meses[data.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final badge =
        _badgeColors[arquivo.categoria] ??
        (bg: const Color(0xFFF5F5F5), text: const Color(0xFF616161));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.insert_drive_file_outlined,
                size: 38,
                color: Color(0xFF90A4AE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arquivo.nome,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    arquivo.tamanhoFormatado,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: badge.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          arquivo.categoria.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: badge.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatarData(arquivo.dataUpload),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onExcluir,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE53935),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Estados vazios ────────────────────────────────────────────────────────────

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: Color(0xFFBDBDBD)),
            SizedBox(height: 16),
            Text(
              'Nenhum arquivo enviado',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Envie seus exames e documentos\nutilizando o botão acima.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFBDBDBD),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVazioFiltro extends StatelessWidget {
  const _EstadoVazioFiltro({required this.onLimpar});
  final VoidCallback onLimpar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.filter_list_off_rounded,
              size: 48,
              color: Color(0xFFBDBDBD),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nenhum arquivo nesta categoria',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onLimpar,
              style: TextButton.styleFrom(foregroundColor: _kTeal),
              child: const Text('Ver todos os arquivos'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet: seleção de categoria ───────────────────────────────────────

class _SheetCategoria extends StatelessWidget {
  const _SheetCategoria();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Qual o tipo do arquivo?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            ...CategoriaArquivo.values.map(
              (cat) => ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cat.icon, color: _kTeal),
                ),
                title: Text(
                  cat.label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => Navigator.pop(context, cat),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
