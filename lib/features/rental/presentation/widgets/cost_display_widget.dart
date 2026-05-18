import 'package:flutter/material.dart';

/// Widget that displays the rental cost.
class CostDisplayWidget extends StatelessWidget {
  /// Current cost in PLN.
  final double cost;

  /// Optional prefix text.
  final String? prefix;

  /// Text style for the cost display.
  final TextStyle? style;

  const CostDisplayWidget({
    super.key,
    required this.cost,
    this.prefix,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefix != null) ...[
          Text(
            prefix!,
            style:
                style ?? defaultStyle?.copyWith(fontWeight: FontWeight.normal),
          ),
          const SizedBox(width: 4),
        ],
        Text('${cost.toStringAsFixed(2)} PLN', style: style ?? defaultStyle),
      ],
    );
  }
}
