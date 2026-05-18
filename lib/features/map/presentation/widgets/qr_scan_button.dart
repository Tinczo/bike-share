import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../rental/presentation/bloc/rental_bloc.dart';

/// A full-width orange button for scanning QR codes to start a rental.
class QrScanButton extends StatelessWidget {
  const QrScanButton({super.key});

  static const _buttonColor = Color(0xFFFF6900);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalBloc, RentalState>(
      builder: (context, state) {
        final hasActiveRental = state is RentalActive || state is RentalPaused;

        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: hasActiveRental
                ? () => _showActiveRentalDialog(context)
                : () => context.push('/rental/scan'),
            style: FilledButton.styleFrom(
              backgroundColor: _buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner, size: 24),
            label: const Text(
              'Skanuj QR, aby wypożyczyć',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  void _showActiveRentalDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.info_outline, size: 48, color: _buttonColor),
        title: const Text('Masz aktywne wypożyczenie'),
        content: const Text(
          'Zakończ obecne wypożyczenie, aby rozpocząć nowe.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: FilledButton.styleFrom(backgroundColor: _buttonColor),
            child: const Text('Rozumiem'),
          ),
        ],
      ),
    );
  }
}
