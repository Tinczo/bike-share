import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../bloc/rental_bloc.dart';

/// Screen showing return options after the bike has been locked.
///
/// User can either make a stop (postój) and return to the map,
/// or return the bike and end the rental.
class ReturnOptionsScreen extends StatelessWidget {
  final String rentalId;
  final String bikeId;

  const ReturnOptionsScreen({
    super.key,
    required this.rentalId,
    required this.bikeId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<RentalBloc>(),
      child: _ReturnOptionsScreenContent(rentalId: rentalId, bikeId: bikeId),
    );
  }
}

class _ReturnOptionsScreenContent extends StatelessWidget {
  final String rentalId;
  final String bikeId;

  const _ReturnOptionsScreenContent({
    required this.rentalId,
    required this.bikeId,
  });

  // Colors from Figma design
  static const _greenBackground = Color(0xFFDCFCE7);
  static const _greenIcon = Color(0xFF00A63E);
  static const _blueInfoBackground = Color(0xFFEFF6FF);
  static const _blueInfoBorder = Color(0xFFBEDBFF);
  static const _orangeIconBackground = Color(0xFFFFEDD4);
  static const _textPrimary = Color(0xFF101828);
  static const _textSecondary = Color(0xFF4A5565);
  static const _textTertiary = Color(0xFF364153);

  @override
  Widget build(BuildContext context) {
    return BlocListener<RentalBloc, RentalState>(
      listener: (context, state) {
        if (state is RentalEnded) {
          context.go('/rental/summary/${state.rental.id}');
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
          title: const Text('Rower zablokowany'),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<RentalBloc, RentalState>(
          builder: (context, state) {
            final isLoading = state is RentalEnding;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildSuccessIcon(),
                    const SizedBox(height: 24),
                    _buildBikeInfoCard(),
                    const SizedBox(height: 24),
                    _buildInfoBanner(),
                    const SizedBox(height: 12),
                    _buildPostojCard(context, isLoading),
                    const SizedBox(height: 12),
                    _buildReturnCard(context, isLoading),
                    const SizedBox(height: 12),
                    _buildWarningTip(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: _greenBackground,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: _greenIcon,
        size: 48,
      ),
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
          const SizedBox(height: 8),
          const Text(
            'Bezpiecznie zablokowany',
            style: TextStyle(
              fontSize: 14,
              color: _greenIcon,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _blueInfoBackground,
        border: Border.all(color: _blueInfoBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppPalette.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nie jesteś przy stacji',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Możesz zrobić postój i wrócić do roweru później, lub zakończyć wypożyczenie.',
                  style: TextStyle(
                    fontSize: 16,
                    color: _textTertiary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostojCard(BuildContext context, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppPalette.tileBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: _orangeIconBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pause_circle_outline,
                  color: AppPalette.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Postój',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rower pozostaje przypisany do Ciebie. Czas nadal jest naliczany.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: isLoading ? null : () => context.go('/'),
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Zrób postój',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnCard(BuildContext context, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppPalette.tileBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppPalette.subtitleBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: AppPalette.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zwróć rower',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Zakończ wypożyczenie i zapłać za przejazd. Może być naliczona dodatkowa opłata za zwrot poza stacją.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: isLoading ? null : () => _handleEndRental(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppPalette.primaryBlue,
                side: const BorderSide(color: AppPalette.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppPalette.primaryBlue,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Zwróć i zakończ',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppPalette.warningBackground,
        border: Border.all(color: AppPalette.warningBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        '💡 Zwrot przy stacji jest bez dodatkowych opłat',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: _textTertiary,
        ),
      ),
    );
  }

  void _handleEndRental(BuildContext context) {
    context.read<RentalBloc>().add(RentalEndRequested(rentalId: rentalId));
  }
}
