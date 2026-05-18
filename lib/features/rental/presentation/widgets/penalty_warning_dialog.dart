import 'package:flutter/material.dart';

/// Dialog warning about a penalty for ending outside designated area.
class PenaltyWarningDialog extends StatelessWidget {
  /// The penalty amount in PLN.
  final double penaltyAmount;

  /// Callback when user confirms to end rental with penalty.
  final VoidCallback onConfirm;

  /// Callback when user chooses to continue riding.
  final VoidCallback onContinue;

  const PenaltyWarningDialog({
    super.key,
    required this.penaltyAmount,
    required this.onConfirm,
    required this.onContinue,
  });

  /// Shows the penalty warning dialog.
  static Future<void> show(
    BuildContext context, {
    required double penaltyAmount,
    required VoidCallback onConfirm,
    required VoidCallback onContinue,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PenaltyWarningDialog(
        penaltyAmount: penaltyAmount,
        onConfirm: onConfirm,
        onContinue: onContinue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.location_off, size: 48, color: Colors.red),
      title: const Text('Outside Return Zone'),
      content: Text(
        'You are outside the designated return area. '
        'Ending your rental here will incur a penalty of '
        '${penaltyAmount.toStringAsFixed(2)} PLN.\n\n'
        'Would you like to continue riding to a valid return zone?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onContinue();
          },
          child: const Text('Continue Riding'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text('End Rental (+${penaltyAmount.toStringAsFixed(2)} PLN)'),
        ),
      ],
    );
  }
}
