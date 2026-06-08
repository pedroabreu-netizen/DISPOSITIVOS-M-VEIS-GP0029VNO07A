import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

import 'nota.dart';
import 'navigation/nav_index.dart';
import 'page_login.dart';
import 'widgets/nav_bar.dart';

class PageNotas extends StatefulWidget {
  const PageNotas({super.key});

  @override
  State<PageNotas> createState() => _PageNotasState();
}

class _PageNotasState extends State<PageNotas> {

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

  // função auxiliar pra capturar a subcoleção do usuário logado em tempo de execução
  CollectionReference get _userNotasCollection {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'usuario_anonimo';
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('notas');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tagsController.dispose();
    _dataController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarNota(String? id) async {
    if (_tituloController.text.trim().isEmpty) return;

    final tags = _selectedCategorias.isNotEmpty
        ? _selectedCategorias.toList()
        : _tagsController.text
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList();

    final dataNota = _selectedDate != null
        ? _formatDate(_selectedDate!)
        : (_dataController.text.trim().isEmpty
              ? null
              : _dataController.text.trim());

    final novaNota = Nota(
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      tags: tags,
      data: dataNota,
      concluida: false,
    );

    if (id == null) {
      // CREATE 
      await _userNotasCollection.add(novaNota.toMap());
    } else {
      // UPDATE 
      await _userNotasCollection.doc(id).update(novaNota.toMap());
    }

    _tituloController.clear();
    _descricaoController.clear();
    _tagsController.clear();
    _dataController.clear();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluirNota(String id) async {
    // DELETE 
    await _userNotasCollection.doc(id).delete();
  }

  void _mostrarFormulario([Nota? nota]) {
    if (nota != null) {
      _tituloController.text = nota.titulo;
      _descricaoController.text = nota.descricao;
      _tagsController.text = nota.tags.join(', ');
      _selectedCategorias
        ..clear()
        ..addAll(nota.tags);
      _dataController.text = nota.data ?? '';
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
                          nota == null ? 'Nova Nota' : 'Editar Nota',
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
                        onPressed: () => _salvarNota(nota?.id),
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
    return Scaffold(
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
      body: StreamBuilder<QuerySnapshot>(
        // O Stream agora ouve dinamicamente apenas os dados do usuário autenticado
        stream: _userNotasCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar notas.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final deNoSQLParaLista = snapshot.data!.docs.map((doc) {
            return Nota.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          final exibidos = deNoSQLParaLista
              .where((n) =>
                  n.titulo.toLowerCase().contains(_filtro.toLowerCase()) ||
                  n.descricao.toLowerCase().contains(_filtro.toLowerCase()))
              .toList();

          if (exibidos.isEmpty) {
            return const Center(child: Text('Nenhuma nota cadastrada.'));
          }

          return ListView.builder(
            itemCount: exibidos.length,
            itemBuilder: (context, index) {
              final nota = exibidos[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                onPressed: () => _mostrarFormulario(nota),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color.fromARGB(255, 220, 38, 38), size: 20),
                                onPressed: () => _excluirNota(nota.id!),
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
                        style: const TextStyle(fontSize: 14, color: Color(0xFF52606D), height: 1.5),
                      ),
                      if (nota.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: nota.tags.map((tag) {
                            return Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
                              backgroundColor: const Color(0xFFE8F1FF),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            );
                          }).toList(),
                        ),
                      ],
                      if (nota.data != null && nota.data!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          nota.data!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF486581), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.only(bottom: 15),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
            onPressed: () => _mostrarFormulario(),
            label: const Text(
              ' Adicionar Nota',
              style: TextStyle(fontSize: 24),
            ),
            icon: const Icon(Icons.add),
            backgroundColor: const Color.fromARGB(255, 62, 172, 111),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 2,
        onTap: (index) => navigateByIndex(context, 2, index),
      ),
    );
  }
}