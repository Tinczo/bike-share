import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../bloc/rental_bloc.dart';

/// Screen for confirming the end of a rental.
///
/// Displays bike information, safety checklist, and action buttons
/// to either lock the bike (end rental) or continue riding.
class EndRentalScreen extends StatelessWidget {
  final String rentalId;
  final String bikeId;

  const EndRentalScreen({
    super.key,
    required this.rentalId,
    required this.bikeId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<RentalBloc>(),
      child: _EndRentalScreenContent(rentalId: rentalId, bikeId: bikeId),
    );
  }
}

class _EndRentalScreenContent extends StatelessWidget {
  final String rentalId;
  final String bikeId;

  const _EndRentalScreenContent({required this.rentalId, required this.bikeId});

  // Colors from Figma design
  static const _gradientStart = Color(0xFF2B7FFF);
  static const _gradientEnd = Color(0xFF155DFC);
  static const _textPrimary = Color(0xFF101828);
  static const _textSecondary = Color(0xFF4A5565);
  static const _textTertiary = Color(0xFF364153);

  @override
  Widget build(BuildContext context) {
    return BlocListener<RentalBloc, RentalState>(
      listener: (context, state) {
        if (state is RentalPaused) {
          context.go('/rental/return-options/$rentalId/$bikeId');
        } else if (state is RentalFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppPalette.scaffoldGray,
        appBar: AppBar(
          title: const Text('Zakończ wypożyczenie'),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
        body: BlocBuilder<RentalBloc, RentalState>(
          builder: (context, state) {
            final isLoading = state is RentalPausing;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            _buildLockIcon(),
                            const SizedBox(height: 24),
                            _buildBikeInfoCard(),
                            const SizedBox(height: 24),
                            _buildWarningCard(),
                            const SizedBox(height: 24),
                            _buildActionButtons(context, isLoading),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientStart, _gradientEnd],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _gradientEnd.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.lock_outline, color: Colors.white, size: 64),
    );
  }

  Widget _buildBikeInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pedal_bike, color: _textPrimary, size: 24),
              const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          const Text(
            'Upewnij się, że rower jest zaparkowany w bezpiecznym miejscu',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: _textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.warningBackground,
        border: Border.all(color: AppPalette.warningBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppPalette.warningOrange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Przed zablokowaniem:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildChecklistItem('Zaparkuj rower w dozwolonym miejscu'),
                const SizedBox(height: 4),
                _buildChecklistItem('Upewnij się, że stoi stabilnie'),
                const SizedBox(height: 4),
                _buildChecklistItem('Zabezpiecz blokadę ramową'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: _textTertiary, height: 1.4),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: isLoading ? null : () => _handleLockBike(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppPalette.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: AppPalette.orange.withValues(alpha: 0.5),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Zablokuj rower',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: isLoading ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _textTertiary,
              side: const BorderSide(color: AppPalette.tileBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Kontynuuj jazdę',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  void _handleLockBike(BuildContext context) {
    context.read<RentalBloc>().add(RentalPauseToggled(rentalId: rentalId));
  }
}
