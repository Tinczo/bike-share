import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../../map/presentation/bloc/map_bloc.dart';
import '../../domain/entities/rental_launch_method.dart';
import '../bloc/rental_bloc.dart';
import '../bloc/reservation_bloc.dart';

/// Screen showing an active reservation with countdown.
class ReservationScreen extends StatefulWidget {
  final String bikeId;

  const ReservationScreen({super.key, required this.bikeId});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch event only once when screen is first created
    // (not on every rebuild like in build() method)
    sl<ReservationBloc>().add(ReservationCreated(bikeId: widget.bikeId));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ReservationBloc>()),
        BlocProvider.value(value: sl<RentalBloc>()),
      ],
      child: _ReservationScreenContent(bikeId: widget.bikeId),
    );
  }
}

class _ReservationScreenContent extends StatelessWidget {
  final String bikeId;

  const _ReservationScreenContent({required this.bikeId});

  // Color constants matching Figma design
  static const _primaryOrange = Color(0xFFFF6900);
  static const _gradientEnd = Color(0xFFF54900);
  static const _scaffoldBg = Color(0xFFF3F4F6);
  static const _iconCircleBg = Color(0xFFDBEAFE);
  static const _infoBg = Color(0xFFEFF6FF);
  static const _infoBorder = Color(0xFFBEDBFF);
  static const _cancelRed = Color(0xFFFB2C36);
  static const _textSecondary = Color(0xFF4A5565);
  static const _textPrimary = Color(0xFF101828);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        title: const Text('Aktywna rezerwacja'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.pop(true); // Return true to indicate reservation exists
          },
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen for reservation state changes (failures, expired, cancelled)
          BlocListener<ReservationBloc, ReservationState>(
            listener: (context, state) {
              if (state is ReservationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
              if (state is ReservationExpiredState) {
                _showExpiredDialog(context);
              }
              if (state is ReservationCancelledState) {
                // Refresh map to show bike as available again (green)
                sl<MapBloc>().add(const RefreshMapRequested());
                context.pop();
              }
            },
          ),
          // Only refresh map when FIRST transitioning to active state
          // (not on every timer tick)
          BlocListener<ReservationBloc, ReservationState>(
            listenWhen: (previous, current) =>
                previous is! ReservationActiveState &&
                current is ReservationActiveState,
            listener: (context, state) {
              // Refresh map to show bike as reserved (blue)
              sl<MapBloc>().add(const RefreshMapRequested());
            },
          ),
          BlocListener<RentalBloc, RentalState>(
            // Only react to transitions TO RentalActive, not existing state
            listenWhen: (previous, current) =>
                previous is! RentalActive && current is RentalActive,
            listener: (context, state) {
              if (state is RentalFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
              if (state is RentalActive) {
                // Clear reservation state since rental has started
                context.read<ReservationBloc>().add(const ReservationCleared());
                // Refresh map to show bike as rented (orange)
                sl<MapBloc>().add(const RefreshMapRequested());
                context.go('/');
              }
              if (state is RentalIneligible) {
                _showIneligibleDialog(context, state.eligibility.reason);
              }
            },
          ),
        ],
        child: BlocBuilder<ReservationBloc, ReservationState>(
          builder: (context, state) {
            if (state is ReservationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReservationActiveState) {
              return _buildActiveContent(context, state);
            }

            if (state is ReservationExpiredState) {
              return _buildExpiredContent(context);
            }

            return const Center(child: Text('No active reservation'));
          },
        ),
      ),
    );
  }

  Widget _buildActiveContent(
    BuildContext context,
    ReservationActiveState state,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCountdownCard(state.remainingTime),
            const SizedBox(height: 24),
            _buildBikeInfoCard(state.reservation.bikeId),
            const SizedBox(height: 24),
            _buildInfoTipCard(),
            const Spacer(),
            _buildActionButtons(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownCard(Duration remainingTime) {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds.remainder(60);
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryOrange, _gradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryOrange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.access_time, size: 48, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            'Pozostały czas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeString,
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rezerwacja wygasa automatycznie',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBikeInfoCard(String bikeId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: _iconCircleBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bike,
                  size: 32,
                  color: Color(0xFF155DFC),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Twój rower',
                    style: TextStyle(fontSize: 14, color: _textSecondary),
                  ),
                  Text(
                    'Rower #$bikeId',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'jest zarezerwowany i czeka na Ciebie',
            style: TextStyle(fontSize: 14, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _infoBg,
        border: Border.all(color: _infoBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        '💡 Znajdź rower na mapie i zeskanuj kod QR, aby rozpocząć przejazd',
        style: TextStyle(fontSize: 14, color: Color(0xFF364153)),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ReservationActiveState state,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () => _startRental(context),
            style: FilledButton.styleFrom(
              backgroundColor: _primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Rozpocznij przejazd',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => _showCancelConfirmation(context, state),
            style: OutlinedButton.styleFrom(
              foregroundColor: _cancelRed,
              side: const BorderSide(color: _cancelRed),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Anuluj rezerwację',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiredContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer_off,
                      size: 60,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Reservation Expired',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your reservation has expired. The bike is now '
                    'available for others.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => context.go('/'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Find Another Bike'),
            ),
          ],
        ),
      ),
    );
  }

  void _startRental(BuildContext context) {
    final rentalState = context.read<RentalBloc>().state;
    if (rentalState is RentalActive || rentalState is RentalPaused) {
      _showActiveRentalWarningDialog(context);
      return;
    }

    context.read<RentalBloc>().add(
      RentalStartWithCheckRequested(
        bikeId: bikeId,
        method: RentalLaunchMethod.manual,
      ),
    );
  }

  void _showActiveRentalWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFFFF6900)),
        title: const Text('Masz aktywny przejazd'),
        content: const Text(
          'Nie możesz rozpocząć nowego przejazdu, ponieważ masz już aktywne wypożyczenie. '
          'Zakończ bieżący przejazd, aby móc wypożyczyć nowy rower.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Rozumiem'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.pop(); // Go back from reservation screen
              context.go('/'); // Navigate to home where active rental is shown
            },
            child: const Text('Przejdź do przejazdu'),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(
    BuildContext context,
    ReservationActiveState state,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Anulować rezerwację?'),
        content: const Text(
          'Czy na pewno chcesz anulować tę rezerwację? '
          'Rower stanie się dostępny dla innych użytkowników.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Zachowaj rezerwację'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ReservationBloc>().add(
                ReservationCancelled(reservationId: state.reservation.id),
              );
            },
            child: const Text('Anuluj rezerwację'),
          ),
        ],
      ),
    );
  }

  void _showExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.timer_off, size: 48, color: Colors.red),
        title: const Text('Reservation Expired'),
        content: const Text(
          'Your 15-minute reservation window has ended. '
          'Would you like to find another bike?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.pop();
            },
            child: const Text('Go Back'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/');
            },
            child: const Text('Find Another Bike'),
          ),
        ],
      ),
    );
  }

  void _showIneligibleDialog(BuildContext context, String? reason) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.block, size: 48, color: Colors.red),
        title: const Text('Cannot Start Rental'),
        content: Text(
          reason ??
              'You are not eligible to rent at this time. '
                  'Please check your account status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.push('/wallet');
            },
            child: const Text('Go to Wallet'),
          ),
        ],
      ),
    );
  }
}
