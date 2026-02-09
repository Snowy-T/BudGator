import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _category = 'General';
  TransactionType _type = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaktion hinzufügen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Titel'),
                  validator: (value) =>
                      value!.isEmpty ? 'Titel eingeben' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Betrag (€)'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Betrag eingeben' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TransactionType>(
                  value: _type,
                  items: TransactionType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t == TransactionType.income
                                ? 'Einnahme'
                                : 'Ausgabe',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _type = val);
                  },
                  decoration: const InputDecoration(labelText: 'Typ'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  items:
                      [
                            'General',
                            'Wohnen',
                            'Lebensmittel',
                            'Transport',
                            'Unterhaltung',
                            'Shopping',
                            'Café',
                            'Salary',
                          ]
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                  decoration: const InputDecoration(labelText: 'Kategorie'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Datum: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: const Text('Datum wählen'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final transaction = TransactionModel(
                          title: _titleController.text,
                          amount: double.parse(_amountController.text),
                          date: _selectedDate,
                          category: _category,
                          type: _type,
                        );

                        ref
                            .read(transactionsProvider.notifier)
                            .add(transaction);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Transaktion hinzufügen'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
