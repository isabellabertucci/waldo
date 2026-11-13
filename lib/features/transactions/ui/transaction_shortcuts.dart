import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/l10n/app_localizations.dart';

import 'widgets/transaction_form_sheet.dart';

final _log = Logger('waldo.ui.shortcuts');

const _newExpense = 'new_expense';
const _newIncome = 'new_income';

/// The app icon's shortcuts (press and hold it on the home screen): "New
/// expense" and "New income" open Home with the new-transaction sheet, so
/// logging skips a step. Wraps the app, under its localizations, so the
/// names follow the language.
class TransactionShortcuts extends StatefulWidget {
  const TransactionShortcuts({
    super.key,
    required this.router,
    required this.child,
    this.quickActions = const QuickActions(),
  });

  final GoRouter router;
  final Widget child;

  /// Swapped in tests.
  final QuickActions quickActions;

  @override
  State<TransactionShortcuts> createState() => _TransactionShortcutsState();
}

class _TransactionShortcutsState extends State<TransactionShortcuts> {
  @override
  void initState() {
    super.initState();
    // Also called for the shortcut that launched the app.
    widget.quickActions.initialize(_open);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    widget.quickActions
        .setShortcutItems([
          ShortcutItem(
            type: _newExpense,
            localizedTitle: l10n.newExpense,
            // ios/Runner/Assets.xcassets and android/.../res/drawable.
            icon: 'shortcut_expense',
          ),
          ShortcutItem(
            type: _newIncome,
            localizedTitle: l10n.newIncome,
            icon: 'shortcut_income',
          ),
        ])
        .catchError((Object e) => _log.warning('setShortcutItems failed', e));
  }

  void _open(String shortcut) {
    final type = switch (shortcut) {
      _newExpense => TransactionType.expense,
      _newIncome => TransactionType.income,
      _ => null,
    };
    if (type == null) return;
    _log.info('Shortcut opened: $shortcut');
    widget.router.go(const DashboardRoute().location);
    _showSheetWhenReady(type);
  }

  /// After Home is in place: on a cold start the navigator isn't built yet.
  void _showSheetWhenReady(TransactionType type, {int tries = 10}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = widget.router.routerDelegate.navigatorKey.currentContext;
      if (context == null) {
        if (tries > 0) _showSheetWhenReady(type, tries: tries - 1);
        return;
      }
      showTransactionFormSheet(context, initialType: type);
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
