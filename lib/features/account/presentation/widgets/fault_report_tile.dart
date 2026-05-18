import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/fault_report.dart';
import '../../domain/entities/fault_type.dart';

/// Tile displaying a fault report with status and optional reward.
class FaultReportTile extends StatelessWidget {
  final FaultReport faultReport;
  final VoidCallback? onTap;

  const FaultReportTile({super.key, required this.faultReport, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faultReport.type.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.labelColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rower: ${faultReport.bikeId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppPalette.hintColor,
                      ),
                    ),
                    if (faultReport.timestamp != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        dateFormat.format(faultReport.timestamp!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppPalette.hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusChip(),
                  if (faultReport.rewardAmount != null &&
                      faultReport.rewardAmount! > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+${faultReport.rewardAmount!.toStringAsFixed(2)} zl',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconData = _getIconForType(faultReport.type);
    const color = AppPalette.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  Widget _buildStatusChip() {
    final (label, color) = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  (String, Color) _getStatusInfo() {
    if (faultReport.isConfirmed) {
      return ('Potwierdzone', Colors.green);
    } else if (faultReport.isVerified && !faultReport.isConfirmed) {
      return ('Odrzucone', Colors.red);
    } else {
      return ('Oczekujace', Colors.orange);
    }
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
