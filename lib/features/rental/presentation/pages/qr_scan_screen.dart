import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../injection_container.dart';
import '../../../map/presentation/bloc/map_bloc.dart';
import '../../domain/entities/rental_launch_method.dart';
import '../bloc/rental_bloc.dart';

/// Design constants matching Figma mockups.
class _QRScanDesign {
  static const Color panelBackground = Color(0xCC000000); // black 80%
  static const Color accentOrange = Color(0xFFFF6900);
  static const Color buttonBackground = Color(0xE6FFFFFF); // white 90%
  static const Color helperTextColor = Color(0xB3FFFFFF); // white 70%
  static const Color inputPlaceholder = Color(0xFF717182);

  static const double cornerFrameSize = 256;
  static const double cornerPieceLength = 48;
  static const double cornerBorderWidth = 3.5;
  static const double cornerBorderRadius = 10;

  static const double buttonHeight = 56;
  static const double buttonBorderRadius = 8;
  static const double panelPadding = 24;
}

/// Screen for scanning QR codes to start a rental.
class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch event only once when screen is first created
    // (not on every rebuild like in build() method)
    sl<RentalBloc>().add(const CheckEligibilityRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<RentalBloc>(),
      child: const _QRScanScreenContent(),
    );
  }
}

class _QRScanScreenContent extends StatefulWidget {
  const _QRScanScreenContent();

  @override
  State<_QRScanScreenContent> createState() => _QRScanScreenContentState();
}

class _QRScanScreenContentState extends State<_QRScanScreenContent> {
  late final MobileScannerController _scannerController;
  bool _isProcessing = false;
  bool _isManualEntryMode = false;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    if (!_scannerController.value.isInitialized) {
      return;
    }
    try {
      await _scannerController.toggleTorch();
    } on MobileScannerException catch (_) {
      // Torch not available or other error - ignore silently
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing || _isManualEntryMode) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);

    final bikeId = _extractBikeId(code);
    if (bikeId != null) {
      _startRental(bikeId, RentalLaunchMethod.qr);
    } else {
      _showError('Invalid QR code format');
      setState(() => _isProcessing = false);
    }
  }

  String? _extractBikeId(String code) {
    if (code.startsWith('BIKE-')) {
      return code;
    }
    final uriMatch = RegExp(r'bike[=/](\w+)').firstMatch(code);
    if (uriMatch != null) {
      return 'BIKE-${uriMatch.group(1)}';
    }
    if (RegExp(r'^\d{5}$').hasMatch(code)) {
      return 'BIKE-$code';
    }
    return null;
  }

  void _startRental(String bikeId, RentalLaunchMethod method) {
    context.read<RentalBloc>().add(
      RentalStarted(bikeId: bikeId, method: method),
    );
  }

  void _submitManualCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showError('Please enter a bike code');
      return;
    }
    if (!RegExp(r'^\d{5}$').hasMatch(code)) {
      _showError('Code must be 5 digits');
      return;
    }
    final bikeId = 'BIKE-$code';
    _startRental(bikeId, RentalLaunchMethod.manual);
  }

  void _toggleManualEntry() {
    setState(() {
      _isManualEntryMode = !_isManualEntryMode;
      if (!_isManualEntryMode) {
        _codeController.clear();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RentalBloc, RentalState>(
        // Only react to transitions TO RentalActive, not existing state
        listenWhen: (previous, current) =>
            previous is! RentalActive && current is RentalActive,
        listener: (context, state) {
          if (state is RentalFailure) {
            _showError(state.message);
            setState(() => _isProcessing = false);
          }
          if (state is RentalActive) {
            // Refresh map to show bike as rented (orange)
            sl<MapBloc>().add(const RefreshMapRequested());
            // Navigate to confirmation screen with rental details
            context.go(
              '/rental/confirmation/${state.rental.id}/${state.rental.bikeId}',
            );
          }
          if (state is RentalIneligible) {
            _showIneligibleDialog(state.eligibility.reason);
          }
        },
        builder: (context, state) {
          final isLoading =
              state is RentalEligibilityChecking ||
              state is RentalStarting ||
              state is RentalUnlocking;

          final loadingMessage = switch (state) {
            RentalEligibilityChecking() => 'Checking eligibility...',
            RentalUnlocking() => 'Unlocking bike...',
            RentalStarting() => 'Starting rental...',
            _ => null,
          };

          // Keep MobileScanner always in the tree to prevent
          // controller initialization race conditions
          return Stack(
            children: [
              // Camera view - ALWAYS mounted to avoid reinitialization
              MobileScanner(
                controller: _scannerController,
                onDetect: _onBarcodeDetected,
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1E2939).withValues(alpha: 0.5),
                      const Color(0xFF101828).withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),

              // Loading overlay (shown on top when loading)
              if (isLoading) _buildLoadingOverlay(loadingMessage!),

              // UI elements (hidden during loading)
              if (!isLoading) ...[
                // Center scan area with corner frame
                Center(child: _buildScanArea()),

                // Custom header at top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(context),
                ),

                // Bottom panel
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomPanel(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay(String message) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _QRScanDesign.accentOrange),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: _QRScanDesign.panelBackground,
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 8, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Skanuj kod QR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Corner frame with QR icon
        SizedBox(
          width: _QRScanDesign.cornerFrameSize,
          height: _QRScanDesign.cornerFrameSize,
          child: Stack(
            children: [
              // Corner pieces
              _buildCornerPiece(Alignment.topLeft),
              _buildCornerPiece(Alignment.topRight),
              _buildCornerPiece(Alignment.bottomLeft),
              _buildCornerPiece(Alignment.bottomRight),

              // QR code icon centered
              const Center(
                child: Icon(Icons.qr_code_2, size: 80, color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Instruction text
        const Text(
          'Umieść kod QR w ramce',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCornerPiece(Alignment alignment) {
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: CustomPaint(
        size: const Size(
          _QRScanDesign.cornerPieceLength,
          _QRScanDesign.cornerPieceLength,
        ),
        painter: _CornerPainter(
          color: _QRScanDesign.accentOrange,
          strokeWidth: _QRScanDesign.cornerBorderWidth,
          borderRadius: _QRScanDesign.cornerBorderRadius,
          isTop: isTop,
          isLeft: isLeft,
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: _QRScanDesign.panelBackground,
      padding: EdgeInsets.only(
        left: _QRScanDesign.panelPadding,
        right: _QRScanDesign.panelPadding,
        top: _QRScanDesign.panelPadding,
        bottom: _QRScanDesign.panelPadding + bottomPadding,
      ),
      child: _isManualEntryMode
          ? _buildManualEntryContent()
          : _buildScanningContent(),
    );
  }

  Widget _buildScanningContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Two buttons row
        Row(
          children: [
            // Flashlight button
            Expanded(
              child: _buildPanelButton(
                icon: Icons.flashlight_on,
                onPressed: _toggleTorch,
              ),
            ),
            const SizedBox(width: 12),
            // Manual entry button
            Expanded(
              child: _buildPanelButton(
                icon: Icons.keyboard,
                label: 'Wpisz kod',
                onPressed: _toggleManualEntry,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Helper text
        const Text(
          'Kod QR znajdziesz na kierownicy roweru',
          style: TextStyle(color: _QRScanDesign.helperTextColor, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildManualEntryContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text input
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 5,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Wpisz kod roweru (np. 12345)',
            hintStyle: const TextStyle(color: _QRScanDesign.inputPlaceholder),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                _QRScanDesign.buttonBorderRadius,
              ),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                _QRScanDesign.buttonBorderRadius,
              ),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                _QRScanDesign.buttonBorderRadius,
              ),
              borderSide: const BorderSide(
                color: _QRScanDesign.accentOrange,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Confirm button
        SizedBox(
          width: double.infinity,
          height: _QRScanDesign.buttonHeight,
          child: FilledButton(
            onPressed: _submitManualCode,
            style: FilledButton.styleFrom(
              backgroundColor: _QRScanDesign.accentOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  _QRScanDesign.buttonBorderRadius,
                ),
              ),
            ),
            child: const Text(
              'Potwierdź',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Two buttons row
        Row(
          children: [
            // Flashlight button
            Expanded(
              child: _buildPanelButton(
                icon: Icons.flashlight_on,
                onPressed: _toggleTorch,
              ),
            ),
            const SizedBox(width: 12),
            // Cancel button
            Expanded(
              child: _buildPanelButton(
                label: 'Anuluj',
                onPressed: _toggleManualEntry,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Helper text
        const Text(
          'Kod QR znajdziesz na kierownicy roweru',
          style: TextStyle(color: _QRScanDesign.helperTextColor, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPanelButton({
    IconData? icon,
    String? label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: _QRScanDesign.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: _QRScanDesign.buttonBackground,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              _QRScanDesign.buttonBorderRadius,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.black87, size: 24),
            if (icon != null && label != null) const SizedBox(width: 8),
            if (label != null)
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showIneligibleDialog(String? reason) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.block, size: 48, color: Colors.red),
        title: const Text('Cannot Start Rental'),
        content: Text(
          reason ??
              'You are not eligible to rent at this time. '
                  'Please check your account status.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.pop();
            },
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.push('/wallet');
            },
            child: const Text('Go to Wallet'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for corner frame pieces.
class _CornerPainter extends CustomPainter {
  _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    required this.isTop,
    required this.isLeft,
  });

  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final bool isTop;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Calculate offsets for stroke width
    final offset = strokeWidth / 2;

    if (isTop && isLeft) {
      // Top-left corner
      path.moveTo(offset, size.height);
      path.lineTo(offset, borderRadius + offset);
      path.quadraticBezierTo(offset, offset, borderRadius + offset, offset);
      path.lineTo(size.width, offset);
    } else if (isTop && !isLeft) {
      // Top-right corner
      path.moveTo(0, offset);
      path.lineTo(size.width - borderRadius - offset, offset);
      path.quadraticBezierTo(
        size.width - offset,
        offset,
        size.width - offset,
        borderRadius + offset,
      );
      path.lineTo(size.width - offset, size.height);
    } else if (!isTop && isLeft) {
      // Bottom-left corner
      path.moveTo(offset, 0);
      path.lineTo(offset, size.height - borderRadius - offset);
      path.quadraticBezierTo(
        offset,
        size.height - offset,
        borderRadius + offset,
        size.height - offset,
      );
      path.lineTo(size.width, size.height - offset);
    } else {
      // Bottom-right corner
      path.moveTo(0, size.height - offset);
      path.lineTo(size.width - borderRadius - offset, size.height - offset);
      path.quadraticBezierTo(
        size.width - offset,
        size.height - offset,
        size.width - offset,
        size.height - borderRadius - offset,
      );
      path.lineTo(size.width - offset, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        borderRadius != oldDelegate.borderRadius ||
        isTop != oldDelegate.isTop ||
        isLeft != oldDelegate.isLeft;
  }
}
