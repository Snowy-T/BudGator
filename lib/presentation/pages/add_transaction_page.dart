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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter an amount' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final transaction = TransactionModel(
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      date: _selectedDate,
                      category: _category,
                    );
                    ref.read(transactionsProvider.notifier).add(transaction);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Transaction'),
              ),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: ['General', 'Food', 'Transport', 'Entertainment']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
