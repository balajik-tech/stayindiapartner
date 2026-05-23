import 'package:flutter/material.dart';

class MovementStatusBadge extends StatelessWidget {
  final bool isInHostel;
  final VoidCallback onTap;

  const MovementStatusBadge({
    super.key,
    required this.isInHostel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isInHostel
              ? Colors.green.shade50
              : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isInHostel
                ? Colors.green.shade200
                : Colors.red.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isInHostel
                    ? Colors.green.shade600
                    : Colors.red.shade600,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isInHostel ? "IN HOSTEL" : "OUTSIDE",
              style: TextStyle(
                color: isInHostel
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
