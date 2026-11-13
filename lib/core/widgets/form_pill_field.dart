import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/theme/state_style.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/widgets/field_label.dart';

/// A form field: its label above, then a filled box with the input and an
/// optional trailing tag. A solid `accent` line marks it as focused.
class FormPillField extends StatefulWidget {
  const FormPillField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
    this.validator,
    this.trailing,
    this.prefix,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.onSubmitted,
    this.onPage = false,
    this.fieldKey,
    this.required = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;

  /// Only checked inside a [Form]. Its message shows under the pill.
  final FormFieldValidator<String>? validator;

  /// A short tag at the end of the box, e.g. a currency symbol.
  final String? trailing;

  /// A short text just before the input, e.g. an amount's sign.
  final String? prefix;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  /// Stops typing at this length; a counter shows near it.
  final int? maxLength;

  /// The keyboard's done key; also makes that key read "done".
  final ValueChanged<String>? onSubmitted;

  /// Opens the keyboard here as soon as the field shows.
  final bool autofocus;

  /// True on the page background rather than a sheet: the box fills with
  /// `surface`, like the cards around it.
  final bool onPage;

  /// Put on the inner [TextFormField], so tests can type into it.
  final Key? fieldKey;

  /// Marks the label with " *".
  final bool required;

  @override
  State<FormPillField> createState() => _FormPillFieldState();
}

/// How many lines a hint may take at accessibility sizes.
const _largeTextHintLines = 3;

class _FormPillFieldState extends State<FormPillField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Checked here rather than by the input, so the message sits under the
    // pill, like every other field's, instead of inside it.
    return FormField<String>(
      validator: (_) => widget.validator?.call(widget.controller.text),
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _pill(context, field),
            if (field.errorText case final error?) FieldError(error),
          ],
        );
      },
    );
  }

  Widget _pill(BuildContext context, FormFieldState<String> field) {
    final colors = context.appColors;
    final largeText = DynamicTypeScaler.isAccessibilitySize(context);
    final trailing = widget.trailing;
    final textField = TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onChanged: (value) {
        field.didChange(value);
        widget.onChanged?.call(value);
      },
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      maxLength: widget.maxLength,
      onFieldSubmitted: widget.onSubmitted,
      textInputAction: widget.onSubmitted == null ? null : TextInputAction.done,
      buildCounter: _nearLimitCounter,
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
        hintText: widget.hint,
        // At accessibility sizes the hint wraps rather than being cut.
        hintMaxLines: largeText ? _largeTextHintLines : null,
        // Full strength: placeholder text is still text
        // (WCAG 1.4.3); the bold ink value reads apart.
        hintStyle: context.bodyStrong.copyWith(color: colors.inkMuted),
      ),
      style: context.bodyStrong,
    );

    final prefix = widget.prefix;

    // One node, so screen readers name the field by the label above it (a
    // collapsed decoration can't take a labelText) and hear its unit.
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FieldLabel(
            widget.label,
            required: widget.required,
            style: context.bodyStrong.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: Spacing.xs),
          // A tap anywhere on the box goes to the field.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            // The field inside is what screen readers focus and tap.
            excludeFromSemantics: true,
            onTap: widget.enabled ? _focusNode.requestFocus : null,
            child: ListenableBuilder(
              listenable: _focusNode,
              builder: (context, _) {
                final side = StateStyle.focused(
                  colors,
                  focused: _focusNode.hasFocus,
                );
                return AnimatedContainer(
                  duration: context.motion(Motion.toggle),
                  width: double.infinity,
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: widget.onPage ? colors.sheet : colors.card,
                    borderRadius: BorderRadius.circular(Rounded.lg),
                    border: Border.fromBorderSide(side),
                  ),
                  child: Row(
                    children: [
                      if (prefix != null)
                        Text('$prefix ', style: context.bodyStrong),
                      Expanded(child: textField),
                      if (trailing != null) ...[
                        const SizedBox(width: Spacing.sm),
                        Text(
                          trailing,
                          style: context.bodyStrong.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A [TextField.buildCounter] that stays hidden until the text reaches 80% of
/// `maxLength`, then shows "87/100" - in `error` once the limit stops typing.
Widget? _nearLimitCounter(
  BuildContext context, {
  required int currentLength,
  required int? maxLength,
  required bool isFocused,
}) {
  if (maxLength == null || currentLength < maxLength * 0.8) return null;
  final colors = context.appColors;
  return Text(
    '$currentLength/$maxLength',
    style: context.label.copyWith(
      color: currentLength >= maxLength ? colors.negative : colors.inkMuted,
    ),
  );
}
