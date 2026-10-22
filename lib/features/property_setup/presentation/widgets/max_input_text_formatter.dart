import 'package:flutter/services.dart';

/// Rejects an edit that would push the number above [maxValue], keeping the
/// value exactly as the user typed it so far. It never rewrites the number
/// to [maxValue]; [onExceeded] is called instead so the UI can explain why.
class MaxValueTextInputFormatter extends TextInputFormatter {
  final int maxValue;
  final void Function()? onExceeded;

  MaxValueTextInputFormatter(this.maxValue, {this.onExceeded});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final value = int.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }

    if (value > maxValue) {
      onExceeded?.call();
      return oldValue;
    }

    return newValue;
  }
}
