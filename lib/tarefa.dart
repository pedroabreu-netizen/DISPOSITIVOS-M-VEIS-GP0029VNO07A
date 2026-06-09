class Tarefa {
  String? id; // Adicionado: ID do documento no Firestore
  String titulo;
  String descricao;
  bool concluida;
  String horario;
  String tipo;
  String data;
  String repeticao;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.concluida,
    required this.horario,
    required this.tipo,
    required this.data,
    required this.repeticao,
  });

  /// Converte para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
      'horario': horario,
      'tipo': tipo,
      'data': data,
      'repeticao': repeticao,
    };
  }

  /// Converte de Map (Firestore) para objeto Tarefa
  factory Tarefa.fromMap(String documentId, Map<String, dynamic> map) {
    return Tarefa(
      id: documentId,
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      concluida: map['concluida'] ?? false,
      horario: map['horario'] ?? '',
      tipo: map['tipo'] ?? '',
      data: map['data'] ?? '',
      repeticao: map['repeticao'] ?? '',
    );
  }
}