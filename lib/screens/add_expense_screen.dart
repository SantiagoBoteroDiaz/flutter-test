import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/expense.dart';
import '../models/person.dart';
import '../providers/expenses_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Un campo de monto por cada una de las 4 personas fijas.
  final Map<Person, TextEditingController> _amountControllers = {
    for (final person in Person.values) person: TextEditingController(text: '0'),
  };

  String? _totalError;

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _total {
    return _amountControllers.values.fold<double>(
      0,
      (sum, controller) => sum + (double.tryParse(controller.text.trim()) ?? 0),
    );
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    final total = _total;

    setState(() {
      _totalError = total <= 0 ? 'La suma de los montos debe ser mayor a cero' : null;
    });
    if (!formValid || _totalError != null) return;

    final expense = Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amounts: {
        for (final entry in _amountControllers.entries)
          entry.key: double.parse(entry.value.text.trim()),
      },
    );

    ref.read(expensesProvider.notifier).addExpense(expense);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Gasto agregado')));

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasTotalError = _totalError != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo gasto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Guardar',
            onPressed: _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del gasto',
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              Text('Cuánto puso cada uno', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final person in Person.values) ...[
                TextFormField(
                  controller: _amountControllers[person],
                  decoration: InputDecoration(
                    labelText: person.displayName,
                    prefixText: r'$ ',
                    prefixIcon: CircleAvatar(
                      radius: 14,
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      child: Text(
                        person.displayName[0],
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() => _totalError = null),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount < 0) {
                      return 'Ingresa un monto válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: hasTotalError ? colorScheme.errorContainer : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Total: \$${_total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: hasTotalError
                            ? colorScheme.onErrorContainer
                            : colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (_totalError != null) ...[
                const SizedBox(height: 4),
                Text(_totalError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(onPressed: _submit, child: const Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
