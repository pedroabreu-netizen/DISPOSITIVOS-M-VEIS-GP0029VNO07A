class Nota {
  String? id; 
  String titulo;
  String descricao;
  List<String> tags;
  String? data;
  bool concluida;

  Nota({
    this.id,
    required this.titulo,
    required this.descricao,
    this.tags = const [],
    this.data,
    this.concluida = false,
  });

  // transforma a nota em um mapa para enviar ao firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'tags': tags,
      'data': data,
      'concluida': concluida,
    };
  }

  // transforma o mapa que vem do firestore de volta em uma nota
  factory Nota.fromMap(String documentId, Map<String, dynamic> map) {
    return Nota(
      id: documentId,
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      // vai garantir que a lista de tags seja convertida corretamente de dynamic pra string
      tags: List<String>.from(map['tags'] ?? []),
      data: map['data'],
      concluida: map['concluida'] ?? false,
    );
  }
}