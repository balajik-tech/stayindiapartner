import 'package:flutter/material.dart';

import '../../domain/entities/kyc_result.dart';

/// Displays a [KycResult] as a clean, read-only profile card.
/// Only shows rows for fields that actually came back non-null/non-empty.
class KycResultCard extends StatelessWidget {
  final KycResult result;

  const KycResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String?>>[
      MapEntry('Name', result.name),
      MapEntry('Aadhaar Number', result.aadharNumber),
      MapEntry('Date of Birth', result.dob),
      MapEntry('Gender', result.gender),
      MapEntry('Address', result.aadharAddress),
      // MapEntry('PAN Number', result.panNumber),
      // MapEntry('Name on PAN', result.nameOnPan),
    ].where((e) => e.value != null && e.value!.trim().isNotEmpty).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Verified Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final row in rows) ...[
              _InfoRow(label: row.key, value: row.value!),
              if (row != rows.last) const Divider(height: 20),
            ],
            const SizedBox(height: 12),
            Text(
              'Verified on ${_formatDate(result.capturedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
