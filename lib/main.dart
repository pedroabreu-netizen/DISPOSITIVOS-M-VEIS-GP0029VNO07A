import 'package:flutter/material.dart';
import 'page_arquivos.dart';

void main() {
  runApp(const VivaApp());
}

class VivaApp extends StatelessWidget {
  const VivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D28D9)),
        useMaterial3: true,
      ),
      // Ponto de entrada temporário para desenvolvimento da tela de arquivos.
      // Substituir pela rota de login quando o fluxo completo estiver pronto.
      initialRoute: PageArquivos.routeName,
      routes: {
        PageArquivos.routeName: (_) => const PageArquivos(),
        // Descomentar conforme as páginas forem implementadas:
        // PageLogin.routeName: (_) => const PageLogin(),
        // PageHome.routeName: (_) => const PageHome(),
        // PageAgenda.routeName: (_) => const PageAgenda(),
        // PageNotas.routeName: (_) => const PageNotas(),
      },
    );
  }
}
