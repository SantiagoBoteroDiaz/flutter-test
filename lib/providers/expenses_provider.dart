import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/balance_calculator.dart';
import '../models/expense.dart';
import '../models/person.dart';
import '../models/settlement.dart';

class ExpensesNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() => []; 

  void addExpense(Expense expense) {

    state = [...state, expense];
  }

  void removeExpense(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final expensesProvider =
    NotifierProvider<ExpensesNotifier, List<Expense>>(ExpensesNotifier.new);


final totalProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses.fold<double>(0, (sum, e) => sum + e.total);
});

final balancesProvider = Provider<Map<Person, double>>((ref) {
  final expenses = ref.watch(expensesProvider);
  return BalanceCalculator.computeBalances(expenses);
});

final settlementsProvider = Provider<List<Settlement>>((ref) {
  final balances = ref.watch(balancesProvider);
  return BalanceCalculator.computeSettlements(balances);
});