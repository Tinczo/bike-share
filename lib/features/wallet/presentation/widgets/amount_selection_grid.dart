import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Grid for selecting top-up amount.
class AmountSelectionGrid extends StatelessWidget {
  final List<double> amounts;
  final double? selectedAmount;
  final double? minimumAmount;
  final ValueChanged<double> onAmountSelected;

  const AmountSelectionGrid({
    super.key,
    required this.amounts,
    required this.selectedAmount,
    required this.onAmountSelected,
    this.minimumAmount,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: amounts.length,
      itemBuilder: (context, index) {
        final amount = amounts[index];
        final isSelected = selectedAmount == amount;
        final isDisabled =
            minimumAmount != null &&
            (amount < minimumAmount! && index != amounts.length - 1);

        return _AmountButton(
          amount: amount,
          isSelected: isSelected,
          isDisabled: isDisabled,
          onTap: isDisabled ? null : () => onAmountSelected(amount),
        );
      },
    );
  }
}

class _AmountButton extends StatelessWidget {
  final double amount;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _AmountButton({
    required this.amount,
    required this.isSelected,
    required this.isDisabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDisabled
        ? Colors.grey.shade300
        : isSelected
        ? AppPalette.primaryBlue
        : AppPalette.primaryBlue;

    final textColor = isDisabled
        ? Colors.grey
        : isSelected
        ? Colors.white
        : AppPalette.primaryBlue;

    final backgroundColor = isSelected ? AppPalette.primaryBlue : Colors.white;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Text(
            '${amount.toInt()} zl',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
