import 'package:dispositivos_moveis_gp0029vno07a/navigation/nav_index.dart';
import 'package:flutter/material.dart';
import 'navigation/nav_index.dart';
import 'widgets/nav_bar.dart';

class PageNotas extends StatelessWidget {
  const PageNotas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('pagina de notas')),
      bottomNavigationBar: NavBar(
        currentIndex: 2,
        onTap: (index) => navigateByIndex(context, 2, index),
      ),
    );
  }
}
