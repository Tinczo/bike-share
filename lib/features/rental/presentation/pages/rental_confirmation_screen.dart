import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Design constants for the rental confirmation screen.
class _ConfirmationDesign {
  static const Color primaryGreen = Color(0xFF00A63E);
  static const Color cardBackground = Colors.white;
  static const Color iconGreen = Color(0xFF00A63E);
  static const Color iconOrange = Color(0xFFFF6900);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFf9fafb);
  static const Color tipBackground = Color(0xFFeff6ff);
  static const Color tipBorder = Color(0xFFcbe2ff);

  static const double cardBorderRadius = 16;
  static const double buttonBorderRadius = 8;
  static const double buttonHeight = 56;
}

/// Screen displayed after successfully renting a bike.
///
/// Shows confirmation with bike ID, pricing info, and auto-redirects to map.
class RentalConfirmationScreen extends StatefulWidget {
  final String bikeId;
  final String rentalId;

  const RentalConfirmationScreen({
    super.key,
    required this.bikeId,
    required this.rentalId,
  });

  @override
  State<RentalConfirmationScreen> createState() =>
      _RentalConfirmationScreenState();
}

class _RentalConfirmationScreenState extends State<RentalConfirmationScreen> {
  static const int _autoRedirectSeconds = 5;
  late int _remainingSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _autoRedirectSeconds;
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _navigateToMap();
      }
    });
  }

  void _navigateToMap() {
    if (mounted) {
      context.go('/');
    }
  }

  String _extractBikeNumber() {
    // Extract number from bikeId like "BIKE-12345" -> "12345"
    if (widget.bikeId.startsWith('BIKE-')) {
      return widget.bikeId.substring(5);
    }
    return widget.bikeId;
  }

  @override
  Widget build(BuildContext context) {
    final bikeNumber = _extractBikeNumber();

    return Scaffold(
      backgroundColor: _ConfirmationDesign.primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // Success checkmark icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _ConfirmationDesign.iconGreen,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 48,
                  color: _ConfirmationDesign.iconGreen,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Wypożyczenie\npotwierdzone!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Rower #$bikeNumber został odblokowany',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),

              const SizedBox(height: 32),

              // White card with bike info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _ConfirmationDesign.cardBackground,
                  borderRadius: BorderRadius.circular(
                    _ConfirmationDesign.cardBorderRadius,
                  ),
                ),
                child: Column(
                  children: [
                    // Bike info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bike icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _ConfirmationDesign.iconGreen.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(
                            Icons.directions_bike,
                            color: _ConfirmationDesign.iconGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Bike details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Twój rower',
                              style: TextStyle(
                                color: _ConfirmationDesign.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '#$bikeNumber',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(
                      color: _ConfirmationDesign.dividerColor,
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    // Pricing info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Rate info
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.access_time,
                            label: 'Stawka',
                            value: '0,50 zł/min',
                            iconColor: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        // Start cost
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.attach_money,
                            label: 'Start',
                            value: '0,00 zł',
                            iconColor: _ConfirmationDesign.iconOrange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tip box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _ConfirmationDesign.tipBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _ConfirmationDesign.tipBorder.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: _ConfirmationDesign.iconOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Pamiętaj aby zablokować rower po zakończeniu przejazdu',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Countdown text
              Text(
                'Powrót do mapy za ${_remainingSeconds}s...',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 16),

              // Show on map button
              SizedBox(
                width: double.infinity,
                height: _ConfirmationDesign.buttonHeight,
                child: FilledButton.icon(
                  onPressed: _navigateToMap,
                  icon: Transform.rotate(
                    angle: math.pi / 4,
                    child: Icon(Icons.navigation_outlined, size: 20),
                  ),
                  label: const Text(
                    'Pokaż na mapie',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _ConfirmationDesign.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        _ConfirmationDesign.buttonBorderRadius,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = _ConfirmationDesign.textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _ConfirmationDesign.dividerColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: _ConfirmationDesign.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
