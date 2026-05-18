import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom sheet for entering a bike code manually.
class ManualCodeEntrySheet extends StatefulWidget {
  /// Callback when a valid code is entered.
  final void Function(String code) onCodeEntered;

  const ManualCodeEntrySheet({super.key, required this.onCodeEntered});

  /// Shows the manual code entry sheet.
  static Future<void> show(
    BuildContext context, {
    required void Function(String code) onCodeEntered,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ManualCodeEntrySheet(onCodeEntered: onCodeEntered),
    );
  }

  @override
  State<ManualCodeEntrySheet> createState() => _ManualCodeEntrySheetState();
}

class _ManualCodeEntrySheetState extends State<ManualCodeEntrySheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateCode);
    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _validateCode() {
    setState(() {
      // Code should be 5 digits
      _isValid =
          _controller.text.length == 5 &&
          RegExp(r'^\d{5}$').hasMatch(_controller.text);
    });
  }

  void _submit() {
    if (_isValid) {
      widget.onCodeEntered(_controller.text);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Enter Bike Code',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 5-digit code found on the bike',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 5,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              letterSpacing: 8,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              hintText: '00000',
              hintStyle: TextStyle(color: Colors.grey[300], letterSpacing: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isValid ? _submit : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Unlock Bike'),
          ),
        ],
      ),
    );
  }
}
