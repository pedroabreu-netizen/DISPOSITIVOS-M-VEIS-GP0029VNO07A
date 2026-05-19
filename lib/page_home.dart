import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'page_login.dart';
//import 'page_perfil.dart';
import 'tarefa.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Tarefa> _itens = [
   /* Tarefa(
      titulo: 'Tomar remédio para pressão',
      descricao: '1 comprimido após café da manhã',
      concluida: false,
      horario: '10:00',
      tipo: 'Remédio',
    ),
    Tarefa(
      titulo: 'Consulta ocm Dr. Silva',
      descricao: 'Rua das flores, 123 - clinica São José',
      concluida: false,
      horario: '11:00',
      tipo: 'Médico',
    ),
    Tarefa(
      titulo: 'Projeto',
      descricao: 'Projeto Integrador',
      concluida: false,
      horario: '12:00',
      tipo: 'Familia',
    ),*/
  ];

  final TextEditingController _tituloController =
      TextEditingController();

  final TextEditingController _descricaoController =
      TextEditingController();

  static const String chaveTarefas = "lista_tarefas";

  //bool _modoBusca = false;

  final TextEditingController _buscaController =
      TextEditingController();

  String _textoBusca = "";

  @override
  void initState() {
    super.initState();

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

  Future<void> _salvarNoStorage() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> tarefasJson = _itens.map((tarefa) {
      return jsonEncode({
        "titulo": tarefa.titulo,
        "descricao": tarefa.descricao,
        "concluida": tarefa.concluida,
        "horario": tarefa.horario,
        "tipo": tarefa.tipo,
      });
    }).toList();

    await prefs.setStringList(
      chaveTarefas,
      tarefasJson,
    );
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
        );
      }
    });

    await _salvarNoStorage();

    _tituloController.clear();
    _descricaoController.clear();
    _horarioSelecionado = null;
    _tipoSelecionado = 'Outro';

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
            onPressed: () =>
                Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              textStyle: const TextStyle(
                color: Colors.white,
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
      _descricaoController.text =_itens[index].descricao;
      _horarioSelecionado = TimeOfDay(
        hour: int.parse(_itens[index].horario.split(':')[0]),
        minute: int.parse(_itens[index].horario.split(':')[1]),
      );
      _tipoSelecionado = _itens[index].tipo;
    } else {
      _tituloController.clear();
      _descricaoController.clear();
      _horarioSelecionado = null;
      _tipoSelecionado = 'Outro';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25),
      ),
    ),

      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nova Tarefa",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'O que é?',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Detalhes (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              DropdownButton<String>(
                value: _tipoSelecionado,
                onChanged: (value) {
                  setState(() {
                    _tipoSelecionado = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: "Remédio", child: Text("Remédio")),
                  DropdownMenuItem(value: "Médico", child: Text("Médico")),
                  DropdownMenuItem(value: "Família", child: Text("Família")),
                  DropdownMenuItem(value: "Pessoal", child: Text("Pessoal")),
                  DropdownMenuItem(value: "Outro", child: Text("Outro")),
                ],
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: () async {
                  final hora = await showTimePicker(
                    context: context,
                    initialTime:
                        _horarioSelecionado ??
                        TimeOfDay.now(),
                  );

                  if (hora != null) {
                    setState(() {
                      _horarioSelecionado = hora;
                    });
                  }
                },
                icon: const Icon(Icons.access_time),
                label: Text(
                  _horarioSelecionado == null
                      ? 'Selecionar horário'
                      : _horarioSelecionado!
                          .format(context),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () => _salvarTarefa(index),
                child: const Text("Salvar Tarefa"),
              ),
            ],
          ),
        )
        );
      },
    );
  }

  String dataFormatada = DateFormat("EEEE d 'de' MMMM", 'pt_BR').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final tarefasFiltradas = _itens.where((tarefa) {
      return tarefa.titulo
          .toLowerCase()
          .contains(_textoBusca);
    }).toList();

    final concluidasHoje = tarefasFiltradas
    .where((tarefa) => tarefa.concluida)
    .length;

    final pendentes = tarefasFiltradas
        .where((tarefa) => !tarefa.concluida)
        .length;

    return Scaffold(
      appBar: AppBar(
        /*title: _modoBusca
            ? TextField(
                controller: _buscaController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar tarefa...',
                  border: InputBorder.none,
                ),
              )
            : const Text('Home'),*/
        /*actions: [
          IconButton(
            icon: Icon(
              _modoBusca
                  ? Icons.close
                  : Icons.search,
            ),
            onPressed: () {
              setState(() {
                if (_modoBusca) {
                  _modoBusca = false;
                  _buscaController.clear();
                  _textoBusca = "";
                } else {
                  _modoBusca = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair do Sistema',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const LoginPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],*/

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
                'Olá, Maria',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 5),

              Text(
                dataFormatada,
                style: TextStyle(color: Colors.white70),
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
      /*drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration:
                  BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Meu Perfil'),
              /*onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PerfilPage(),
                ),
              ),*/
            ),
          ],
        ),
      ),*/
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child: Text(
                        'Para fazer hoje',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
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
        padding: EdgeInsets.only(bottom: 10),
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

      bottomNavigationBar:
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
      ),
    );
  }
}