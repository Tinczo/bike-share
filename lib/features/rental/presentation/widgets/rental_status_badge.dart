import 'package:flutter/material.dart';

import '../../domain/entities/rental_status.dart';

/// Badge displaying the current rental status.
class RentalStatusBadge extends StatelessWidget {
  final RentalStatus status;

  const RentalStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      RentalStatus.active => (Colors.green, 'ACTIVE'),
      RentalStatus.paused => (Colors.orange, 'PAUSED'),
      RentalStatus.finished => (Colors.grey, 'ENDED'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
