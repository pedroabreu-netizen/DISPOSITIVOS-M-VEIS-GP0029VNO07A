import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
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
    Tarefa(
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
    ),
  ];

  final TextEditingController _tituloController =
      TextEditingController();

  final TextEditingController _descricaoController =
      TextEditingController();

  static const String chaveTarefas = "lista_tarefas";

  bool _modoBusca = false;

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
      _itens = [
        Tarefa(
          titulo: 'Flutter',
          descricao: 'Tarefa de Flutter',
          concluida: false,
          horario: '10:00',
          tipo: 'Médico',
        ),
        Tarefa(
          titulo: 'Dart',
          descricao: 'Prática de Dart',
          concluida: false,
          horario: '11:00',
          tipo: 'Remédio',  
        ),
        Tarefa(
          titulo: 'Projeto',
          descricao: 'Projeto Integrador',
          concluida: false,
          horario: '12:00',
          tipo: 'Familia',
        ),
      ];

      _salvarNoStorage();
    }
  }

  void _salvarTarefa(int? index) async {
    if (_tituloController.text.isEmpty ||
        _descricaoController.text.isEmpty) {
      return;
    }

    setState(() {
      if (index == null) {
        _itens.add(
          Tarefa(
            titulo: _tituloController.text,
            descricao: _descricaoController.text,
            concluida: false,
            horario: '00:00',
  
            tipo: 'Outro',
          ),
        );
      } else {
        _itens[index] = Tarefa(
          titulo: _tituloController.text,
          descricao: _descricaoController.text,
          concluida: _itens[index].concluida,
          horario: _itens[index].horario,
          tipo: _itens[index].tipo,
        );
      }
    });

    await _salvarNoStorage();

    _tituloController.clear();
    _descricaoController.clear();

    Navigator.pop(context);
  }

  void _excluirTarefa(int index) async {
    setState(() {
      _itens.removeAt(index);
    });

    await _salvarNoStorage();
  }

  void _mostrarFormulario([int? index]) {
    if (index != null) {
      _tituloController.text = _itens[index].titulo;
      _descricaoController.text =
          _itens[index].descricao;
    } else {
      _tituloController.clear();
      _descricaoController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          index == null
              ? 'Nova Tarefa'
              : 'Editar Tarefa',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () =>
                _salvarTarefa(index),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tarefasFiltradas = _itens.where((tarefa) {
      return tarefa.titulo
          .toLowerCase()
          .contains(_textoBusca);
    }).toList();

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
            color: Color.fromARGB(255, 74, 212, 136),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
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
                'Quarta-feira, 18 de Março',
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
                      Text('0',
                        style:TextStyle(fontSize: 30, 
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        )
                      ),
                      Text('Concluídas hoje',
                          style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold,)
                        ),
                    ],
                  ),

                  Container(width: 1, height: 30, color: Colors.white),

                  Column(
                    children: [
                      Text('4',
                          style:
                              TextStyle(fontSize: 30, 
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,)
                          ),
                      Text('Pendentes',
                          style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold,)
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

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Para fazer hoje',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                );

                return Card(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      tarefa.titulo,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle:
                        Text(tarefa.descricao),
                    trailing: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: tarefa.concluida,
                          onChanged:
                              (value) async {
                            setState(() {
                              _itens[indexOriginal]
                                      .concluida =
                                  value ??
                                      false;
                            });

                            await _salvarNoStorage();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () =>
                              _mostrarFormulario(
                            indexOriginal,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 131, 129, 129),
                          ),
                          onPressed: () =>
                              _excluirTarefa(
                            indexOriginal,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              style: TextStyle(fontSize: 24),
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