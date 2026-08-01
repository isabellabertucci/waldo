import 'package:flutter/material.dart';
import 'package:waldo/core/router/app_router.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Transactions'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => const TransactionNewRoute().push(context),
              child: const Text('New Transaction (nested route)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => const TransactionDetailRoute('42').push(context),
              child: const Text('Transaction #42 (dynamic param)'),
            ),
          ],
        ),
      ),
    );
  }
}
