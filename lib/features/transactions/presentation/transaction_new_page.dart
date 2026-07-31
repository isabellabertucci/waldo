import 'package:flutter/material.dart';

class TransactionNewPage extends StatelessWidget {
  const TransactionNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Transaction')),
      body: const Center(child: Text('New Transaction')),
    );
  }
}
