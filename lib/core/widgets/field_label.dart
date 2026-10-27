import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The small label over a field's value; [required] adds a dark " *" that
/// screen readers announce as "required".
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  /// "Name, required": what screen readers hear for a required field's label.
  static String requiredSemantics(BuildContext context, String text) =>
      '$text, ${AppLocalizations.of(context).requiredField}';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Text.rich(
      TextSpan(
        text: text,
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: colors.onSurface),
            ),
        ],
      ),
      semanticsLabel: required ? requiredSemantics(context, text) : null,
      style: context.textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
