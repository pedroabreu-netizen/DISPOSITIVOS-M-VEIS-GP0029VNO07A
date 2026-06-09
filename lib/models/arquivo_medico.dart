import 'package:flutter/material.dart';

enum CategoriaArquivo {
  exame,
  prescricao,
  laudo,
  receita,
  outros;

  String get label => switch (this) {
        CategoriaArquivo.exame       => 'Exame',
        CategoriaArquivo.prescricao  => 'Prescrição',
        CategoriaArquivo.laudo       => 'Laudo',
        CategoriaArquivo.receita     => 'Receita',
        CategoriaArquivo.outros      => 'Outros',
      };

  String get chipLabel => label;

  IconData get icon => switch (this) {
        CategoriaArquivo.exame       => Icons.biotech_outlined,
        CategoriaArquivo.prescricao  => Icons.medication_outlined,
        CategoriaArquivo.laudo       => Icons.description_outlined,
        CategoriaArquivo.receita     => Icons.receipt_long_outlined,
        CategoriaArquivo.outros      => Icons.folder_outlined,
      };
}

class ArquivoMedico {
  final String id;
  final String nome;
  final CategoriaArquivo categoria;
  final DateTime dataUpload;
  final int tamanhoBytes;
  final String extensao;

  // Campos para integração com Firebase:
  // downloadUrl — URL pública do arquivo no Firebase Storage
  // nomeNoStorage — nome com que o arquivo foi salvo no Storage,
  //                 necessário para deletá-lo posteriormente
  final String? downloadUrl;
  final String? nomeNoStorage;

  // Mantido por compatibilidade com o código original (não usado no Firebase)
  final String? caminhoLocal;

  const ArquivoMedico({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.dataUpload,
    required this.tamanhoBytes,
    required this.extensao,
    this.downloadUrl,
    this.nomeNoStorage,
    this.caminhoLocal,
  });

  String get tamanhoFormatado {
    if (tamanhoBytes >= 1024 * 1024) {
      return '${(tamanhoBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (tamanhoBytes >= 1024) {
      return '${(tamanhoBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$tamanhoBytes B';
  }
}