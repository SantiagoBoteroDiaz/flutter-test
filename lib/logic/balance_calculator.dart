import 'dart:math';

import '../models/expense.dart';
import '../models/person.dart';
import '../models/settlement.dart';


class BalanceCalculator {
  BalanceCalculator._();

  static const double _epsilon = 0.01;


  static Map<Person, double> computeBalances(List<Expense> expenses) {
    final balances = {for (final person in Person.values) person: 0.0};
    if (expenses.isEmpty) return balances;

    var total = 0.0;
    for (final expense in expenses) {
      for (final person in Person.values) {
        final aporte = expense.amounts[person] ?? 0;
        balances[person] = balances[person]! + aporte;
        total += aporte;
      }
    }

    final fairShare = total / Person.values.length;
    for (final person in Person.values) {
      balances[person] = balances[person]! - fairShare;
    }

    return balances;
  }

  static List<Settlement> computeSettlements(Map<Person, double> balances) {
    final pending = Map<Person, double>.from(balances);
    final settlements = <Settlement>[];

    for (final debtor in Person.values) {
      while (pending[debtor]! < -_epsilon) {
        final creditor = Person.values.firstWhere(
          (person) => pending[person]! > _epsilon,
        );
        final amount = min(-pending[debtor]!, pending[creditor]!);

        settlements.add(Settlement(from: debtor, to: creditor, amount: amount));

        pending[debtor] = pending[debtor]! + amount;
        pending[creditor] = pending[creditor]! - amount;
      }
    }

    return settlements;
  }
}
