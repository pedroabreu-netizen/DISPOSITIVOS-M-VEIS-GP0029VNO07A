import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'navigation/nav_index.dart';
import 'page_login.dart';
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

  final bool _modoBusca = false;

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

  String _tipoSelecionado = 'Outro';
  TimeOfDay? _horarioSelecionado;

  DateTime? _dataSelecionada;
  String _repeticaoSelecionada = 'Nunca';

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
                        const Text(
                          'Nova Tarefa',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        CircleAvatar(
                          backgroundColor: Colors.grey.shade200,

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
                          borderRadius: BorderRadius.circular(15),
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
                        hintText: 'Adicione informações extras aqui...',

                        filled: true,
                        fillColor: Colors.grey.shade100,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
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
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Data',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'Hora',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 8),

                              GestureDetector(
                                onTap: () async {
                                  final hora = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );

                                  if (hora != null) {
                                    modalSetState(() {
                                      _horarioSelecionado = hora;
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
                                        _horarioSelecionado == null
                                            ? '--:--'
                                            : _horarioSelecionado!.format(
                                                context,
                                              ),
                                      ),

                                      const Icon(Icons.access_time, size: 18),
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
                        _buildTipoButton('Remédio', '💊', modalSetState),

                        _buildTipoButton('Médico', '🩺', modalSetState),

                        _buildTipoButton('Família', '❤️', modalSetState),

                        _buildTipoButton('Pessoal', '😊', modalSetState),

                        _buildTipoButton('Outro', '✨', modalSetState),
                      ],
                    ),

                    const SizedBox(height: 35),

                    /// BOTÃO SALVAR
                    SizedBox(
                      width: double.infinity,

                      height: 60,

                      child: ElevatedButton(
                        onPressed: () => _salvarTarefa(index),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
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

  Widget _buildTipoButton(String tipo, String emoji, Function modalSetState) {
    final selecionado = _tipoSelecionado == tipo;

    return GestureDetector(
      onTap: () {
        modalSetState(() {
          _tipoSelecionado = tipo;
        });
      },

      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),

        decoration: BoxDecoration(
          color: selecionado ? Colors.blue.shade50 : Colors.grey.shade100,

          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: selecionado ? Colors.blue : Colors.grey.shade300,
          ),
        ),

        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),

            const SizedBox(height: 5),

            Text(tipo, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
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
            // color: Color.fromARGB(255, 75, 202, 132),
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
