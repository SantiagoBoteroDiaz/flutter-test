import 'person.dart';


class Expense {
  final String id;
  final String name;
  final Map<Person, double> amounts;

  const Expense({
    required this.id,
    required this.name,
    required this.amounts,
  });

  double get total => amounts.values.fold(0, (sum, amount) => sum + amount);
}
