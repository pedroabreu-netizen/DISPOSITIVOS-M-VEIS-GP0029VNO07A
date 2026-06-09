import 'package:flutter/material.dart';

enum CategoriaArquivo {
  exame('Exame', 'Exame', Icons.science_outlined),
  prescricao('Prescrição', 'Prescrição', Icons.medication_outlined),
  laudo('Laudo', 'Laudo', Icons.description_outlined),
  receita('Receita', 'Receita Médica', Icons.receipt_long_outlined),
  outros('Outros', 'Outros', Icons.folder_outlined);

  const CategoriaArquivo(this.label, this.chipLabel, this.icon);

  /// Label curto — usado no badge do card
  final String label;

  /// Label completo — usado nos chips de filtro
  final String chipLabel;

  final IconData icon;
}

class ArquivoMedico {
  final String id;
  final String nome;
  final CategoriaArquivo categoria;
  final DateTime dataUpload;
  final int tamanhoBytes;
  final String extensao;
  final String criadoPor;
  final String? caminhoLocal;
  final String? urlRemota;

  const ArquivoMedico({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.dataUpload,
    required this.tamanhoBytes,
    required this.extensao,
    this.criadoPor = '',
    this.caminhoLocal,
    this.urlRemota,
  });

  String get tamanhoFormatado {
    if (tamanhoBytes < 1024) return '$tamanhoBytes B';
    if (tamanhoBytes < 1024 * 1024) {
      return '${(tamanhoBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(tamanhoBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory ArquivoMedico.fromJson(Map<String, dynamic> json) {
    return ArquivoMedico(
      id: json['id'] as String,
      nome: json['nome'] as String,
      categoria: CategoriaArquivo.values.firstWhere(
        (e) => e.name == json['categoria'] as String,
        orElse: () => CategoriaArquivo.outros,
      ),
      dataUpload: DateTime.parse(json['dataUpload'] as String),
      tamanhoBytes: json['tamanhoBytes'] as int,
      extensao: json['extensao'] as String,
      criadoPor: json['criado_por'] as String? ?? '',
      caminhoLocal: json['caminhoLocal'] as String?,
      urlRemota: json['urlRemota'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'categoria': categoria.name,
    'dataUpload': dataUpload.toIso8601String(),
    'tamanhoBytes': tamanhoBytes,
    'extensao': extensao,
    'criado_por': criadoPor,
    if (caminhoLocal != null) 'caminhoLocal': caminhoLocal,
    if (urlRemota != null) 'urlRemota': urlRemota,
  };

  ArquivoMedico copyWith({
    String? id,
    String? nome,
    CategoriaArquivo? categoria,
    DateTime? dataUpload,
    int? tamanhoBytes,
    String? extensao,
    String? criadoPor,
    String? caminhoLocal,
    String? urlRemota,
  }) {
    return ArquivoMedico(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      dataUpload: dataUpload ?? this.dataUpload,
      tamanhoBytes: tamanhoBytes ?? this.tamanhoBytes,
      extensao: extensao ?? this.extensao,
      criadoPor: criadoPor ?? this.criadoPor,
      caminhoLocal: caminhoLocal ?? this.caminhoLocal,
      urlRemota: urlRemota ?? this.urlRemota,
    );
  }
}
