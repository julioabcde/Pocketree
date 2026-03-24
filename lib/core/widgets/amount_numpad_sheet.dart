import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';

/// Shows a calculator-style numpad bottom sheet for amount input.
///
/// Returns the entered amount as [double], or `null` if dismissed.
Future<double?> showAmountNumpad(BuildContext context, {double? initialValue}) {
  return showModalBottomSheet<double>(
    context: context,
    backgroundColor: AppColors.neutralCream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AmountNumpadSheet(initialValue: initialValue),
  );
}

class _AmountNumpadSheet extends StatefulWidget {
  final double? initialValue;
  const _AmountNumpadSheet({this.initialValue});

  @override
  State<_AmountNumpadSheet> createState() => _AmountNumpadSheetState();
}

class _AmountNumpadSheetState extends State<_AmountNumpadSheet> {
  String _input = '0';
  double? _firstOperand;
  String? _operator;
  bool _waitingForOperand = false;
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue! > 0) {
      _input = _doubleToInput(widget.initialValue!);
    }
  }

  // Conversion helpers

  /// Converts double → input string (50000.5 → "50000,5")
  String _doubleToInput(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }

  /// Converts input string → double ("50000,5" → 50000.5)
  double _inputToDouble(String input) {
    if (input.isEmpty) return 0;
    return double.tryParse(input.replaceAll(',', '.')) ?? 0;
  }

  /// Formats input for display with IDR-style separators
  /// ("50000,5" → "50.000,5")
  String _formatDisplay(String input) {
    if (input.isEmpty || input == '0') return '0';

    final parts = input.split(',');
    final intStr = parts[0];
    final decStr = parts.length > 1 ? parts[1] : null;

    final negative = intStr.startsWith('-');
    final digits = negative ? intStr.substring(1) : intStr;

    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }

    final result = StringBuffer();
    if (negative) result.write('-');
    result.write(buf);
    if (decStr != null) {
      result.write(',');
      result.write(decStr);
    }
    return result.toString();
  }

  // Calculator actions

  void _onDigit(String digit) {
    setState(() {
      if (_hasResult) {
        _input = digit;
        _hasResult = false;
        _firstOperand = null;
        _operator = null;
      } else if (_waitingForOperand) {
        _input = digit;
        _waitingForOperand = false;
      } else if (_input == '0') {
        _input = digit;
      } else {
        // Max 2 decimal places
        if (_input.contains(',') && _input.split(',')[1].length >= 2) {
          return;
        }
        // Max 12 integer digits
        if (!_input.contains(',') && _input.replaceAll('-', '').length >= 12) {
          return;
        }
        _input += digit;
      }
    });
  }

  void _onDecimal() {
    setState(() {
      if (_hasResult) {
        _input = '0,';
        _hasResult = false;
        _firstOperand = null;
        _operator = null;
      } else if (_waitingForOperand) {
        _input = '0,';
        _waitingForOperand = false;
      } else if (!_input.contains(',')) {
        _input += ',';
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      final current = _inputToDouble(_input);

      if (_firstOperand != null && _operator != null && !_waitingForOperand) {
        // Chained operation: evaluate pending first
        final result = _evaluate(_firstOperand!, _operator!, current);
        _firstOperand = result;
        _input = _doubleToInput(result);
      } else if (!_waitingForOperand) {
        _firstOperand = current;
      }
      // If _waitingForOperand, just swap the operator

      _operator = op;
      _waitingForOperand = true;
      _hasResult = false;
    });
  }

  void _onEquals() {
    setState(() {
      if (_firstOperand == null || _operator == null) return;

      final second = _waitingForOperand
          ? _firstOperand!
          : _inputToDouble(_input);
      final result = _evaluate(_firstOperand!, _operator!, second);

      _input = _doubleToInput(result);
      _firstOperand = null;
      _operator = null;
      _waitingForOperand = false;
      _hasResult = true;
    });
  }

  double _evaluate(double a, String op, double b) {
    return switch (op) {
      '+' => a + b,
      '−' => a - b,
      '×' => a * b,
      '÷' => b != 0 ? a / b : 0,
      _ => b,
    };
  }

  void _onBackspace() {
    setState(() {
      if (_hasResult || _waitingForOperand) return;
      _input = _input.length <= 1
          ? '0'
          : _input.substring(0, _input.length - 1);
    });
  }

  void _onClear() {
    setState(() {
      _input = '0';
      _firstOperand = null;
      _operator = null;
      _waitingForOperand = false;
      _hasResult = false;
    });
  }

  void _onConfirmOrEquals() {
    if (_operator != null) {
      _onEquals();
    } else {
      Navigator.pop(context, _inputToDouble(_input));
    }
  }

  bool get _showEquals => _operator != null;

  // Build

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDisplay(),
          Divider(
            height: 1,
            color: AppColors.neutralTaupe.withValues(alpha: 0.3),
          ),
          _buildRow([
            _iconKey(Icons.backspace_outlined, _onBackspace),
            _textKey('C', _onClear),
            _emptyKey(),
            _textKey('÷', () => _onOperator('÷')),
          ]),
          _buildRow([
            _textKey('7', () => _onDigit('7')),
            _textKey('8', () => _onDigit('8')),
            _textKey('9', () => _onDigit('9')),
            _textKey('×', () => _onOperator('×')),
          ]),
          _buildRow([
            _textKey('4', () => _onDigit('4')),
            _textKey('5', () => _onDigit('5')),
            _textKey('6', () => _onDigit('6')),
            _textKey('+', () => _onOperator('+')),
          ]),
          _buildRow([
            _textKey('1', () => _onDigit('1')),
            _textKey('2', () => _onDigit('2')),
            _textKey('3', () => _onDigit('3')),
            _textKey('−', () => _onOperator('−')),
          ]),
          _buildRow([
            _emptyKey(),
            _textKey('0', () => _onDigit('0')),
            _textKey(',', _onDecimal),
            _confirmKey(),
          ]),
        ],
      ),
    );
  }

  Widget _buildDisplay() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Expression line (pending operation)
            if (_firstOperand != null && _operator != null)
              Text(
                '${_formatDisplay(_doubleToInput(_firstOperand!))} $_operator',
                style: TextStyle(fontSize: 14, color: AppColors.brownMocha),
              ),
            const SizedBox(height: 4),
            // Current value
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _formatDisplay(_input),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brownEspresso,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return IntrinsicHeight(
      child: Row(children: children.map((w) => Expanded(child: w)).toList()),
    );
  }

  Widget _textKey(String label, VoidCallback onTap) {
    final isOperator = ['÷', '×', '+', '−'].contains(label);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.neutralTaupe.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isOperator ? 24 : 22,
              fontWeight: isOperator ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.brownEspresso,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconKey(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.neutralTaupe.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Icon(icon, size: 22, color: AppColors.brownEspresso),
        ),
      ),
    );
  }

  Widget _emptyKey() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
    );
  }

  Widget _confirmKey() {
    return GestureDetector(
      onTap: _onConfirmOrEquals,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryForest,
          border: Border.all(
            color: AppColors.neutralTaupe.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Center(
          child: _showEquals
              ? const Text(
                  '=',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                )
              : const Icon(
                  Icons.check_rounded,
                  size: 26,
                  color: AppColors.white,
                ),
        ),
      ),
    );
  }
}
