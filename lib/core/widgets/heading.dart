import 'package:flutter/widgets.dart';

/// A heading to screen readers: its own node, so it never merges into the
/// content below, and VoiceOver's Headings rotor can jump to it.
class Heading extends StatelessWidget {
  const Heading({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(header: true, container: true, child: child);
}
