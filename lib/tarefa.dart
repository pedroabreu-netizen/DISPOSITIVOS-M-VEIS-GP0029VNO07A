class Tarefa {
  String? id;
  String titulo;
  String descricao;
  bool concluida;
  String horario;
  String tipo;
  String data;
  String repeticao;
  String criadoPor;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.concluida,
    required this.horario,
    required this.tipo,
    required this.data,
    required this.repeticao,
    this.criadoPor = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
      'horario': horario,
      'tipo': tipo,
      'data': data,
      'repeticao': repeticao,
      'criado_por': criadoPor,
    };
  }

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
      criadoPor: map['criado_por'] ?? '',
    );
  }
}
