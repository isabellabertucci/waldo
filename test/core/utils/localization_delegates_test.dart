import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/utils/localization_delegates.dart';

void main() {
  testWidgets('In Portuguese, Flutter speaks European Portuguese and the '
      "app's dates stay as they are", (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: const [Locale('en'), Locale('pt')],
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    final material = MaterialLocalizations.of(context);
    expect(material.tabLabel(tabIndex: 1, tabCount: 3), 'Separador 1 de 3');
    expect(material.datePickerHelpText, 'Selecionar data');
    // Dates still follow plain `pt`, not pt_PT's "11/2025".
    final locale = Localizations.localeOf(context).toString();
    expect(locale, 'pt');
    expect(DateFormat.yMMM(locale).format(DateTime(2025, 11)), 'nov. de 2025');
  });
}
