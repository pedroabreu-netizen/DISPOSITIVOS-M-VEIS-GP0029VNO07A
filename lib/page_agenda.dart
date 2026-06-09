import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'navigation/nav_index.dart';
import 'page_login.dart';
import 'tarefa.dart';
import 'widgets/nav_bar.dart';

class PageAgenda extends StatefulWidget {
  const PageAgenda({super.key});

  @override
  State<PageAgenda> createState() => _PageAgendaState();
}

class _PageAgendaState extends State<PageAgenda> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _buscaController = TextEditingController();

  static const String chaveTarefas = 'lista_tarefas';
  final bool _modoBusca = false;

  String _textoBusca = '';
  DateTime _diaSelecionado = DateTime.now();
  DateTime _diaFocado = DateTime.now();

  String _tipoSelecionado = 'Outro';
  TimeOfDay? _horarioSelecionado;
  DateTime? _dataSelecionada;
  String _repeticaoSelecionada = 'Nunca';

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(() {
      setState(() {
        _textoBusca = _buscaController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  /// aqui o getter que aponta para a subcoleção NoSQL isolada do usuário autenticado
  CollectionReference get _userTarefasCollection {
    final String userId =
        FirebaseAuth.instance.currentUser?.uid ?? 'usuario_anonimo';
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('tarefas');
  }

  /// CREATE e UPDATE
  void _salvarTarefa([Tarefa? tarefaExistente]) async {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) {
      return;
    }

    final dataAlvo = _dataSelecionada ?? _diaSelecionado;
    final dataString =
        '${dataAlvo.day.toString().padLeft(2, '0')}/'
        '${dataAlvo.month.toString().padLeft(2, '0')}/'
        '${dataAlvo.year}';

    final horarioString = _horarioSelecionado == null
        ? (tarefaExistente != null ? tarefaExistente.horario : '00:00')
        : _horarioSelecionado!.format(context);

    final novaTarefa = Tarefa(
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      concluida: tarefaExistente != null ? tarefaExistente.concluida : false,
      horario: horarioString,
      tipo: _tipoSelecionado,
      data: dataString,
      repeticao: _repeticaoSelecionada,
    );

    if (tarefaExistente == null) {
      // OPERAÇÃO: CREATE
      await _userTarefasCollection.add(novaTarefa.toMap());
    } else {
      // OPERAÇÃO: UPDATE
      await _userTarefasCollection
          .doc(tarefaExistente.id)
          .update(novaTarefa.toMap());
    }

    _tituloController.clear();
    _descricaoController.clear();
    _horarioSelecionado = null;
    _dataSelecionada = null;
    _tipoSelecionado = 'Outro';
    _repeticaoSelecionada = 'Nunca';

    Navigator.pop(context);
  }

  /// DELETE
  void _excluirTarefa(String tarefaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirmar exclusão',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza que deseja excluir esta tarefa?',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _userTarefasCollection.doc(tarefaId).delete();
    }
  }

  /// alterna o status do checkbox mudando apenas o campo 'concluida' no Firestore
  Future<void> _alternarStatusTarefa(Tarefa tarefa, bool valor) async {
    await _userTarefasCollection.doc(tarefa.id).update({'concluida': valor});
  }

  void _mostrarFormulario([Tarefa? tarefa]) {
    if (tarefa != null) {
      _tituloController.text = tarefa.titulo;
      _descricaoController.text = tarefa.descricao;
      _tipoSelecionado = tarefa.tipo;
      _repeticaoSelecionada = tarefa.repeticao;
    } else {
      _tituloController.clear();
      _descricaoController.clear();
      _tipoSelecionado = 'Outro';
      _repeticaoSelecionada = 'Nunca';
      _horarioSelecionado = null;
      _dataSelecionada = null;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
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
                    Row(
                      children: [
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
                                        _dataSelecionada ?? _diaSelecionado,
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
                                            ? (tarefa != null &&
                                                      tarefa.data.isNotEmpty
                                                  ? tarefa.data
                                                  : 'Selecionar')
                                            : '${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}',
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
                                            ? (tarefa != null
                                                  ? tarefa.horario
                                                  : '--:--')
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
                    const SizedBox(height: 20),
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
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _salvarTarefa(tarefa),
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
    // formata a data atual selecionada no calendário para bater com o padrão de Strings NoSQL (DD/MM/AAAA)
    final stringDiaSelecionado =
        '${_diaSelecionado.day.toString().padLeft(2, '0')}/'
        '${_diaSelecionado.month.toString().padLeft(2, '0')}/'
        '${_diaSelecionado.year}';

    return StreamBuilder<QuerySnapshot>(
      stream: _userTarefasCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Erro ao conectar ao Firebase.')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // converte os documentos em instâncias da classe Tarefa
        final todasAsTarefas = snapshot.data!.docs.map((doc) {
          return Tarefa.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        // Filtra as tarefas de acordo com o dia selecionado no TableCalendar e a busca por texto
        final tarefasFiltradas = todasAsTarefas.where((tarefa) {
          final mesmaData = tarefa.data == stringDiaSelecionado;
          final mesmaBusca = tarefa.titulo.toLowerCase().contains(_textoBusca);
          return mesmaData && mesmaBusca;
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
                    selectedDayPredicate: (day) =>
                        isSameDay(_diaSelecionado, day),
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
                      'Compromissos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
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
                    ? const Center(
                        child: Text("Nenhuma tarefa cadastrada para este dia."),
                      )
                    : ListView.builder(
                        itemCount: tarefasFiltradas.length,
                        itemBuilder: (context, index) {
                          final tarefa = tarefasFiltradas[index];

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
                                  onTap: () => _alternarStatusTarefa(
                                    tarefa,
                                    !tarefa.concluida,
                                  ),
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
                                  child: GestureDetector(
                                    onTap: () => _mostrarFormulario(
                                      tarefa,
                                    ), // Abre em modo de edição
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF0DD),
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEAEAEA),
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                ),
                                IconButton(
                                  onPressed: () => _excluirTarefa(tarefa.id!),
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
          // bottomNavigationBar: NavBar(
          //   currentIndex: 1,
          //   onTap: (index) => navigateByIndex(context, 1, index),
          // ),
        );
      },
    );
  }
}
