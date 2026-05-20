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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// CABEÇALHO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          index == null ? 'Nova Nota' : 'Editar Nota',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _tituloController.clear();
                              _descricaoController.clear();
                              _tagsController.clear();
                              _dataController.clear();
                              _selectedCategorias.clear();
                              _selectedDate = null;
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    /// TÍTULO
                    const Text(
                      'Título',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Lista de Remédios',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// CONTEÚDO
                    const Text(
                      'Conteúdo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descricaoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Escreva sua anotação aqui...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    /// DATA
                    const Text(
                      'Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          modalSetState(() {
                            _selectedDate = picked;
                            _dataController.text = _formatDate(picked);
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
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
                    const SizedBox(height: 25),

                    /// CATEGORIAS
                    const Text(
                      'Categorias',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categorias.map((cat) {
                        final selecionado = _selectedCategorias.contains(cat);
                        return GestureDetector(
                          onTap: () {
                            modalSetState(() {
                              if (selecionado) {
                                _selectedCategorias.remove(cat);
                              } else {
                                _selectedCategorias.add(cat);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selecionado
                                  ? Colors.blue.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: selecionado
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selecionado
                                    ? Colors.blue
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 35),

                    /// BOTÃO SALVAR
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _salvarNota(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Salvar Nota',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF62C982),
                Color(0xFF23D7CC),
              ],
            ),
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
      floatingActionButton: Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
            onPressed: () => _mostrarFormulario(), 
            label: const Text(' Adicionar Nota', style: TextStyle(fontSize: 24) ,),
             icon: Icon(Icons.add),          
        backgroundColor: const Color.fromARGB(255, 62, 172, 111),
        foregroundColor: Colors.white,),
        
        ),

      ),
  
      bottomNavigationBar: NavBar(
        currentIndex: 2,
        onTap: (index) => navigateByIndex(context, 2, index),
      ),
    );
  }
}
