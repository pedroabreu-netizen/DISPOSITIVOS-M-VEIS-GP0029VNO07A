import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'page_login.dart';
import 'tarefa.dart';
import 'widgets/nav_bar.dart';
import 'navigation/nav_index.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Tarefa> _itens = [];

  final TextEditingController _tituloController =
      TextEditingController();

  final TextEditingController _descricaoController =
      TextEditingController();

  static const String chaveTarefas = "lista_tarefas";

  //bool _modoBusca = false;

  final TextEditingController _buscaController =
      TextEditingController();

  String _textoBusca = "";

  String _nomeUsuario = '';
  String _tipoUsuario = '';

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
    _carregarTarefas();

    _buscaController.addListener(() {
      setState(() {
        _textoBusca =
            _buscaController.text.toLowerCase();
      });
    });
  }

  String _tipoSelecionado = 'Outro';
  TimeOfDay? _horarioSelecionado;

  DateTime? _dataSelecionada;
  String _repeticaoSelecionada = 'Nunca';

  Future<void> _salvarNoStorage() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> tarefasJson = _itens.map((tarefa) {
      return jsonEncode({
        "titulo": tarefa.titulo,
        "descricao": tarefa.descricao,
        "concluida": tarefa.concluida,
        "horario": tarefa.horario,
        "tipo": tarefa.tipo,
        "data": tarefa.data,
        "repeticao": tarefa.repeticao,
      });
    }).toList();

    await prefs.setStringList(
      chaveTarefas,
      tarefasJson,
    );
  }

  Future<void> _carregarUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

        print('Documento existe: ${doc.exists}');
        print('Dados: ${doc.data()}');

    if (doc.exists) {
      setState(() {
        _nomeUsuario = doc['nome'];
        _tipoUsuario = doc['tipoUsuario'];
      });
    }
  }

  Future<void> _carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? tarefasSalvas =
        prefs.getStringList(chaveTarefas);

    if (tarefasSalvas != null) {
      setState(() {
        _itens = tarefasSalvas.map((item) {
          final dados = jsonDecode(item);

          return Tarefa(
            titulo: dados["titulo"],
            descricao: dados["descricao"],
            concluida: dados["concluida"],
            horario: dados["horario"],
            tipo: dados["tipo"],
            data: dados["data"] ?? '',
            repeticao: dados["repeticao"] ?? 'Nunca',
          );
        }).toList();
      });
    } else {
      _itens = [];

      _salvarNoStorage();
    }
  }

  void _salvarTarefa(int? index) async {
    if (_tituloController.text.isEmpty ||
        _descricaoController.text.isEmpty || 
        _tipoSelecionado.isEmpty) {
      return;
    }

    setState(() {
      if (index == null) {
        _itens.add(
          Tarefa(
            titulo: _tituloController.text,
            descricao: _descricaoController.text,
            concluida: false,
            horario: _horarioSelecionado == null
                ? '00:00'
                : _horarioSelecionado!.format(context),
            tipo: _tipoSelecionado,
            data: _dataSelecionada == null
              ? ''
              : '${_dataSelecionada!.day.toString().padLeft(2, '0')}/'
                '${_dataSelecionada!.month.toString().padLeft(2, '0')}/'
                '${_dataSelecionada!.year}',
            repeticao: _repeticaoSelecionada,
          ),
        );
      } else {
        _itens[index] = Tarefa(
          titulo: _tituloController.text,
          descricao: _descricaoController.text,
          concluida: _itens[index].concluida,
       horario: _horarioSelecionado == null
          ? _itens[index].horario
          : _horarioSelecionado!.format(context),
        tipo: _tipoSelecionado,
        data: _dataSelecionada == null
          ? _itens[index].data
          : '${_dataSelecionada!.day.toString().padLeft(2, '0')}/'
            '${_dataSelecionada!.month.toString().padLeft(2, '0')}/'
            '${_dataSelecionada!.year}',
            repeticao: _repeticaoSelecionada,
          );
      }
    });

    await _salvarNoStorage();

    _tituloController.clear();
    _descricaoController.clear();
    _horarioSelecionado = null;
    _tipoSelecionado = 'Outro';
    _repeticaoSelecionada = 'Nunca';

    Navigator.pop(context);
  }

  void _excluirTarefa(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão', 
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza que deseja excluir esta tarefa?',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
        setState(() {
          _itens.removeAt(index);
        });

        await _salvarNoStorage();
      }
    }

    void _mostrarFormulario([int? index]) {
    if (index != null) {
      _tituloController.text = _itens[index].titulo;
      _descricaoController.text =
          _itens[index].descricao;

      _tipoSelecionado = _itens[index].tipo;
    } else {
      _tituloController.clear();
      _descricaoController.clear();

      _tipoSelecionado = 'Outro';
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
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 20,
              ),

              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    /// CABEÇALHO
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nova Tarefa',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        CircleAvatar(
                          backgroundColor:
                              Colors.grey.shade200,

                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// TITULO
                    const Text(
                      'O que é?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: _tituloController,

                      decoration: InputDecoration(
                        hintText: 'Ex: Tomar remédio',

                        filled: true,
                        fillColor: Colors.grey.shade100,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// DESCRIÇÃO
                    const Text(
                      'Detalhes (opcional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: _descricaoController,
                      maxLines: 3,

                      decoration: InputDecoration(
                        hintText:
                            'Adicione informações extras aqui...',

                        filled: true,
                        fillColor: Colors.grey.shade100,

                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// DATA E HORA
                    Row(
                      children: [

                        /// DATA
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Data',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              GestureDetector(
                                onTap: () async {

                                  final data = await showDatePicker(
                                    context: context,

                                    initialDate:
                                        _dataSelecionada ?? DateTime.now(),

                                    firstDate: DateTime(2020),

                                    lastDate: DateTime(2030),
                                  );

                                  if (data != null) {
                                    modalSetState(() {
                                      _dataSelecionada = data;
                                    });
                                  }
                                },

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(15),
                                  ),

                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [

                                      Text(
                                        _dataSelecionada == null
                                            ? 'Selecionar'
                                            : '${_dataSelecionada!.day.toString().padLeft(2, '0')}/'
                                              '${_dataSelecionada!.month.toString().padLeft(2, '0')}/'
                                              '${_dataSelecionada!.year}',
                                      ),

                                      const Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 15),

                        /// HORA
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Hora',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              GestureDetector(
                                onTap: () async {

                                  final hora =
                                      await showTimePicker(
                                    context: context,
                                    initialTime:
                                        TimeOfDay.now(),
                                  );

                                  if (hora != null) {
                                    modalSetState(() {
                                      _horarioSelecionado =
                                          hora;
                                    });
                                  }
                                },

                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),

                                  decoration: BoxDecoration(
                                    color:
                                        Colors.grey.shade100,

                                    borderRadius:
                                        BorderRadius.circular(
                                            15),
                                  ),

                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,

                                    children: [
                                      Text(
                                        _horarioSelecionado ==
                                                null
                                            ? '--:--'
                                            : _horarioSelecionado!
                                                .format(
                                                    context),
                                      ),

                                      const Icon(
                                        Icons.access_time,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// REPETIÇÃO
                    const Text(
                      'Repetir?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _repeticaoSelecionada,

                          items: const [

                            DropdownMenuItem(
                              value: 'Nunca',
                              child: Text('Nunca'),
                            ),

                            DropdownMenuItem(
                              value: 'Diariamente',
                              child: Text('Diariamente'),
                            ),

                            DropdownMenuItem(
                              value: 'Semanalmente',
                              child: Text('Semanalmente'),
                            ),

                            DropdownMenuItem(
                              value: 'Mensalmente',
                              child: Text('Mensalmente'),
                            ),
                          ],

                          onChanged: (value) {
                            modalSetState(() {
                              _repeticaoSelecionada = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    /// TIPO
                    const Text(
                      'Tipo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,

                      children: [

                        _buildTipoButton(
                          'Remédio',
                          '💊',
                          modalSetState,
                        ),

                        _buildTipoButton(
                          'Médico',
                          '🩺',
                          modalSetState,
                        ),

                        _buildTipoButton(
                          'Família',
                          '❤️',
                          modalSetState,
                        ),

                        _buildTipoButton(
                          'Pessoal',
                          '😊',
                          modalSetState,
                        ),

                        _buildTipoButton(
                          'Outro',
                          '✨',
                          modalSetState,
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    /// BOTÃO SALVAR
                    SizedBox(
                      width: double.infinity,

                      height: 60,

                      child: ElevatedButton(
                        onPressed: () =>
                            _salvarTarefa(index),

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    18),
                          ),
                        ),

                        child: const Text(
                          'Salvar Tarefa',

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

  Widget _buildTipoButton(
    String tipo,
    String emoji,
    Function modalSetState,
  ) {
    final selecionado =
        _tipoSelecionado == tipo;

    return GestureDetector(
      onTap: () {
        modalSetState(() {
          _tipoSelecionado = tipo;
        });
      },

      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: selecionado
              ? Colors.blue.shade50
              : Colors.grey.shade100,

          borderRadius:
              BorderRadius.circular(15),

          border: Border.all(
            color: selecionado
                ? Colors.blue
                : Colors.grey.shade300,
          ),
        ),

        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 5),

            Text(
              tipo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String dataFormatada = DateFormat("EEEE d 'de' MMMM", 'pt_BR').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
  final hoje =
      '${DateTime.now().day.toString().padLeft(2, '0')}/'
      '${DateTime.now().month.toString().padLeft(2, '0')}/'
      '${DateTime.now().year}';

  final tarefasFiltradas = _itens.where((tarefa) {

    final mesmaData = tarefa.data == hoje;

    final mesmaBusca = tarefa.titulo
        .toLowerCase()
        .contains(_textoBusca);

    return mesmaData && mesmaBusca;

  }).toList();

  final concluidasHoje = tarefasFiltradas
    .where((tarefa) => tarefa.concluida)
    .length;

  final pendentes = tarefasFiltradas
    .where((tarefa) => !tarefa.concluida)
    .length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 220,
        flexibleSpace: Container(
          padding: EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:[
               Color(0xFF62C982),
               Color(0xFF23D7CC)
              ]
            ),

          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $_nomeUsuario',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 5),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dataFormatada,
                    style: TextStyle(color: Colors.white70),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    ),
                    child: const Icon(Icons.logout, color: Colors.white, size: 20),
                  ),
                ],
              ),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(15),
                ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('$concluidasHoje',
                        style:TextStyle(fontSize: 35, 
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        )
                      ),
                      Text('Concluídas hoje',
                          style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 15)
                        ),
                    ],
                  ),

                  Container(width: 1, height: 30, color: Colors.white),

                  Column(
                    children: [
                      Text('$pendentes',
                          style:
                              TextStyle(fontSize: 35, 
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,)
                          ),
                      Text('Pendentes',
                          style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 15)
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],      
        ),
      ),
      ),
      body: tarefasFiltradas.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma tarefa cadastrada.",
              ),
            )  
          : ListView.builder(

              itemCount: tarefasFiltradas.length,
              itemBuilder: (context, index) {
                final tarefa =
                    tarefasFiltradas[index];

                final indexOriginal =
                    _itens.indexOf(tarefa);

                SizedBox(height: 20);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        if (_tipoUsuario == 'cuidador')
                          Container(
                            margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.link, color: Colors.green),
                                const SizedBox(width: 8),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Conectado',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Vinculado a Maria',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            'Para fazer hoje',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                Card(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              value: tarefa.concluida,
                              onChanged: (value) async {
                                setState(() {
                                  _itens[indexOriginal].concluida =
                                      value ?? false;
                                });
                                await _salvarNoStorage();
                              },
                              shape: CircleBorder(),
                              activeColor: Colors.green,
                              checkColor: Colors.white, 
                            ),
                          ),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tarefa.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  tarefa.descricao,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                              size: 35,
                            ),
                            onPressed: () =>
                                _excluirTarefa(indexOriginal),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                tarefa.tipo,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey,
                                  ),

                                  const SizedBox(width: 4),

                                  Text(
                                    tarefa.horario,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                ],
              );
            },
          ),
      floatingActionButton: Container(
        padding: EdgeInsets.only(bottom: 15),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton.extended(
           onPressed: () =>
            _mostrarFormulario(),
            icon: const Icon(Icons.add),
            label: const Text(' Adicionar tarefa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color.fromARGB(255, 62, 172, 111),
            foregroundColor: Colors.white,
          ),
        ),
      ),

      /*bottomNavigationBar:
        BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, color: Colors.grey),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note, color: Colors.grey),
            label: 'Notas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner, color: Colors.grey),
            label: 'Arquivos',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const CalendarioPage(),
              ),
            );*/
          }
        },
      ),*/
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => navigateByIndex(context, 0, index),
      ),
    );
  }
}