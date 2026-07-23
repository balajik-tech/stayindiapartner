import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const StatusBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  factory StatusBadge.verified() => const StatusBadge(
        label: 'Verified',
        background: Color(0xFFDDF4E4),
        foreground: Color(0xFF1E8E42),
      );

  factory StatusBadge.pending() => const StatusBadge(
        label: 'Pending',
        background: Color(0xFFFCEBC7),
        foreground: Color(0xFF9A6600),
      );

  factory StatusBadge.primary() => const StatusBadge(
        label: 'Primary',
        background: Color(0xFFE1EAFE),
        foreground: Color(0xFF2E5AF5),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
