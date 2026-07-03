import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/expense.dart';
import '../models/person.dart';
import '../models/settlement.dart';
import '../providers/expenses_provider.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    final balances = ref.watch(balancesProvider);
    final settlements = ref.watch(settlementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos compartidos')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          const _SectionTitle('Historial de gastos'),
          if (expenses.isEmpty)
            const _EmptyState(
              icon: Icons.receipt_long_outlined,
              text: 'Aún no hay gastos registrados.',
            )
          else
            ...expenses.map(
              (expense) => _DismissibleExpenseCard(
                key: ValueKey(expense.id),
                expense: expense,
              ),
            ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const _SectionTitle('Balances'),
          ...Person.values.map(
            (person) => _BalanceTile(person: person, balance: balances[person]!),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const _SectionTitle('Quién le paga a quién'),
          if (settlements.isEmpty)
            const _EmptyState(
              icon: Icons.check_circle_outline,
              text: 'Todo está saldado.',
            )
          else
            ...settlements.map((s) => _SettlementTile(settlement: s)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Agregar gasto'),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}


class _DismissibleExpenseCard extends ConsumerWidget {
  final Expense expense;
  const _DismissibleExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void deleteExpense() {
      final removed = expense;
      ref.read(expensesProvider.notifier).removeExpense(removed.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Se eliminó "${removed.name}"'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () =>
                  ref.read(expensesProvider.notifier).addExpense(removed),
            ),
          ),
        );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => deleteExpense(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      child: _ExpenseCard(expense: expense, onDelete: deleteExpense),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  const _ExpenseCard({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final aportes = expense.amounts.entries.where((entry) => entry.value > 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(expense.name, style: Theme.of(context).textTheme.titleMedium),
                ),
                Text(
                  '\$${expense.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar gasto',
                  onPressed: onDelete,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: aportes
                  .map(
                    (entry) => Chip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      label: Text(
                        '${entry.key.displayName}: \$${entry.value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final Person person;
  final double balance;
  const _BalanceTile({required this.person, required this.balance});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = balance > 0.01;
    final isNegative = balance < -0.01;

    final IconData icon;
    final Color background;
    final Color foreground;
    final String label;

    if (isPositive) {
      icon = Icons.arrow_downward;
      background = colorScheme.tertiaryContainer;
      foreground = colorScheme.onTertiaryContainer;
      label = 'Recibe \$${balance.toStringAsFixed(2)}';
    } else if (isNegative) {
      icon = Icons.arrow_upward;
      background = colorScheme.errorContainer;
      foreground = colorScheme.onErrorContainer;
      label = 'Paga \$${(-balance).toStringAsFixed(2)}';
    } else {
      icon = Icons.check;
      background = colorScheme.surfaceContainerHighest;
      foreground = colorScheme.onSurfaceVariant;
      label = 'Al día';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: Text(person.displayName[0]),
      ),
      title: Text(person.displayName),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  final Settlement settlement;
  const _SettlementTile({required this.settlement});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        radius: 18,
        child: const Icon(Icons.arrow_forward, size: 18),
      ),
      title: Text(
        '${settlement.from.displayName} le paga a ${settlement.to.displayName}',
      ),
      trailing: Text(
        '\$${settlement.amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
