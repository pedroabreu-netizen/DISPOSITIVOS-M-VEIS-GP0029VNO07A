class Nota {
  String titulo;
  String descricao;
  List<String> tags;
  String? data;
  bool concluida;

  Nota({
    required this.titulo,
    required this.descricao,
    this.tags = const [],
    this.data,
    this.concluida = false,
  });
}
