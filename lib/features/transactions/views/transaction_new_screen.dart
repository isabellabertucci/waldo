import 'package:flutter/material.dart';

import 'widgets/transaction_form_sheet.dart';

class TransactionNewScreen extends StatelessWidget {
  const TransactionNewScreen({super.key, required this.walletId});

  final int walletId;

  @override
  Widget build(BuildContext context) {
    return TransactionFormSheet(initialWalletId: walletId);
  }
}
