import 'package:flutter/services.dart';

class MaxValueTextInputFormatter extends TextInputFormatter {
  final int maxValue;

  MaxValueTextInputFormatter(this.maxValue);

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
      final cappedText = maxValue.toString();
      return TextEditingValue(
        text: cappedText,
        selection: TextSelection.collapsed(offset: cappedText.length),
      );
    }

    return newValue;
  }
}