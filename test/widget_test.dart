import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dispositivos_moveis_gp0029vno07a/main.dart';

void main() {
  testWidgets('Mostra a tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const VivaApp());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);

    await tester.tap(find.text('Clique para cadastrar nova conta'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastro'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(3), '11987654321');
    await tester.pump();

    expect(find.text('(11) 98765-4321'), findsOneWidget);
  });
}
