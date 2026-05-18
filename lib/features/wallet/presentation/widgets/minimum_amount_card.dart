import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Card displaying minimum top-up amount required to cover debt.
class MinimumAmountCard extends StatelessWidget {
  final double minimumAmount;

  const MinimumAmountCard({super.key, required this.minimumAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minimalna kwota doladowania',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AppPalette.labelColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.warningBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.warningBorder,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Musisz doladowac co najmniej',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppPalette.paragraphColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${minimumAmount.toStringAsFixed(2)} zl',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFF54900),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Po doladowaniu konta zostanie automatycznie uregulowany dlug',
            style: TextStyle(
              fontSize: 14,
              color: AppPalette.paragraphColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
