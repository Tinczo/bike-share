import 'package:flutter/material.dart';

import '../../../rental/domain/entities/reservation.dart';

/// Card widget displaying a reservation item in the active rentals bottom sheet.
class ReservationItemCard extends StatelessWidget {
  /// The reservation to display.
  final Reservation reservation;

  /// Remaining time until reservation expires.
  final Duration remainingTime;

  /// Callback when "Wypożycz" (rent) button is tapped.
  final VoidCallback? onRent;

  /// Callback when "Anuluj" (cancel) button is tapped.
  final VoidCallback? onCancel;

  /// Whether the card is in a loading state (during rental start operations).
  final bool isLoading;

  const ReservationItemCard({
    super.key,
    required this.reservation,
    required this.remainingTime,
    this.onRent,
    this.onCancel,
    this.isLoading = false,
  });

  // Colors from Figma design
  static const _reservedBlue = Color(0xFF155DFC);
  static const _reservedBadgeBg = Color(0xFFEFF6FF);
  static const _cardBackground = Color(0xFFF9FAFB);
  static const _cardBorder = Color(0xFFE5E7EB);
  static const _iconCircleBg = Color(0xFFDBEAFE);
  static const _primaryOrange = Color(0xFFFF6900);
  static const _textSecondary = Color(0xFF6B7280);
  static const _warningRed = Color(0xFFDC2626);

  bool get _isLowTime => remainingTime.inMinutes < 2;

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
          _buildCountdown(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Bike icon with blue background
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: _iconCircleBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_bike,
            color: _reservedBlue,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        // Bike ID
        Expanded(
          child: Text(
            'Rower #${reservation.bikeId}',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _reservedBadgeBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Zarezerwowany',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _reservedBlue,
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds.remainder(60);
    final formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 16,
          color: _isLowTime ? _warningRed : _textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          'Pozostało: ',
          style: TextStyle(
            fontSize: 14,
            color: _isLowTime ? _warningRed : _textSecondary,
          ),
        ),
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _isLowTime ? _warningRed : _textSecondary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // "Anuluj" button (outlined)
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: _textSecondary,
              side: const BorderSide(color: _cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Anuluj',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // "Wypożycz" button (filled orange)
        Expanded(
          child: FilledButton(
            onPressed: isLoading ? null : onRent,
            style: FilledButton.styleFrom(
              backgroundColor: _primaryOrange,
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
                : const Text(
                    'Wypożycz',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
          ),
        ),
      ],
    );
  }
}
