import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/wallet.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/widgets.dart';

/// Screen for topping up the wallet.
class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch event only once when screen is first created
    // (not on every rebuild like in build() method)
    sl<WalletBloc>().add(const WalletLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<WalletBloc>(),
      child: const _TopUpScreenContent(),
    );
  }
}

class _TopUpScreenContent extends StatefulWidget {
  const _TopUpScreenContent();

  @override
  State<_TopUpScreenContent> createState() => _TopUpScreenContentState();
}

class _TopUpScreenContentState extends State<_TopUpScreenContent> {
  double? _selectedAmount;
  String _selectedMethod = 'blik';

  static const List<double> _amounts = [10, 20, 50, 100, 200, 500];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.scaffoldGray,
      appBar: AppBar(
        title: const Text('Doladowanie konta'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is WalletTopUpSuccess) {
            context.pop();
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletTopUpInProgress) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Przetwarzanie platnosci...'),
                ],
              ),
            );
          }

          final wallet = state is WalletLoaded ? state.wallet : null;
          final hasDebt = wallet?.status == WalletStatus.debt ||
              (wallet != null && wallet.balance < 0);
          final debt = wallet != null && wallet.balance < 0
              ? wallet.balance.abs()
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasDebt) ...[
                  DebtCard(debtAmount: debt),
                  const SizedBox(height: 24),
                  MinimumAmountCard(minimumAmount: debt),
                  const SizedBox(height: 24),
                ],
                _buildSectionCard(
                  title: 'Wybierz kwote',
                  child: AmountSelectionGrid(
                    amounts: _amounts,
                    selectedAmount: _selectedAmount,
                    minimumAmount: hasDebt ? debt : null,
                    onAmountSelected: (amount) {
                      setState(() => _selectedAmount = amount);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Metoda platnosci',
                  child: PaymentMethodSelector(
                    selectedMethod: _selectedMethod,
                    onMethodSelected: (method) {
                      setState(() => _selectedMethod = method);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedAmount != null
                        ? () => _handleTopUp(context, hasDebt)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.orange,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      hasDebt ? 'Ureguluj dlug teraz' : 'Doladuj konto',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AppPalette.labelColor,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  void _handleTopUp(BuildContext context, bool hasDebt) {
    if (_selectedAmount == null) return;

    context.read<WalletBloc>().add(
      TopUpRequested(amount: _selectedAmount!, method: _selectedMethod),
    );
  }
}
