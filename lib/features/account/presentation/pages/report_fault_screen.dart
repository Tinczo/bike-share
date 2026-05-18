import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/fault_type.dart';
import '../bloc/report_fault_bloc.dart';
import '../widgets/fault_type_radio_tile.dart';

/// Screen for reporting a fault on a bike.
class ReportFaultScreen extends StatelessWidget {
  final String bikeId;

  const ReportFaultScreen({super.key, required this.bikeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportFaultBloc>(),
      child: _ReportFaultScreenContent(bikeId: bikeId),
    );
  }
}

class _ReportFaultScreenContent extends StatefulWidget {
  final String bikeId;

  const _ReportFaultScreenContent({required this.bikeId});

  @override
  State<_ReportFaultScreenContent> createState() =>
      _ReportFaultScreenContentState();
}

class _ReportFaultScreenContentState extends State<_ReportFaultScreenContent> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.scaffoldGray,
      appBar: AppBar(
        title: const Text('Zgłoś usterkę'),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<ReportFaultBloc, ReportFaultState>(
        listener: (context, state) {
          if (state is ReportFaultFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is ReportFaultSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Zgłoszenie wysłane pomyślnie!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          final selectedType = state is ReportFaultTypeSelected
              ? state.selectedType
              : null;
          final isSubmitting = state is ReportFaultSubmitting;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBikeInfo(),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Wybierz rodzaj usterki'),
                      const SizedBox(height: 12),
                      _buildFaultTypeList(context, selectedType),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Dodaj opis (opcjonalnie)'),
                      const SizedBox(height: 8),
                      _buildDescriptionField(context),
                    ],
                  ),
                ),
              ),
              _buildSubmitButton(context, selectedType, isSubmitting),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBikeInfo() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppPalette.warningBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.warningBorder, width: 1),
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
                Text(
                  'Rower #${widget.bikeId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.labelColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Twoje zgłoszenie pomoże poprawić jakość usługi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppPalette.paragraphColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppPalette.labelColor,
      ),
    );
  }

  Widget _buildFaultTypeList(BuildContext context, FaultType? selectedType) {
    return Column(
      children: FaultType.values.map((type) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FaultTypeRadioTile(
            type: type,
            isSelected: selectedType == type,
            onTap: () {
              context.read<ReportFaultBloc>().add(FaultTypeSelected(type));
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return TextField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Opisz problem bardziej szczegółowo...',
        hintStyle: const TextStyle(fontSize: 16, color: AppPalette.hintColor),
        filled: true,
        fillColor: AppPalette.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.primaryBlue, width: 1),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
      onChanged: (value) {
        context.read<ReportFaultBloc>().add(DescriptionChanged(value));
      },
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    FaultType? selectedType,
    bool isSubmitting,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, -10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: selectedType == null || isSubmitting
                ? null
                : () {
                    context.read<ReportFaultBloc>().add(
                      FaultReportSubmitted(bikeId: widget.bikeId),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.orange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppPalette.orange.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Wyślij zgłoszenie',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
          ),
        ),
      ),
    );
  }
}
