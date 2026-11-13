import 'package:flutter/widgets.dart';

/// A heading to screen readers: its own node, so it never merges into the
/// content below, and VoiceOver's Headings rotor can jump to it.
class Heading extends StatelessWidget {
  const Heading({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// False leaves [child] as plain text, for a widget whose text is a
  /// title in one place only.
  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      enabled ? Semantics(header: true, container: true, child: child) : child;
}
