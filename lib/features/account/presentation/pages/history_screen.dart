import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../bloc/rental_history_bloc.dart';
import '../widgets/rental_history_tile.dart';

/// Screen displaying the user's rental history.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<RentalHistoryBloc>()..add(const RentalHistoryLoadRequested()),
      child: const _HistoryScreenContent(),
    );
  }
}

class _HistoryScreenContent extends StatelessWidget {
  const _HistoryScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.scaffoldGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: const Text('Historia wypozyczen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<RentalHistoryBloc, RentalHistoryState>(
        builder: (context, state) {
          if (state is RentalHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RentalHistoryLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<RentalHistoryBloc>().add(
                  const RentalHistoryLoadRequested(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: state.rentalHistory.length,
                itemBuilder: (context, index) {
                  final rental = state.rentalHistory[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < state.rentalHistory.length - 1 ? 12 : 0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: RentalHistoryTile(rental: rental),
                    ),
                  );
                },
              ),
            );
          }

          if (state is RentalHistoryEmpty) {
            return _buildEmptyState(context);
          }

          if (state is RentalHistoryError) {
            return _buildErrorState(context, state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_bike_outlined,
                size: 64,
                color: AppPalette.hintColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Brak wypozyczen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.labelColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nie masz jeszcze zadnej historii wypozyczen.\n'
                'Wypozycz rower, aby zobaczyc go tutaj.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppPalette.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<RentalHistoryBloc>().add(
                  const RentalHistoryLoadRequested(),
                ),
                child: const Text('Sprobuj ponownie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
