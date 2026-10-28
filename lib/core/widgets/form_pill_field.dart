import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/badge_row.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/field_label.dart';

/// A form field in a filled pill: a leading disc, a label over the input, and
/// an optional trailing tag. An ink stitch and an ink disc mark it as focused.
class FormPillField extends StatefulWidget {
  const FormPillField({
    super.key,
    required this.leading,
    required this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
    this.validator,
    this.trailing,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.onSubmitted,
    this.onPage = false,
    this.fieldKey,
    this.required = false,
  });

  /// An [Icon] or a short [Text] (e.g. a currency symbol) shown in the disc.
  final Widget leading;
  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;

  /// Only checked inside a [Form].
  final FormFieldValidator<String>? validator;

  /// A short tag at the end of the pill, e.g. a currency code.
  final String? trailing;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  /// Stops typing at this length; a counter shows near it.
  final int? maxLength;

  /// The keyboard's done key; also makes that key read "done".
  final ValueChanged<String>? onSubmitted;

  /// True on the page background rather than a sheet: the pill fills with
  /// `surface`, like the cards around it, and the disc steps the other way.
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
    final colors = context.appColors;
    final largeText = DynamicTypeScaler.isAccessibilitySize(context);
    final trailing = widget.trailing;
    final tag = trailing == null
        ? null
        : Text(
            trailing,
            style: context.bodyMdBold.copyWith(color: colors.onSurfaceVariant),
          );
    final input = TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      validator: widget.validator,
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
        contentPadding: const EdgeInsets.symmetric(vertical: Spacing.xs),
        hintText: widget.hint,
        // At accessibility sizes the hint wraps rather than being cut.
        hintMaxLines: largeText ? _largeTextHintLines : null,
        // Full strength: placeholder text is still text
        // (WCAG 1.4.3); the bold ink value reads apart.
        hintStyle: context.bodyMdBold.copyWith(color: colors.onSurfaceVariant),
      ),
      style: context.bodyMdBold,
    );

    // A tap anywhere on the pill, the disc included, goes to the field.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // The field inside is what screen readers focus and tap.
      excludeFromSemantics: true,
      onTap: widget.enabled ? _focusNode.requestFocus : null,
      child: ListenableBuilder(
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
                color: widget.onPage ? colors.surface : colors.surfaceContainer,
                borderRadius: BorderRadius.circular(Rounded.lg),
              ),
              // One node, so screen readers name the field by its label (a
              // collapsed decoration can't take a labelText) and hear its unit.
              child: MergeSemantics(
                child: BadgeRow(
                  // Decorative: an icon, or a symbol the unit after repeats.
                  badge: ExcludeSemantics(
                    child: Container(
                      width: BadgeSize.md,
                      height: BadgeSize.md,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: focused
                            ? colors.primary
                            : (widget.onPage
                                  ? colors.surfaceContainer
                                  : colors.surface),
                        shape: BoxShape.circle,
                      ),
                      child: IconTheme(
                        data: IconThemeData(color: discInk, size: IconSize.md),
                        child: DefaultTextStyle(
                          style: context.bodyMdBold.copyWith(color: discInk),
                          // A symbol shrinks to stay inside the disc with large text.
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: widget.leading,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // At accessibility sizes the tag moves down beside the
                  // input, so the label keeps the whole width.
                  trailing: tag == null || largeText
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(left: Spacing.sm),
                          child: tag,
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FieldLabel(widget.label, required: widget.required),
                      if (tag != null && largeText)
                        Row(
                          children: [
                            Expanded(child: input),
                            const SizedBox(width: Spacing.sm),
                            tag,
                          ],
                        )
                      else
                        input,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
    style: context.textTheme.bodySmall?.copyWith(
      color: currentLength >= maxLength
          ? colors.error
          : colors.onSurfaceVariant,
    ),
  );
}
