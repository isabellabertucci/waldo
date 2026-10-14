import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// The Name field shared by the wallet and category forms: an ink badge,
/// a small label, and a borderless text field, with an ink outline while
/// focused (DESIGN.md: 2px `primary` when focused).
class FormNameField extends StatefulWidget {
  const FormNameField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    required this.validator,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String> validator;

  /// Put on the inner [TextFormField], so tests can type into it.
  final Key? fieldKey;

  @override
  State<FormNameField> createState() => _FormNameFieldState();
}

class _FormNameFieldState extends State<FormNameField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListenableBuilder(
      listenable: _focusNode,
      builder: (context, child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(Rounded.lg),
          border: _focusNode.hasFocus
              ? Border.all(color: colors.primary, width: 2)
              : null,
        ),
        child: child,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.name,
              size: IconSize.md,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                TextFormField(
                  key: widget.fieldKey,
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  validator: widget.validator,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: Spacing.xs,
                    ),
                    hintText: widget.hint,
                    hintStyle: context.bodyMdBold.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  style: context.bodyMdBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
