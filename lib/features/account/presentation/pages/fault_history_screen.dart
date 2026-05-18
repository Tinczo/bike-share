import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../bloc/fault_history_bloc.dart';
import '../widgets/fault_report_tile.dart';

/// Screen displaying the user's fault report history.
class FaultHistoryScreen extends StatelessWidget {
  const FaultHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<FaultHistoryBloc>()..add(const FaultHistoryLoadRequested()),
      child: const _FaultHistoryScreenContent(),
    );
  }
}

class _FaultHistoryScreenContent extends StatelessWidget {
  const _FaultHistoryScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.scaffoldGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: const Text('Historia zgloszen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<FaultHistoryBloc, FaultHistoryState>(
        builder: (context, state) {
          if (state is FaultHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FaultHistoryLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FaultHistoryBloc>().add(
                  const FaultHistoryLoadRequested(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: state.faultReports.length,
                itemBuilder: (context, index) {
                  final faultReport = state.faultReports[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < state.faultReports.length - 1 ? 12 : 0,
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
                      child: FaultReportTile(faultReport: faultReport),
                    ),
                  );
                },
              ),
            );
          }

          if (state is FaultHistoryEmpty) {
            return _buildEmptyState(context);
          }

          if (state is FaultHistoryError) {
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
                Icons.report_outlined,
                size: 64,
                color: AppPalette.hintColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Brak zgloszen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.labelColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nie masz jeszcze zadnych zgloszen usterek.',
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
                onPressed: () => context.read<FaultHistoryBloc>().add(
                  const FaultHistoryLoadRequested(),
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
