import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart';

/// Tile displaying a transaction with icon, description, and amount.
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount >= 0;
    final dateFormat = DateFormat('yyyy-MM-dd • HH:mm');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppPalette.labelColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormat.format(transaction.date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppPalette.paragraphColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isPositive ? '+' : ''}${transaction.amount.toStringAsFixed(2).replaceAll('.', ',')} zl',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: isPositive ? AppPalette.incomeGreen : AppPalette.expenseRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (transaction.type) {
      case TransactionType.topUp:
        iconData = Icons.download;
        iconColor = AppPalette.incomeGreen;
        backgroundColor = AppPalette.incomeIconBg;
      case TransactionType.fee:
        iconData = Icons.arrow_outward;
        iconColor = AppPalette.expenseRed;
        backgroundColor = AppPalette.expenseIconBg;
      case TransactionType.reward:
        iconData = Icons.account_balance;
        iconColor = AppPalette.incomeGreen;
        backgroundColor = AppPalette.incomeIconBg;
      case TransactionType.penalty:
        iconData = Icons.arrow_outward;
        iconColor = AppPalette.expenseRed;
        backgroundColor = AppPalette.expenseIconBg;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }
}
