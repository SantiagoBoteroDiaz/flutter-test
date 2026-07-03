import 'person.dart';


class Settlement {
  final Person from;
  final Person to;
  final double amount;

  const Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });
}
