import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  const TextDivider({ super.key, required this.child, this.padding=10, });

  final Widget child;

  /// Horizontal spacing between the divider lines and the [child].
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.only(left: padding, right: padding),
          child: child,
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Returns [null] if the user dismissed the dialog without committing an
/// explicit choice.
Future<bool?> showConfirmationDialog(
    BuildContext context,
    { String? title, String? content })
{
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title ?? 'Confirm this action?'),
      content: (content == null) ? null : Text(title!),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel')
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm')
        ),
      ],
    ),
  );
}
