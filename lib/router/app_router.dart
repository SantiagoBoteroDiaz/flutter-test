import 'package:go_router/go_router.dart';

import '../screens/add_expense_screen.dart';
import '../screens/expenses_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ExpensesListScreen(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddExpenseScreen(),
    ),
  ],
);
