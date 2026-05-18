import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'navigation/nav_index.dart';
import 'objAux/tarefa.dart';
import 'widgets/nav_bar.dart';

class PageAgenda extends StatefulWidget {
  const PageAgenda({super.key});

  @override
  State<PageAgenda> createState() => _PageAgendaState();
}

class _PageAgendaState extends State<PageAgenda> {
  static const String _storageKey = 'agenda';

  final List<Tarefa> _itens = [
    Tarefa(
      titulo: 'Tomar remédio para pressão',
      descricao: '1 comprimido após café da manhã',
      concluida: false,
      horario: '10:00',
      tipo: 'Remédio',
    ),
  ];

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  static const String chaveTarefas = 'lista_ tarefas';

  bool _modoBusca = false;

  final TextEditingController _buscaController = TextEditingController();

  String _textoBusca = '';

  DateTime _diaSelecionado = DateTime.now();

  DateTime _diaFocado = DateTime.now();

  @override
  void initState() {
    super.initState();

    _carregarTarefas();

    _buscaController.addListener(() {
      setState(() {
        _textoBusca = _buscaController.text.toLowerCase();
      });
    });
  }

  Future<void> _carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final tarefasSalvas = prefs.getStringList(_storageKey);

    if (tarefasSalvas != null && tarefasSalvas.isNotEmpty) {
      final tarefas = tarefasSalvas.map((item) {
        final dados = jsonDecode(item);
        return Tarefa(
          titulo: dados["titulo"],
          descricao: dados["descricao"],
          concluida: dados["concluida"],
          horario: dados["horario"],
          tipo: dados["tipo"],
        );
      }).toList();
      if (!mounted) return;
      setState(() {
        _itens
          ..clear()
          ..addAll(tarefas);
      });
    }
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

    await prefs.setStringList(chaveTarefas, tarefasJson);
  }

  void _salvarTarefa(int? index) async {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
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
      _descricaoController.text = _itens[index].descricao;
    } else {
      _tituloController.clear();
      _descricaoController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Nova Tarefa' : 'Editar Tarefa'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _salvarTarefa(index),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tarefasFiltradas = _itens.where((tarefa) {
      return tarefa.titulo.toLowerCase().contains(_textoBusca);
    }).toList();

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
                'Minha Agenda',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Veja seus compromissos',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),

                lastDay: DateTime.utc(2035, 12, 31),

                focusedDay: _diaFocado,

                selectedDayPredicate: (day) {
                  return isSameDay(_diaSelecionado, day);
                },

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _diaSelecionado = selectedDay;

                    _diaFocado = focusedDay;
                  });
                },

                rowHeight: 42,

                daysOfWeekHeight: 20,

                headerStyle: HeaderStyle(
                  titleCentered: true,

                  formatButtonVisible: false,

                  titleTextStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),

                  leftChevronIcon: Container(
                    padding: const EdgeInsets.all(6),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(Icons.chevron_left, size: 20),
                  ),

                  rightChevronIcon: Container(
                    padding: const EdgeInsets.all(6),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(Icons.chevron_right, size: 20),
                  ),
                ),

                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(fontSize: 16),

                  weekendTextStyle: const TextStyle(fontSize: 16),

                  outsideTextStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),

                  todayDecoration: BoxDecoration(
                    color: Colors.green.shade300,

                    shape: BoxShape.circle,
                  ),

                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF70D6C2),

                    shape: BoxShape.circle,
                  ),

                  cellMargin: const EdgeInsets.all(6),
                ),

                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 12, color: Colors.grey),

                  weekendStyle: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Hoje',

                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
                ),

                ElevatedButton(
                  onPressed: () => _mostrarFormulario(),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF63D49C),

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    '+ Adicionar',

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: tarefasFiltradas.isEmpty
                ? const Center(child: Text("Nenhuma tarefa cadastrada."))
                : ListView.builder(
                    itemCount: tarefasFiltradas.length,

                    itemBuilder: (context, index) {
                      final tarefa = tarefasFiltradas[index];

                      final indexOriginal = _itens.indexOf(tarefa);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(24),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),

                              blurRadius: 10,

                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _itens[indexOriginal].concluida =
                                      !_itens[indexOriginal].concluida;
                                });

                                await _salvarNoStorage();
                              },

                              child: Container(
                                width: 28,
                                height: 28,

                                margin: const EdgeInsets.only(top: 4),

                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  color: tarefa.concluida
                                      ? const Color(0xFF63D49C)
                                      : Colors.transparent,

                                  border: Border.all(
                                    color: tarefa.concluida
                                        ? const Color(0xFF63D49C)
                                        : Colors.grey.shade400,

                                    width: 2,
                                  ),
                                ),

                                child: tarefa.concluida
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    tarefa.titulo,

                                    style: const TextStyle(
                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,

                                      color: Color(0xFF20263A),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    tarefa.descricao,

                                    style: TextStyle(
                                      fontSize: 15,

                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),

                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF0DD),

                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),

                                        child: Text(
                                          tarefa.tipo,

                                          style: const TextStyle(
                                            color: Colors.orange,

                                            fontWeight: FontWeight.bold,
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
                                          color: const Color(0xFFEAEAEA),

                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),

                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,

                                              size: 16,
                                            ),

                                            const SizedBox(width: 4),

                                            Text(
                                              tarefa.horario,

                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              onPressed: () => _excluirTarefa(indexOriginal),

                              icon: Icon(
                                Icons.delete_outline,

                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: NavBar(
        currentIndex: 1,
        onTap: (index) => navigateByIndex(context, 1, index),
      ),
    );
  }
}
