import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/payment_method.dart';

/// Tile displaying a saved payment method.
class PaymentMethodTile extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PaymentMethodTile({
    super.key,
    required this.paymentMethod,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.tileBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMethodName(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.labelColor,
                      ),
                    ),
                    if (paymentMethod.lastFourDigits != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '•••• ${paymentMethod.lastFourDigits}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppPalette.paragraphColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppPalette.hintColor,
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;

    switch (paymentMethod.type) {
      case PaymentMethodType.card:
        iconData = Icons.credit_card;
      case PaymentMethodType.blik:
        iconData = Icons.smartphone;
      case PaymentMethodType.transfer:
        iconData = Icons.account_balance;
    }

    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B7FFF), AppPalette.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(iconData, color: Colors.white, size: 20),
    );
  }

  String _getMethodName() {
    switch (paymentMethod.type) {
      case PaymentMethodType.card:
        return paymentMethod.cardBrand ?? 'Karta';
      case PaymentMethodType.blik:
        return 'BLIK';
      case PaymentMethodType.transfer:
        return 'Przelew';
    }
  }
}
