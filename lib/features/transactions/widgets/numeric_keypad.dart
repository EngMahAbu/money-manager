import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/theme_constants.dart';

class NumericKeypad extends StatelessWidget {
  final bool isCalculatorExpanded;
  final Function(String) onKeyPressed;
  final VoidCallback onDeletePressed;
  final Function(String) onOperatorPressed;

  const NumericKeypad({
    super.key,
    required this.isCalculatorExpanded,
    required this.onKeyPressed,
    required this.onDeletePressed,
    required this.onOperatorPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.transparent, // Background will be from the parent column
      child: Column(
        children: [
          Row(
            children: [
              _buildKey('1'),
              const SizedBox(width: 8),
              _buildKey('2'),
              const SizedBox(width: 8),
              _buildKey('3'),
              if (isCalculatorExpanded) ...[
                const SizedBox(width: 8),
                _buildOperatorKey('÷'),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKey('4'),
              const SizedBox(width: 8),
              _buildKey('5'),
              const SizedBox(width: 8),
              _buildKey('6'),
              if (isCalculatorExpanded) ...[
                const SizedBox(width: 8),
                _buildOperatorKey('×'),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKey('7'),
              const SizedBox(width: 8),
              _buildKey('8'),
              const SizedBox(width: 8),
              _buildKey('9'),
              if (isCalculatorExpanded) ...[
                const SizedBox(width: 8),
                _buildOperatorKey('−', '-'),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildKey('.'),
              const SizedBox(width: 8),
              _buildKey('0'),
              const SizedBox(width: 8),
              _buildDeleteKey(),
              if (isCalculatorExpanded) ...[
                const SizedBox(width: 8),
                _buildOperatorKey('+'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onKeyPressed(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return Expanded(
      child: GestureDetector(
        onTap: onDeletePressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
          ),
          alignment: Alignment.center,
          child: const Icon(TablerIcons.backspace, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildOperatorKey(String label, [String? value]) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onOperatorPressed(value ?? label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.accentContainer,
            borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, color: AppColors.accentText),
          ),
        ),
      ),
    );
  }
}
