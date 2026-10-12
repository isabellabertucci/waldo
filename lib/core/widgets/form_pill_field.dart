import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/dashed_border.dart';

/// A form field in a filled pill: a leading disc, a label over the input, and
/// an optional trailing tag. An ink stitch and an ink disc mark it as focused.
class FormPillField extends StatefulWidget {
  const FormPillField({
    super.key,
    required this.leading,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    required this.validator,
    this.trailing,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.fieldKey,
  });

  /// An [Icon] or a short [Text] (e.g. a currency symbol) shown in the disc.
  final Widget leading;
  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String> validator;

  /// A short tag at the end of the pill, e.g. a currency code.
  final String? trailing;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  /// Put on the inner [TextFormField], so tests can type into it.
  final Key? fieldKey;

  @override
  State<FormPillField> createState() => _FormPillFieldState();
}

class _FormPillFieldState extends State<FormPillField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final trailing = widget.trailing;

    return ListenableBuilder(
      listenable: _focusNode,
      builder: (context, _) {
        final focused = _focusNode.hasFocus;
        final discInk = focused ? colors.onPrimary : colors.onSurface;

        return DashedBorder(
          radius: Rounded.lg,
          color: focused ? colors.primary : colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(Rounded.lg),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: focused ? colors.primary : colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: IconTheme(
                    data: IconThemeData(color: discInk, size: IconSize.md),
                    child: DefaultTextStyle(
                      style: context.bodyMdBold.copyWith(color: discInk),
                      child: widget.leading,
                    ),
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
                        enabled: widget.enabled,
                        onChanged: widget.onChanged,
                        validator: widget.validator,
                        keyboardType: widget.keyboardType,
                        inputFormatters: widget.inputFormatters,
                        textCapitalization: widget.textCapitalization,
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
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        style: context.bodyMdBold,
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: Spacing.sm),
                  Text(
                    trailing,
                    style: context.bodyMdBold.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
