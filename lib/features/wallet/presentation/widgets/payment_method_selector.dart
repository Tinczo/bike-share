import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Widget for selecting payment method (BLIK or Card).
class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MethodTile(
          label: 'BLIK',
          description: 'Szybka platnosc kodem',
          icon: Icons.smartphone,
          isSelected: selectedMethod == 'blik',
          onTap: () => onMethodSelected('blik'),
        ),
        const SizedBox(height: 12),
        _MethodTile(
          label: 'Karta platnicza',
          description: 'Visa, Mastercard',
          icon: Icons.credit_card,
          isSelected: selectedMethod == 'card',
          onTap: () => onMethodSelected('card'),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.tileBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: AppPalette.primaryBlue, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppPalette.subtitleBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppPalette.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.labelColor,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppPalette.paragraphColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppPalette.primaryBlue,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
