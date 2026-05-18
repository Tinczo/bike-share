import 'package:flutter/material.dart';

import '../../domain/entities/station.dart';

/// A bottom sheet displaying detailed information about a selected station.
///
/// Features a slide-up entrance animation and can be dismissed by dragging down
/// or by setting [isDismissRequested] to true.
class StationDetailsBottomSheet extends StatefulWidget {
  final Station station;
  final VoidCallback? onClose;
  final bool isDismissRequested;

  const StationDetailsBottomSheet({
    super.key,
    required this.station,
    this.onClose,
    this.isDismissRequested = false,
  });

  @override
  State<StationDetailsBottomSheet> createState() =>
      _StationDetailsBottomSheetState();
}

class _StationDetailsBottomSheetState extends State<StationDetailsBottomSheet>
    with SingleTickerProviderStateMixin {
  // UI Colors matching Figma design
  static const _rowBackgroundColor = Color(0xFFF9FAFB);
  static const _primaryBlue = Color(0xFF155DFC);

  // Animation
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // Drag state
  double _dragOffset = 0;
  bool _isDismissing = false;

  // Dismiss threshold in pixels
  static const _dismissThreshold = 100.0;
  // Velocity threshold for quick dismiss (pixels per second)
  static const _velocityThreshold = 500.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(StationDetailsBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDismissRequested &&
        !oldWidget.isDismissRequested &&
        !_isDismissing) {
      _dismiss();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isDismissing) return;
    setState(() {
      // Only allow dragging down (positive delta)
      _dragOffset = (_dragOffset + details.delta.dy).clamp(
        0.0,
        double.infinity,
      );
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isDismissing) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_dragOffset > _dismissThreshold || velocity > _velocityThreshold) {
      _dismiss();
    } else {
      _snapBack();
    }
  }

  void _dismiss() {
    setState(() => _isDismissing = true);
    _animationController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  void _snapBack() {
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SlideTransition(
      position: _slideAnimation,
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle - functional for dismissing
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: _handleDragUpdate,
                onVerticalDragEnd: _handleDragEnd,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),

              // Large circular station icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: _primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),

              // Station name
              Text(
                widget.station.name,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stacja rowerowa',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Available bikes row
                    _buildInfoRow(
                      icon: Icons.directions_bike,
                      iconColor: widget.station.availableBikes > 0
                          ? Colors.green
                          : Colors.red,
                      label: 'Dostępne rowery',
                      value: '${widget.station.availableBikes}',
                      valueColor: widget.station.availableBikes > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(height: 12),

                    // Empty stands row
                    _buildInfoRow(
                      icon: Icons.local_parking,
                      iconColor: widget.station.availableStands > 0
                          ? _primaryBlue
                          : Colors.orange,
                      label: 'Wolne stojaki',
                      value: '${widget.station.availableStands}',
                      valueColor: widget.station.availableStands > 0
                          ? _primaryBlue
                          : Colors.orange,
                    ),
                    const SizedBox(height: 12),

                    // Capacity indicator
                    _CapacityIndicator(
                      availableBikes: widget.station.availableBikes,
                      capacity: widget.station.capacity,
                    ),
                  ],
                ),
              ),

              // Bottom padding
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _rowBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityIndicator extends StatelessWidget {
  final int availableBikes;
  final int capacity;

  const _CapacityIndicator({
    required this.availableBikes,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const rowBackgroundColor = Color(0xFFF9FAFB);
    final percentage = capacity > 0 ? availableBikes / capacity : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: rowBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pojemność stacji',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$availableBikes / $capacity',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
