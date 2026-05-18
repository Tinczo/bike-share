import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../rental/domain/entities/rental.dart';
import '../../../rental/domain/entities/rental_eligibility.dart';
import '../../../rental/domain/entities/rental_launch_method.dart';
import '../../../rental/domain/entities/reservation.dart';
import '../../../rental/presentation/bloc/rental_bloc.dart';
import '../../../rental/presentation/bloc/reservation_bloc.dart';
import 'qr_scan_button.dart';
import 'rental_item_card.dart';
import 'reservation_item_card.dart';

/// An expandable bottom sheet showing active rentals and reservations.
///
/// Displays a QR scan button at the top, followed by a collapsible list
/// of active rental and reservation cards.
class ActiveRentalsBottomSheet extends StatefulWidget {
  const ActiveRentalsBottomSheet({super.key});

  @override
  State<ActiveRentalsBottomSheet> createState() =>
      _ActiveRentalsBottomSheetState();
}

class _ActiveRentalsBottomSheetState extends State<ActiveRentalsBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  // Animation duration
  static const _animationDuration = Duration(milliseconds: 300);

  // Cached data to preserve UI during transitional states
  Rental? _cachedRental;
  Reservation? _cachedReservation;
  Duration? _cachedRemainingTime;

  // Colors from Figma design
  static const _primaryOrange = Color(0xFFFF6900);
  static const _iconCircleBg = Color(0xFFFFEDD4);
  static const _textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RentalBloc, RentalState>(
      listener: _onRentalStateChanged,
      child: BlocBuilder<RentalBloc, RentalState>(
        builder: (context, rentalState) {
          return BlocBuilder<ReservationBloc, ReservationState>(
            builder: (context, reservationState) {
              final rental = _getRentalFromState(rentalState);
              final reservation = _getReservationFromState(
                reservationState,
                rentalState,
              );
              final remainingTime = _getRemainingTimeFromState(
                reservationState,
                rentalState,
              );
              final hasItems = rental != null || reservation != null;
              final isRentalLoading = _isRentalLoading(rentalState);
              final isReservationLoading = _isReservationLoading(rentalState);

              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildContent(
                  context,
                  rental: rental,
                  reservation: reservation,
                  remainingTime: remainingTime,
                  hasItems: hasItems,
                  isRentalLoading: isRentalLoading,
                  isReservationLoading: isReservationLoading,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onRentalStateChanged(BuildContext context, RentalState state) {
    if (state is RentalIneligible) {
      _showIneligibleDialog(context, state.eligibility);
    } else if (state is RentalFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  void _showIneligibleDialog(
    BuildContext context,
    RentalEligibility eligibility,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nie możesz wypożyczyć roweru'),
        content: Text(
          eligibility.reason ?? 'Sprawdź swój portfel i dane płatności.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Zamknij'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Navigate to wallet - user can check from there.
              context.push('/wallet');
            },
            child: const Text('Idź do portfela'),
          ),
        ],
      ),
    );
  }

  Rental? _getRentalFromState(RentalState state) {
    final rental = switch (state) {
      RentalActive(:final rental) => rental,
      RentalPaused(:final rental) => rental,
      // Preserve rental during transitional states
      RentalPausing() => _cachedRental,
      RentalResuming() => _cachedRental,
      RentalEnding() => _cachedRental,
      _ => null,
    };

    // Update cache
    if (rental != null) {
      _cachedRental = rental;
    } else if (state is RentalEnded || state is RentalInitial) {
      _cachedRental = null;
    }

    return rental;
  }

  bool _isRentalLoading(RentalState state) {
    return state is RentalPausing ||
        state is RentalResuming ||
        state is RentalEnding;
  }

  Reservation? _getReservationFromState(
    ReservationState reservationState,
    RentalState rentalState,
  ) {
    final reservation = switch (reservationState) {
      ReservationActiveState(:final reservation) => reservation,
      _ => null,
    };

    // During rental start, preserve reservation to show loading state
    final isStartingRental =
        rentalState is RentalStarting || rentalState is RentalUnlocking;

    if (reservation != null) {
      _cachedReservation = reservation;
      return reservation;
    } else if (isStartingRental && _cachedReservation != null) {
      // Keep showing reservation during rental start
      return _cachedReservation;
    }

    // Clear cache when not starting rental and no active reservation
    if (!isStartingRental) {
      _cachedReservation = null;
    }

    return null;
  }

  Duration? _getRemainingTimeFromState(
    ReservationState reservationState,
    RentalState rentalState,
  ) {
    final remainingTime = switch (reservationState) {
      ReservationActiveState(:final remainingTime) => remainingTime,
      _ => null,
    };

    // During rental start, preserve remaining time
    final isStartingRental =
        rentalState is RentalStarting || rentalState is RentalUnlocking;

    if (remainingTime != null) {
      _cachedRemainingTime = remainingTime;
      return remainingTime;
    } else if (isStartingRental && _cachedRemainingTime != null) {
      return _cachedRemainingTime;
    }

    if (!isStartingRental) {
      _cachedRemainingTime = null;
    }

    return null;
  }

  bool _isReservationLoading(RentalState rentalState) {
    return rentalState is RentalStarting ||
        rentalState is RentalUnlocking ||
        rentalState is RentalEligibilityChecking;
  }

  Widget _buildContent(
    BuildContext context, {
    required Rental? rental,
    required Reservation? reservation,
    required Duration? remainingTime,
    required bool hasItems,
    required bool isRentalLoading,
    required bool isReservationLoading,
  }) {
    return Container(
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
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Scan button
              const QrScanButton(),

              // Header row (only if there are items)
              if (hasItems) ...[
                const SizedBox(height: 16),
                _buildHeaderRow(rental, reservation),
              ],

              // Expandable content with slide animation
              if (hasItems)
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1.0,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildItemsList(
                        context,
                        rental,
                        reservation,
                        remainingTime,
                        isRentalLoading: isRentalLoading,
                        isReservationLoading: isReservationLoading,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(Rental? rental, Reservation? reservation) {
    final itemCount = (rental != null ? 1 : 0) + (reservation != null ? 1 : 0);
    final itemText = itemCount == 1 ? 'rower' : 'rowery';

    return GestureDetector(
      onTap: _toggleExpanded,
      behavior: HitTestBehavior.opaque,
      child: Row(
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
          // Title and count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktywne wypożyczenia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$itemCount $itemText',
                  style: const TextStyle(fontSize: 14, color: _textSecondary),
                ),
              ],
            ),
          ),
          // Animated chevron icon
          RotationTransition(
            turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
            child: const Icon(
              Icons.keyboard_arrow_up,
              color: _textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    Rental? rental,
    Reservation? reservation,
    Duration? remainingTime, {
    required bool isRentalLoading,
    required bool isReservationLoading,
  }) {
    return Column(
      children: [
        // Rental card
        if (rental != null)
          RentalItemCard(
            rental: rental,
            onEnd: () => _showEndRentalConfirmation(context, rental),
            onUnlock: () => _handleUnlock(context, rental),
            onReportIssue: () => _handleReportIssue(context, rental),
            isLoading: isRentalLoading,
          ),

        // Spacing between cards
        if (rental != null && reservation != null) const SizedBox(height: 12),

        // Reservation card
        if (reservation != null && remainingTime != null)
          ReservationItemCard(
            reservation: reservation,
            remainingTime: remainingTime,
            onRent: () => _handleRentFromReservation(context, reservation),
            onCancel: () =>
                _showCancelReservationConfirmation(context, reservation),
            isLoading: isReservationLoading,
          ),
      ],
    );
  }

  void _showEndRentalConfirmation(BuildContext context, Rental rental) {
    context.push('/rental/end/${rental.id}/${rental.bikeId}');
  }

  void _handleUnlock(BuildContext context, Rental rental) {
    context.read<RentalBloc>().add(RentalPauseToggled(rentalId: rental.id));
  }

  void _handleReportIssue(BuildContext context, Rental rental) {
    context.push('/fault/report/${rental.bikeId}');
  }

  void _handleRentFromReservation(
    BuildContext context,
    Reservation reservation,
  ) {
    // Early UI check for active rental (better UX before async operation).
    final currentRentalState = context.read<RentalBloc>().state;

    // Guard against loading states - don't proceed if bloc is still loading.
    // This prevents race conditions when state is being refreshed.
    if (currentRentalState is RentalLoading ||
        currentRentalState is RentalEligibilityChecking ||
        currentRentalState is RentalStarting ||
        currentRentalState is RentalUnlocking) {
      return;
    }

    if (currentRentalState is RentalActive ||
        currentRentalState is RentalPaused) {
      _showActiveRentalExistsDialog(context);
      return;
    }

    // Use RentalStartWithCheckRequested to check eligibility before starting.
    context.read<RentalBloc>().add(
      RentalStartWithCheckRequested(
        bikeId: reservation.bikeId,
        method: RentalLaunchMethod.manual,
      ),
    );
    // Cancel the reservation after starting the rental.
    context.read<ReservationBloc>().add(
      ReservationCancelled(reservationId: reservation.id),
    );
  }

  void _showActiveRentalExistsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Masz aktywne wypożyczenie'),
        content: const Text(
          'Musisz najpierw zakończyć obecne wypożyczenie, '
          'aby móc wypożyczyć nowy rower.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Rozumiem'),
          ),
        ],
      ),
    );
  }

  void _showCancelReservationConfirmation(
    BuildContext context,
    Reservation reservation,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Anulować rezerwację?'),
        content: Text(
          'Czy na pewno chcesz anulować rezerwację roweru #${reservation.bikeId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Nie'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ReservationBloc>().add(
                ReservationCancelled(reservationId: reservation.id),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Anuluj rezerwację'),
          ),
        ],
      ),
    );
  }
}
