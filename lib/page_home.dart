import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'page_login.dart';
import 'tarefa.dart';
import 'widgets/nav_bar.dart';
import 'navigation/nav_index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _buscaController = TextEditingController();

  String _textoBusca = "";
  String _tipoSelecionado = 'Outro';
  TimeOfDay? _horarioSelecionado;
  DateTime? _dataSelecionada;
  String _repeticaoSelecionada = 'Nunca';
  String dataFormatada = DateFormat("EEEE d 'de' MMMM", 'pt_BR').format(DateTime.now());

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

  /// um getter que aponta para a subcoleção NoSQL isolada do usuário autenticado
  CollectionReference get _userTarefasCollection {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'usuario_anonimo';
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('tarefas');
  }

  /// CREATE e UPDATE
  void _salvarTarefa([Tarefa? tarefaExistente]) async {
    if (_tituloController.text.isEmpty ||
        _descricaoController.text.isEmpty || 
        _tipoSelecionado.isEmpty) {
      return;
    }

    final dataString = _dataSelecionada == null
        ? (tarefaExistente != null ? tarefaExistente.data : '')
        : '${_dataSelecionada!.day.toString().padLeft(2, '0')}/'
          '${_dataSelecionada!.month.toString().padLeft(2, '0')}/'
          '${_dataSelecionada!.year}';

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
      await _userTarefasCollection.doc(tarefaExistente.id).update(novaTarefa.toMap());
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
        title: const Text('Confirmar exclusão', 
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

  /// Alterna o status do Checkbox mudando apenas o campo 'concluida' no Firestore
  Future<void> _alternarStatusTarefa(Tarefa tarefa, bool valor) async {
    await _userTarefasCollection.doc(tarefa.id).update({
      'concluida': valor,
    });
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
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                    const Text('O que é?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    const Text('Detalhes (opcional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                              const Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final data = await showDatePicker(
                                    context: context,
                                    initialDate: _dataSelecionada ?? DateTime.now(),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _dataSelecionada == null
                                            ? (tarefa != null && tarefa.data.isNotEmpty ? tarefa.data : 'Selecionar')
                                            : '${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}',
                                      ),
                                      const Icon(Icons.calendar_today, size: 18),
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
                              const Text('Hora', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _horarioSelecionado == null
                                            ? (tarefa != null ? tarefa.horario : '--:--')
                                            : _horarioSelecionado!.format(context),
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
                    const Text('Repetir?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _repeticaoSelecionada,
                          items: const [
                            DropdownMenuItem(value: 'Nunca', child: Text('Nunca')),
                            DropdownMenuItem(value: 'Diariamente', child: Text('Diariamente')),
                            DropdownMenuItem(value: 'Semanalmente', child: Text('Semanalmente')),
                            DropdownMenuItem(value: 'Mensalmente', child: Text('Mensalmente')),
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
                    const Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text(
                          'Salvar Tarefa',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
          border: Border.all(color: selecionado ? Colors.blue : Colors.grey.shade300),
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
    final hoje = '${DateTime.now().day.toString().padLeft(2, '0')}/'
        '${DateTime.now().month.toString().padLeft(2, '0')}/'
        '${DateTime.now().year}';

    //  nome cadastrado no login 
    final String nomeUsuario = FirebaseAuth.instance.currentUser?.displayName ?? 'Usuário';

    // streamBuilder escuta as atualizações em tempo real da subcoleção de tarefas
    return StreamBuilder<QuerySnapshot>(
      stream: _userTarefasCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text('Erro ao conectar ao Firebase.')));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final todasAsTarefas = snapshot.data!.docs.map((doc) {
          return Tarefa.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        final tarefasFiltradas = todasAsTarefas.where((tarefa) {
          final mesmaData = tarefa.data == hoje;
          final mesmaBusca = tarefa.titulo.toLowerCase().contains(_textoBusca);
          return mesmaData && mesmaBusca;
        }).toList();

        final concluidasHoje = tarefasFiltradas.where((tarefa) => tarefa.concluida).length;
        final pendentes = tarefasFiltradas.where((tarefa) => !tarefa.concluida).length;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 240, 
            flexibleSpace: Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF62C982), Color(0xFF23D7CC)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $nomeUsuario',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dataFormatada, style: const TextStyle(color: Colors.white70)),
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
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                                style: const TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold)),
                            const Text('Concluídas hoje',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        Container(width: 1, height: 30, color: Colors.white),
                        Column(
                          children: [
                            Text('$pendentes',
                                style: const TextStyle(fontSize: 35, color: Colors.orange, fontWeight: FontWeight.bold)),
                            const Text('Pendentes',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
              ? const Center(child: Text("Nenhuma tarefa cadastrada para hoje."))
              : ListView.builder(
                  itemCount: tarefasFiltradas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefasFiltradas[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              'Para fazer hoje',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                          ),
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
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
                                        onChanged: (value) => _alternarStatusTarefa(tarefa, value ?? false),
                                        shape: const CircleBorder(),
                                        activeColor: Colors.green,
                                        checkColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _mostrarFormulario(tarefa), // Abre em formato de edição
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tarefa.titulo,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              tarefa.descricao,
                                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 35),
                                      onPressed: () => _excluirTarefa(tarefa.id!),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(left: 50),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
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
            padding: const EdgeInsets.only(bottom: 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton.extended(
                onPressed: () => _mostrarFormulario(),
                icon: const Icon(Icons.add),
                label: const Text(
                  ' Adicionar tarefa',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color.fromARGB(255, 62, 172, 111),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          bottomNavigationBar: NavBar(
            currentIndex: 0,
            onTap: (index) => navigateByIndex(context, 0, index),
          ),
        );
      },
    );
  }
}