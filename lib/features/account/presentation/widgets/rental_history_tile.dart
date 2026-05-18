import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/rental_history_item.dart';

/// Tile displaying a rental history item with duration and cost.
class RentalHistoryTile extends StatelessWidget {
  final RentalHistoryItem rental;
  final VoidCallback? onTap;

  const RentalHistoryTile({super.key, required this.rental, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');

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
                      dateFormat.format(rental.startTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.labelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${timeFormat.format(rental.startTime)} - '
                      '${timeFormat.format(rental.endTime)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppPalette.hintColor,
                      ),
                    ),
                    if (rental.startStationName != null ||
                        rental.endStationName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _buildStationText(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppPalette.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${rental.cost.toStringAsFixed(2)} zl',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.labelColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(rental.duration),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppPalette.hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    const color = AppPalette.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.directions_bike, color: color, size: 24),
    );
  }

  String _buildStationText() {
    final start = rental.startStationName ?? '?';
    final end = rental.endStationName ?? '?';
    return '$start → $end';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}
