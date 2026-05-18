import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/rental.dart';
import '../bloc/rental_bloc.dart';

/// Screen showing the rental summary after completion.
class RentalSummaryScreen extends StatelessWidget {
  final String rentalId;

  const RentalSummaryScreen({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<RentalBloc>(),
      child: _RentalSummaryScreenContent(rentalId: rentalId),
    );
  }
}

class _RentalSummaryScreenContent extends StatelessWidget {
  final String rentalId;

  const _RentalSummaryScreenContent({required this.rentalId});

  static const _polishMonths = [
    'stycznia',
    'lutego',
    'marca',
    'kwietnia',
    'maja',
    'czerwca',
    'lipca',
    'sierpnia',
    'września',
    'października',
    'listopada',
    'grudnia',
  ];

  String _formatPolishDate(DateTime date) {
    return '${date.day} ${_polishMonths[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RentalBloc, RentalState>(
        builder: (context, state) {
          if (state is RentalLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RentalEnded) {
            return _buildSummary(context, state.rental);
          }

          return _buildFallbackSummary(context);
        },
      ),
    );
  }

  Widget _buildSummary(BuildContext context, Rental rental) {
    final duration = rental.duration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    final durationFormatted =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final durationText = '$minutes min';

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildStatCards(
                    durationFormatted: durationFormatted,
                    durationText: durationText,
                    cost: rental.cost,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailsCard(
                    context,
                    bikeId: rental.bikeId,
                    date: _formatPolishDate(rental.startTime),
                    startTime: _formatTime(rental.startTime),
                    endTime: rental.endTime != null
                        ? _formatTime(rental.endTime!)
                        : '--:--',
                  ),
                  const SizedBox(height: 24),
                  _buildPaymentNote(),
                  const SizedBox(height: 24),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00C950), Color(0xFF00A63E)],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Color(0xFF00C950),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Wypożyczenie zakończone!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dziękujemy za skorzystanie z BikeShare',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFDCFCE7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards({
    required String durationFormatted,
    required String durationText,
    required double cost,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.access_time_outlined,
            iconColor: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFFEFF6FF),
            label: 'Czas przejazdu',
            value: durationFormatted,
            subtitle: durationText,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.attach_money,
            iconColor: const Color(0xFFF97316),
            backgroundColor: const Color(0xFFFFF7ED),
            label: 'Całkowity koszt',
            value: '${cost.toStringAsFixed(2)} zł',
            subtitle: '0,50 zł/min',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(
    BuildContext context, {
    required String bikeId,
    required String date,
    required String startTime,
    required String endTime,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bike,
                  size: 20,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rower',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5565),
                    ),
                  ),
                  Text(
                    '#$bikeId',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101828),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x1A000000), height: 1),
          const SizedBox(height: 12),
          _buildDetailRow('Data', date),
          const SizedBox(height: 8),
          _buildDetailRow('Start', startTime),
          const SizedBox(height: 8),
          _buildDetailRow('Koniec', endTime),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4A5565),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBEDBFF)),
      ),
      child: const Text(
        'Płatność zostanie pobrana z Twojego portfela automatycznie',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF364153),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () => context.go('/'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6900),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Powrót do mapy',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => context.push('/wallet'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD1D5DC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Zobacz portfel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF364153),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackSummary(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'Dziękujemy za jazdę!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const Spacer(),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5565),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6A7282),
            ),
          ),
        ],
      ),
    );
  }
}
