class Nota {
  String? id;
  String titulo;
  String descricao;
  List<String> tags;
  String? data;
  bool concluida;
  String criadoPor;

  Nota({
    this.id,
    required this.titulo,
    required this.descricao,
    this.tags = const [],
    this.data,
    this.concluida = false,
    this.criadoPor = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'tags': tags,
      'data': data,
      'concluida': concluida,
      'criado_por': criadoPor,
    };
  }

  factory Nota.fromMap(String documentId, Map<String, dynamic> map) {
    return Nota(
      id: documentId,
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      data: map['data'],
      concluida: map['concluida'] ?? false,
      criadoPor: map['criado_por'] ?? '',
    );
  }
}
