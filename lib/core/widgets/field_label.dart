import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The small label over a field's value; [required] adds a red " *" that
/// screen readers announce as "required".
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false, this.style});

  final String text;
  final bool required;

  /// In place of the small grey caption, e.g. a list row's name.
  final TextStyle? style;

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
              style: TextStyle(color: colors.negative),
            ),
        ],
      ),
      semanticsLabel: required ? requiredSemantics(context, text) : null,
      style: style ?? context.label.copyWith(color: colors.inkMuted),
    );
  }
}

/// A field's error, under it and in line with its label, so the message
/// reads as part of the field.
class FieldError extends StatelessWidget {
  const FieldError(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xxs),
      child: Text(
        text,
        style: context.label.copyWith(color: context.appColors.negative),
      ),
    );
  }
}
