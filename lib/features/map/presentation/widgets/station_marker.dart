import 'package:flutter/material.dart';

import '../../domain/entities/station.dart';

/// A marker widget representing a bike station on the map.
///
/// Displays a blue rounded container with a location icon and
/// the ratio of available bikes to total capacity (e.g., "5 / 8").
class StationMarker extends StatelessWidget {
  final Station station;
  final VoidCallback? onTap;
  final bool isSelected;

  // Blue color from Figma design
  static const _markerColor = Color(0xFF155DFC);

  const StationMarker({
    super.key,
    required this.station,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _markerColor,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              '${station.availableBikes} / ${station.capacity}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
