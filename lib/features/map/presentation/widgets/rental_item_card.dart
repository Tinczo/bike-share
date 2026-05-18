import 'package:flutter/material.dart';

import '../../../rental/domain/entities/rental.dart';
import '../../../rental/domain/entities/rental_status.dart';

/// Card widget displaying a rental item in the active rentals bottom sheet.
class RentalItemCard extends StatelessWidget {
  /// The rental to display.
  final Rental rental;

  /// Callback when "Zakończ" (end) button is tapped.
  final VoidCallback? onEnd;

  /// Callback when "Odblokuj" (unlock/resume) button is tapped.
  final VoidCallback? onUnlock;

  /// Callback when "Zgłoś problem" (report issue) button is tapped.
  final VoidCallback? onReportIssue;

  /// Whether the card is in a loading state (during pause/resume operations).
  final bool isLoading;

  const RentalItemCard({
    super.key,
    required this.rental,
    this.onEnd,
    this.onUnlock,
    this.onReportIssue,
    this.isLoading = false,
  });

  // Colors from Figma design
  static const _activeGreen = Color(0xFF00A63E);
  static const _pausedOrange = Color(0xFFF54900);
  static const _activeBadgeBg = Color(0xFFF0FDF4);
  static const _pausedBadgeBg = Color(0xFFFFF7ED);
  static const _cardBackground = Color(0xFFF9FAFB);
  static const _cardBorder = Color(0xFFE5E7EB);
  static const _iconCircleBg = Color(0xFFFFEDD4);
  static const _primaryOrange = Color(0xFFFF6900);
  static const _unlockGreen = Color(0xFF00C950);
  static const _outlinedOrange = Color(0xFFF54900);
  static const _textSecondary = Color(0xFF6B7280);

  bool get _isPaused => rental.status == RentalStatus.paused;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildDurationAndCost(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Bike icon with orange background
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: _iconCircleBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_bike,
            color: _primaryOrange,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        // Bike ID
        Expanded(
          child: Text(
            'Rower #${rental.bikeId}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        // Status badge
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isActive = !_isPaused;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? _activeBadgeBg : _pausedBadgeBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Aktywny' : 'Na postoju',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? _activeGreen : _pausedOrange,
        ),
      ),
    );
  }

  Widget _buildDurationAndCost() {
    final duration = rental.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    String durationText;
    if (hours > 0) {
      durationText = '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      durationText = '${minutes}min ${seconds}s';
    } else {
      durationText = '${seconds}s';
    }

    String cost;
    cost = (duration.inMinutes * 0.50).toStringAsFixed(2);

    return Row(
      children: [
        // Duration
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: _textSecondary),
            const SizedBox(width: 4),
            Text(
              durationText,
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        // Cost
        Row(
          children: [
            Icon(Icons.payments_outlined, size: 16, color: _textSecondary),
            const SizedBox(width: 4),
            Text(
              '$cost zł',
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // "Zgłoś problem" button (outlined)
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onReportIssue,
            style: OutlinedButton.styleFrom(
              foregroundColor: _outlinedOrange,
              side: BorderSide(
                color: isLoading ? _cardBorder : _outlinedOrange,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Zgłoś problem',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // "Zakończ" or "Odblokuj" button (filled)
        Expanded(
          child: FilledButton(
            onPressed: isLoading ? null : (_isPaused ? onUnlock : onEnd),
            style: FilledButton.styleFrom(
              backgroundColor: _isPaused ? _unlockGreen : _primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isPaused ? 'Odblokuj' : 'Zakończ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
