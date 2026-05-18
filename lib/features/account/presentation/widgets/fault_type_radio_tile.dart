import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/fault_type.dart';

/// Radio tile for selecting a fault type.
class FaultTypeRadioTile extends StatelessWidget {
  final FaultType type;
  final bool isSelected;
  final VoidCallback onTap;

  const FaultTypeRadioTile({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppPalette.selectedBlueBackground : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppPalette.primaryBlue
                  : AppPalette.tileBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildRadioIndicator(),
              const SizedBox(width: 12),
              Icon(
                _getIconForType(type),
                color: isSelected
                    ? AppPalette.primaryBlue
                    : AppPalette.hintColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isSelected
                        ? AppPalette.primaryBlue
                        : AppPalette.labelColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioIndicator() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppPalette.primaryBlue : AppPalette.tileBorder,
          width: 1,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.primaryBlue,
                ),
              ),
            )
          : null,
    );
  }

  IconData _getIconForType(FaultType type) {
    return switch (type) {
      FaultType.flatTire => Icons.circle_outlined,
      FaultType.brokenChain => Icons.link_off,
      FaultType.faultyBrakes => Icons.pan_tool,
      FaultType.damagedFrame => Icons.construction,
      FaultType.brokenBell => Icons.notifications_off,
      FaultType.damagedLights => Icons.lightbulb_outline,
      FaultType.other => Icons.more_horiz,
    };
  }
}
