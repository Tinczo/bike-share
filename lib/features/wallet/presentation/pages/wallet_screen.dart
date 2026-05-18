import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/widgets.dart';

/// Main wallet screen displaying balance, payment methods, and transactions.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
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
      child: const _WalletScreenContent(),
    );
  }
}

class _WalletScreenContent extends StatelessWidget {
  const _WalletScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.scaffoldGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: const Text('Portfel'),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Doladowanie zakonczone sukcesem!'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload wallet data after successful top-up
            context.read<WalletBloc>().add(const WalletLoadRequested());
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(const WalletLoadRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WalletBalanceCard(
                      balance: state.wallet.balance,
                      status: state.wallet.status,
                      onTopUp: () => context.push('/wallet/topup'),
                    ),
                    const SizedBox(height: 24),
                    _buildPaymentMethodsSection(context, state.paymentMethods),
                    const SizedBox(height: 24),
                    _buildTransactionsSection(context, state.transactions),
                  ],
                ),
              ),
            );
          }

          if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<WalletBloc>().add(
                      const WalletLoadRequested(),
                    ),
                    child: const Text('Sprobuj ponownie'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPaymentMethodsSection(
    BuildContext context,
    List paymentMethods,
  ) {
    return Container(
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Metody platnosci',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.labelColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to add payment method screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dodawanie metody platnosci...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16, color: AppPalette.primaryBlue),
                  label: const Text(
                    'Dodaj',
                    style: TextStyle(
                      color: AppPalette.primaryBlue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (paymentMethods.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPalette.tileBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppPalette.hintColor),
                    SizedBox(width: 12),
                    Text(
                      'Brak zapisanych metod platnosci',
                      style: TextStyle(color: AppPalette.hintColor),
                    ),
                  ],
                ),
              )
            else
              ...paymentMethods.map(
                (method) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PaymentMethodTile(paymentMethod: method),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(
    BuildContext context,
    List<Transaction> transactions,
  ) {
    return Container(
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppPalette.labelColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Historia transakcji',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.labelColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPalette.tileBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppPalette.hintColor),
                    SizedBox(width: 12),
                    Text(
                      'Brak transakcji',
                      style: TextStyle(color: AppPalette.hintColor),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black.withValues(alpha: 0.1),
                  height: 1,
                ),
                itemBuilder: (context, index) => TransactionTile(
                  transaction: transactions[index],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
