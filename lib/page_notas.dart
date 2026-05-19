import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nota.dart';
import 'navigation/nav_index.dart';
import 'widgets/nav_bar.dart';

class PageNotas extends StatefulWidget {
  const PageNotas({super.key});

  @override
  State<PageNotas> createState() => _PageNotasState();
}

class _PageNotasState extends State<PageNotas> {
  static const String _storageKey = 'notas';

  final List<Nota> _itens = [
    Nota(
      titulo: 'Lista de remédios',
      descricao:
          'Losartana 50mg - manhã\nAtorvastatina 20mg - noite\nMetformina 500mg - almoço',
      concluida: false,
      tags: ['Remédios', 'Saúde'],
      data: '18 de Março',
    ),
    Nota(
      titulo: 'Telefones importantes',
      descricao:
          'Fiha Ana: (11) 9 9999-1111\nDr. Silva: (11) 333-2222\nUPA: (11) 192',
      concluida: false,
      tags: ['Médico', 'Saúde'],
      data: '18 de Março',
    ),
  ];

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  String _filtro = '';
  final List<String> _categorias = [
    'Remédios',
    'Trabalho',
    'Pessoal',
    'Saúde',
    'Compras',
    'Estudos',
    'Financeiro',
  ];
  final Set<String> _selectedCategorias = <String>{};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  @override
  void dispose() {
    _tagsController.dispose();
    _dataController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    final notasSalvas = prefs.getStringList(_storageKey);

    if (notasSalvas != null && notasSalvas.isNotEmpty) {
      final notas = notasSalvas.map((item) {
        final dados = jsonDecode(item);
        return Nota(
          titulo: dados['titulo'],
          descricao: dados['descricao'],
          concluida: dados['concluida'],
          tags: List<String>.from(dados['tags'] ?? []),
          data: dados['data'],
        );
      }).toList();
      if (!mounted) return;
      setState(() {
        _itens
          ..clear()
          ..addAll(notas);
      });
    }
  }

  Future<void> _salvarNoStorage() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> notasJson = _itens.map((nota) {
      return jsonEncode({
        'titulo': nota.titulo,
        'descricao': nota.descricao,
        'concluida': nota.concluida,
        'tags': nota.tags,
        'data': nota.data,
      });
    }).toList();

    await prefs.setStringList(_storageKey, notasJson);
  }

  void _salvarNota(int? index) {
    if (_tituloController.text.trim().isEmpty) return;

    setState(() {
      final tags = _selectedCategorias.isNotEmpty
          ? _selectedCategorias.toList()
          : _tagsController.text
                .split(',')
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList();
      if (index == null) {
        _itens.add(
          Nota(
            titulo: _tituloController.text.trim(),
            descricao: _descricaoController.text.trim(),
            concluida: false,
            tags: tags,
            data: _selectedDate != null
                ? _formatDate(_selectedDate!)
                : (_dataController.text.trim().isEmpty
                      ? null
                      : _dataController.text.trim()),
          ),
        );
      } else {
        _itens[index].titulo = _tituloController.text.trim();
        _itens[index].descricao = _descricaoController.text.trim();
        _itens[index].tags = tags;
        _itens[index].data = _selectedDate != null
            ? _formatDate(_selectedDate!)
            : (_dataController.text.trim().isEmpty
                  ? null
                  : _dataController.text.trim());
      }
    });

    _salvarNoStorage();
    _tituloController.clear();
    _descricaoController.clear();
    _tagsController.clear();
    _dataController.clear();
    Navigator.pop(context);
  }

  void _excluirNota(int index) {
    setState(() {
      _itens.removeAt(index);
    });
    _salvarNoStorage();
  }

  void _mostrarFormulario([int? index]) {
    if (index != null) {
      _tituloController.text = _itens[index].titulo;
      _descricaoController.text = _itens[index].descricao;
      _tagsController.text = _itens[index].tags.join(', ');
      _selectedCategorias
        ..clear()
        ..addAll(_itens[index].tags);
      _dataController.text = _itens[index].data ?? '';
      _selectedDate = null;
    } else {
      _tituloController.clear();
      _descricaoController.clear();
      _tagsController.clear();
      _dataController.clear();
      _selectedCategorias.clear();
      _selectedDate = null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(index == null ? 'Nova Nota' : 'Editar Nota'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Título da nota'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Descrição'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categorias',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _categorias.map((cat) {
                    final selected = _selectedCategorias.contains(cat);
                    return FilterChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedCategorias.add(cat);
                          } else {
                            _selectedCategorias.remove(cat);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _dataController.text = _formatDate(picked);
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dataController.text.isEmpty
                              ? 'Selecionar data'
                              : _dataController.text,
                          style: TextStyle(
                            color: _dataController.text.isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _tituloController.clear();
                _descricaoController.clear();
                _tagsController.clear();
                _dataController.clear();
                _selectedCategorias.clear();
                _selectedDate = null;
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _salvarNota(index),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    final exibidos = _itens
        .where(
          (n) =>
              n.titulo.toLowerCase().contains(_filtro.toLowerCase()) ||
              n.descricao.toLowerCase().contains(_filtro.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 128,
        flexibleSpace: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 75, 202, 132),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Minhas Notas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Suas anotações importantes',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: exibidos.isEmpty
                ? const Center(child: Text('Nenhuma nota cadastrada.'))
                : ListView.builder(
                    itemCount: exibidos.length,
                    itemBuilder: (context, index) {
                      final nota = exibidos[index];
                      final indexOriginal = _itens.indexOf(nota);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      nota.titulo,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF102A43),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _mostrarFormulario(indexOriginal),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Color.fromARGB(
                                            255,
                                            220,
                                            38,
                                            38,
                                          ),
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _excluirNota(indexOriginal),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                nota.descricao,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF52606D),
                                  height: 1.5,
                                ),
                              ),
                              if (nota.tags.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: nota.tags.map((tag) {
                                    return Chip(
                                      label: Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFFE8F1FF),
                                      side: BorderSide.none,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 0,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                              if (nota.data != null &&
                                  nota.data!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  nota.data!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF486581),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color.fromARGB(255, 62, 172, 111),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar nota'),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 2,
        onTap: (index) => navigateByIndex(context, 2, index),
      ),
    );
  }
}
