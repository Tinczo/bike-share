import 'package:flutter/material.dart';

import '../../domain/entities/bike.dart';
import '../../domain/entities/bike_status.dart';

/// A marker widget representing a bike on the map.
class BikeMarker extends StatelessWidget {
  final Bike bike;
  final VoidCallback? onTap;
  final bool isSelected;

  const BikeMarker({
    super.key,
    required this.bike,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getStatusColor(),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(Icons.directions_bike, color: Colors.white, size: 20),
      ),
    );
  }

  Color _getStatusColor() {
    return switch (bike.status) {
      BikeStatus.available => Colors.green,
      BikeStatus.rented => Colors.orange,
      BikeStatus.reserved => Colors.blue,
      BikeStatus.broken => Colors.red,
    };
  }
}
