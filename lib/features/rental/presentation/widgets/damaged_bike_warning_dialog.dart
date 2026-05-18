import 'package:flutter/material.dart';

/// Dialog warning about a potentially damaged bike.
class DamagedBikeWarningDialog extends StatelessWidget {
  /// Callback when user confirms to proceed anyway.
  final VoidCallback onProceed;

  /// Callback when user chooses to select another bike.
  final VoidCallback onSelectAnother;

  const DamagedBikeWarningDialog({
    super.key,
    required this.onProceed,
    required this.onSelectAnother,
  });

  /// Shows the damaged bike warning dialog.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onProceed,
    required VoidCallback onSelectAnother,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DamagedBikeWarningDialog(
        onProceed: onProceed,
        onSelectAnother: onSelectAnother,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        size: 48,
        color: Colors.orange,
      ),
      title: const Text('Bike May Be Damaged'),
      content: const Text(
        'This bike has been reported as potentially damaged by a previous '
        'user. You may proceed, but please inspect the bike before riding.\n\n'
        'If you find any issues, please report them after ending your rental.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onSelectAnother();
          },
          child: const Text('Select Another'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onProceed();
          },
          child: const Text('Proceed Anyway'),
        ),
      ],
    );
  }
}
