import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gastos_app/main.dart';

void main() {
  testWidgets('muestra la pantalla de gastos y permite agregar uno nuevo',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Arranca en la lista, sin gastos.
    expect(find.text('Gastos compartidos'), findsOneWidget);
    expect(find.text('Aún no hay gastos registrados.'), findsOneWidget);

    // Navega al formulario.
    await tester.tap(find.text('Agregar gasto'));
    await tester.pumpAndSettle();
    expect(find.text('Nuevo gasto'), findsOneWidget);

    // Completa el nombre y el aporte de la primera persona (Juan/ana).
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del gasto'), 'Cena');
    await tester.enterText(find.widgetWithText(TextFormField, 'Juan'), '100');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    // Vuelve a la lista y muestra el gasto y los balances resultantes.
    expect(find.text('Gastos compartidos'), findsOneWidget);
    expect(find.text('Cena'), findsOneWidget);
    expect(find.text('Quién le paga a quién'), findsOneWidget);
  });

  testWidgets('no deja guardar un gasto donde todos aportan cero',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.tap(find.text('Agregar gasto'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del gasto'), 'Nada');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    // Sigue en el formulario: no navegó de vuelta a la lista.
    expect(find.text('Nuevo gasto'), findsOneWidget);
    expect(find.text('La suma de los montos debe ser mayor a cero'), findsOneWidget);
  });
}
