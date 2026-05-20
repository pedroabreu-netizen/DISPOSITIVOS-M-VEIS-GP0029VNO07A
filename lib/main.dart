import 'package:flutter/material.dart';
import 'page_arquivos.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'page_login.dart';


void main() {
  runApp(const VivaApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      title: 'Viva+',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF65C982)),
      ),
      home: const LoginPage(),
    );
  }
}
