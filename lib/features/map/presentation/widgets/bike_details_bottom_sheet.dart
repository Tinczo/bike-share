import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/bike.dart';
import '../../../rental/presentation/bloc/rental_bloc.dart';
import '../../../rental/presentation/bloc/reservation_bloc.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../domain/entities/bike_status.dart';
import '../../../rental/presentation/widgets/damaged_bike_warning_dialog.dart';

/// A bottom sheet displaying detailed information about a selected bike.
///
/// Displays bike information in Polish with status, battery level
/// (for electric bikes), and pricing information. Features a slide-up
/// entrance animation and can be dismissed by dragging down.
class BikeDetailsBottomSheet extends StatefulWidget {
  final Bike bike;
  final VoidCallback? onClose;
  final bool isDismissRequested;

  const BikeDetailsBottomSheet({
    super.key,
    required this.bike,
    this.onClose,
    this.isDismissRequested = false,
  });

  @override
  State<BikeDetailsBottomSheet> createState() => _BikeDetailsBottomSheetState();
}

class _BikeDetailsBottomSheetState extends State<BikeDetailsBottomSheet>
    with SingleTickerProviderStateMixin {
  // UI Colors matching Figma design
  static const _rowBackgroundColor = Color(0xFFF9FAFB);
  static const _pricingBackgroundColor = Color(0xFFEFF6FF);
  static const _pricingBorderColor = Color(0xFFBEDBFF);
  static const _primaryBlue = Color(0xFF155DFC);
  static const _rentButtonOrange = Color(0xFFFF6900);

  // Status colors
  static const _statusAvailable = Color(0xFF00A63E);
  static const _statusRented = Colors.orange;
  static const _statusReserved = Colors.blue;
  static const _statusBroken = Colors.red;

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
  void didUpdateWidget(BikeDetailsBottomSheet oldWidget) {
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

              // Large circular bike icon with gradient
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bike,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),

              // Title "Rower #X"
              Text(
                'Rower #${widget.bike.qrCode}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Content with padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Battery row (only for electric bikes)
                    if (widget.bike.batteryLevel != null) ...[
                      _buildInfoRow(
                        icon: Icons.battery_charging_full,
                        iconColor: _primaryBlue,
                        label: 'Bateria',
                        value: '${widget.bike.batteryLevel}%',
                        valueColor: _getBatteryColor(widget.bike.batteryLevel!),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Status row
                    _buildInfoRow(
                      icon: Icons.info_outline,
                      iconColor: Colors.grey[600]!,
                      label: 'Status',
                      value: _getStatusText(),
                      valueColor: _getStatusColor(),
                    ),
                    const SizedBox(height: 12),

                    // Pricing row (Cennik)
                    _buildPricingRow(),
                    const SizedBox(height: 16),

                    // Action buttons (only for available bikes)
                    if (widget.bike.status == BikeStatus.available) ...[
                      Row(
                        children: [
                          // Reserve button (outlined)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _handleReserveBike(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _primaryBlue,
                                side: const BorderSide(color: _primaryBlue),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Rezerwuj',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Rent button (filled orange)
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _handleRentBike(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: _rentButtonOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Wypożycz',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Report fault button - always visible
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/fault/report/${widget.bike.id}'),
                      icon: const Icon(Icons.report_problem_outlined, size: 18),
                      label: const Text('Zglos usterke'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
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

  Widget _buildPricingRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _pricingBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pricingBorderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, color: _primaryBlue, size: 20),
          const SizedBox(width: 12),
          Text(
            'Cennik',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Text(
            '0,50 zł / min',
            style: TextStyle(
              fontSize: 15,
              color: _primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    return switch (widget.bike.status) {
      BikeStatus.available => _statusAvailable,
      BikeStatus.rented => _statusRented,
      BikeStatus.reserved => _statusReserved,
      BikeStatus.broken => _statusBroken,
    };
  }

  String _getStatusText() {
    return switch (widget.bike.status) {
      BikeStatus.available => 'Dostępny',
      BikeStatus.rented => 'Wypożyczony',
      BikeStatus.reserved => 'Zarezerwowany',
      BikeStatus.broken => 'Niedostępny',
    };
  }

  Color _getBatteryColor(int level) {
    if (level >= 60) return _statusAvailable;
    if (level >= 30) return Colors.orange;
    return Colors.red;
  }

  void _handleRentBike(BuildContext context) {
    final rentalState = context.read<RentalBloc>().state;
    if (rentalState is RentalActive || rentalState is RentalPaused) {
      _showActiveRentalDialog(context);
      return;
    }

    if (widget.bike.isPotentiallyDamaged) {
      DamagedBikeWarningDialog.show(
        context,
        onProceed: () => context.push('/rental/scan'),
        onSelectAnother: () {},
      );
    } else {
      context.push('/rental/scan');
    }
  }

  void _handleReserveBike(BuildContext context) {
    final reservationState = context.read<ReservationBloc>().state;

    if (reservationState is ReservationActiveState) {
      _showActiveReservationDialog(context);
      return;
    }

    // Check if user has sufficient balance (minimum 5 PLN required)
    final walletState = sl<WalletBloc>().state;
    if (walletState is WalletLoaded && walletState.wallet.balance < 5) {
      _showInsufficientBalanceDialog(context);
      return;
    }

    if (widget.bike.isPotentiallyDamaged) {
      DamagedBikeWarningDialog.show(
        context,
        onProceed: () => _navigateToReservation(context),
        onSelectAnother: () {},
      );
    } else {
      _navigateToReservation(context);
    }
  }

  void _navigateToReservation(BuildContext context) {
    context.push<bool>('/reservation/${widget.bike.id}').then((result) {
      if (result == true && context.mounted) {
        context.read<ReservationBloc>().add(const ActiveReservationLoaded());
      }
    });
  }

  void _showActiveRentalDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.info_outline,
          size: 48,
          color: _rentButtonOrange,
        ),
        title: const Text('Masz aktywne wypożyczenie'),
        content: const Text('Zakończ obecne wypożyczenie, aby rozpocząć nowe.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: FilledButton.styleFrom(backgroundColor: _rentButtonOrange),
            child: const Text('Rozumiem'),
          ),
        ],
      ),
    );
  }

  void _showActiveReservationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.info_outline, size: 48, color: _primaryBlue),
        title: const Text('Masz aktywną rezerwację'),
        content: const Text(
          'Anuluj obecną rezerwację lub wypożycz zarezerwowany rower.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: FilledButton.styleFrom(backgroundColor: _primaryBlue),
            child: const Text('Rozumiem'),
          ),
        ],
      ),
    );
  }

  void _showInsufficientBalanceDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.account_balance_wallet,
          size: 48,
          color: _rentButtonOrange,
        ),
        title: const Text('Niewystarczające środki'),
        content: const Text(
          'Aby dokonać rezerwacji, musisz mieć co najmniej 5 zł na koncie.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.push('/wallet/');
            },
            style: FilledButton.styleFrom(backgroundColor: _rentButtonOrange),
            child: const Text('Doładuj konto'),
          ),
        ],
      ),
    );
  }
}
