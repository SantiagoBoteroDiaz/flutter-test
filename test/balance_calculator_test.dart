import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_app/logic/balance_calculator.dart';
import 'package:gastos_app/models/expense.dart';
import 'package:gastos_app/models/person.dart';

void main() {
  test('un gasto donde solo Ana aporta 100: Ana recibe 75, cada otro paga 25', () {
    final expenses = [
      const Expense(id: '1', name: 'Cena', amounts: {Person.ana: 100}),
    ];

    final balances = BalanceCalculator.computeBalances(expenses);

    expect(balances[Person.ana], 75); // aportó 100, le tocaba 25
    expect(balances[Person.bruno], -25); // no aportó, le tocaba 25
    expect(balances[Person.carla], -25);
    expect(balances[Person.diego], -25);

    final settlements = BalanceCalculator.computeSettlements(balances);
    // 3 personas le pagan 25 a Ana.
    expect(settlements.length, 3);
    expect(settlements.every((s) => s.to == Person.ana), true);
    expect(settlements.fold<double>(0, (sum, s) => sum + s.amount), 75);
  });

  test('sin gastos, todos en cero', () {
    final balances = BalanceCalculator.computeBalances([]);
    expect(balances.values.every((b) => b == 0), true);
    expect(BalanceCalculator.computeSettlements(balances), isEmpty);
  });

  test('un gasto repartido entre varios aportantes distintos se compensa', () {
    final expenses = [
      const Expense(
        id: '1',
        name: 'Mercado',
        amounts: {Person.ana: 80, Person.bruno: 40},
      ),
    ];
    // total = 120, promedio del grupo = 30 c/u.

    final balances = BalanceCalculator.computeBalances(expenses);
    expect(balances[Person.ana], 50); // aportó 80, le tocaba 30
    expect(balances[Person.bruno], 10); // aportó 40, le tocaba 30
    expect(balances[Person.carla], -30);
    expect(balances[Person.diego], -30);

    final settlements = BalanceCalculator.computeSettlements(balances);
    // Solo carla y diego deben pagar; solo ana y bruno deben recibir.
    expect(settlements.every((s) => s.from == Person.carla || s.from == Person.diego), true);
    expect(settlements.every((s) => s.to == Person.ana || s.to == Person.bruno), true);
    expect(settlements.fold<double>(0, (sum, s) => sum + s.amount), 60);
  });

  test('el total de un gasto es la suma de los aportes de las 4 personas', () {
    const expense = Expense(
      id: '1',
      name: 'Taxi',
      amounts: {Person.ana: 10, Person.bruno: 5, Person.carla: 0, Person.diego: 5},
    );
    expect(expense.total, 20);
  });
}
