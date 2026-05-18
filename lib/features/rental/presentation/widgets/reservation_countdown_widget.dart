import 'package:flutter/material.dart';

/// Widget that displays a countdown for a reservation.
class ReservationCountdownWidget extends StatelessWidget {
  /// Remaining time until reservation expires.
  final Duration remainingTime;

  /// Text style for the countdown display.
  final TextStyle? style;

  const ReservationCountdownWidget({
    super.key,
    required this.remainingTime,
    this.style,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLow = remainingTime.inMinutes < 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatDuration(remainingTime),
          style:
              style ??
              Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLow ? Colors.red : null,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'time remaining',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isLow ? Colors.red : Colors.grey,
          ),
        ),
      ],
    );
  }
}
