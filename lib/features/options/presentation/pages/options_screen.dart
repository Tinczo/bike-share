import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/api_options.dart';
import '../bloc/options_bloc.dart';

/// Screen for configuring API base URLs.
class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  @override
  void initState() {
    super.initState();
    sl<OptionsBloc>().add(const OptionsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<OptionsBloc>(),
      child: const _OptionsScreenContent(),
    );
  }
}

class _OptionsScreenContent extends StatelessWidget {
  const _OptionsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.scaffoldGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        title: const Text('Ustawienia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<OptionsBloc, OptionsState>(
        listener: (context, state) {
          if (state is OptionsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is OptionsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ustawienia zapisane'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OptionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OptionsLoaded || state is OptionsSaved) {
            final options =
                state is OptionsLoaded
                    ? state.options
                    : (state as OptionsSaved).options;
            final hasChanges =
                state is OptionsLoaded ? state.hasChanges : false;

            return _OptionsForm(options: options, hasChanges: hasChanges);
          }

          if (state is OptionsSaving) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Zapisywanie...'),
                ],
              ),
            );
          }

          if (state is OptionsError) {
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
                    onPressed:
                        () => context.read<OptionsBloc>().add(
                          const OptionsLoadRequested(),
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
}

class _OptionsForm extends StatefulWidget {
  final ApiOptions options;
  final bool hasChanges;

  const _OptionsForm({required this.options, required this.hasChanges});

  @override
  State<_OptionsForm> createState() => _OptionsFormState();
}

class _OptionsFormState extends State<_OptionsForm> {
  late TextEditingController _globalUrlController;
  late TextEditingController _authUrlController;
  late TextEditingController _mapUrlController;
  late TextEditingController _rentalUrlController;
  late TextEditingController _walletUrlController;
  late TextEditingController _accountUrlController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _globalUrlController = TextEditingController(
      text: widget.options.globalBaseUrl,
    );
    _authUrlController = TextEditingController(text: widget.options.authBaseUrl);
    _mapUrlController = TextEditingController(text: widget.options.mapBaseUrl);
    _rentalUrlController = TextEditingController(
      text: widget.options.rentalBaseUrl,
    );
    _walletUrlController = TextEditingController(
      text: widget.options.walletBaseUrl,
    );
    _accountUrlController = TextEditingController(
      text: widget.options.accountBaseUrl,
    );
  }

  @override
  void didUpdateWidget(_OptionsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers when options change externally (e.g., reset)
    if (oldWidget.options != widget.options) {
      _globalUrlController.text = widget.options.globalBaseUrl;
      _authUrlController.text = widget.options.authBaseUrl;
      _mapUrlController.text = widget.options.mapBaseUrl;
      _rentalUrlController.text = widget.options.rentalBaseUrl;
      _walletUrlController.text = widget.options.walletBaseUrl;
      _accountUrlController.text = widget.options.accountBaseUrl;
    }
  }

  @override
  void dispose() {
    _globalUrlController.dispose();
    _authUrlController.dispose();
    _mapUrlController.dispose();
    _rentalUrlController.dispose();
    _walletUrlController.dispose();
    _accountUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildApiUrlsSection(context),
          const SizedBox(height: 24),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildApiUrlsSection(BuildContext context) {
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.api, size: 20, color: AppPalette.labelColor),
                const SizedBox(width: 8),
                const Text(
                  'Adresy API',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.labelColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Skonfiguruj adresy bazowe dla poszczegolnych serwisow API.',
              style: TextStyle(fontSize: 14, color: AppPalette.hintColor),
            ),
            const SizedBox(height: 24),
            _buildSameForAllToggle(context),
            const SizedBox(height: 24),
            if (widget.options.sameForAll)
              _buildUrlField(
                label: 'Adres bazowy API',
                controller: _globalUrlController,
                onChanged:
                    (value) => context.read<OptionsBloc>().add(
                      OptionsGlobalUrlChanged(value),
                    ),
              )
            else
              _buildIndividualUrlFields(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSameForAllToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.tileBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.tileBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ten sam adres dla wszystkich',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.labelColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uzyj jednego adresu bazowego dla wszystkich serwisow',
                  style: TextStyle(fontSize: 13, color: AppPalette.hintColor),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.options.sameForAll,
            onChanged:
                (value) => context.read<OptionsBloc>().add(
                  OptionsSameForAllToggled(value),
                ),
            activeTrackColor: AppPalette.primaryBlue.withValues(alpha: 0.5),
            activeThumbColor: AppPalette.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualUrlFields(BuildContext context) {
    return Column(
      children: [
        _buildUrlField(
          label: 'Autoryzacja',
          controller: _authUrlController,
          icon: Icons.lock_outline,
          onChanged:
              (value) => context.read<OptionsBloc>().add(
                OptionsIndividualUrlChanged(
                  type: DataSourceType.auth,
                  url: value,
                ),
              ),
        ),
        const SizedBox(height: 16),
        _buildUrlField(
          label: 'Mapa',
          controller: _mapUrlController,
          icon: Icons.map_outlined,
          onChanged:
              (value) => context.read<OptionsBloc>().add(
                OptionsIndividualUrlChanged(
                  type: DataSourceType.map,
                  url: value,
                ),
              ),
        ),
        const SizedBox(height: 16),
        _buildUrlField(
          label: 'Wypozyczenia',
          controller: _rentalUrlController,
          icon: Icons.directions_bike_outlined,
          onChanged:
              (value) => context.read<OptionsBloc>().add(
                OptionsIndividualUrlChanged(
                  type: DataSourceType.rental,
                  url: value,
                ),
              ),
        ),
        const SizedBox(height: 16),
        _buildUrlField(
          label: 'Portfel',
          controller: _walletUrlController,
          icon: Icons.account_balance_wallet_outlined,
          onChanged:
              (value) => context.read<OptionsBloc>().add(
                OptionsIndividualUrlChanged(
                  type: DataSourceType.wallet,
                  url: value,
                ),
              ),
        ),
        const SizedBox(height: 16),
        _buildUrlField(
          label: 'Konto',
          controller: _accountUrlController,
          icon: Icons.person_outline,
          onChanged:
              (value) => context.read<OptionsBloc>().add(
                OptionsIndividualUrlChanged(
                  type: DataSourceType.account,
                  url: value,
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildUrlField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppPalette.hintColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppPalette.labelColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'http://example.com/api',
            prefixIcon: const Icon(Icons.link, size: 20),
          ),
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                () =>
                    context.read<OptionsBloc>().add(const OptionsResetRequested()),
            icon: const Icon(Icons.restore),
            label: const Text('Przywroc domyslne'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppPalette.primaryBlue),
              foregroundColor: AppPalette.primaryBlue,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                widget.hasChanges
                    ? () => context.read<OptionsBloc>().add(
                      const OptionsSaveRequested(),
                    )
                    : null,
            icon: const Icon(Icons.save),
            label: const Text('Zapisz'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppPalette.primaryBlue,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }
}
