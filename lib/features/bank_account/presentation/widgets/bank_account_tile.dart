import 'package:flutter/material.dart';

import '../../domain/entities/bank_account_entity.dart';
import 'status_badge.dart';

class BankAccountTile extends StatelessWidget {
  final BankAccountEntity account;
  final bool isUpdating;
  final VoidCallback onSetPrimary;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const BankAccountTile({
    super.key,
    required this.account,
    required this.onSetPrimary,
    required this.onEdit,
    required this.onRemove,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isVerificationPending = account.verificationStatus == AccountVerificationStatus.pending;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 0,bottom: 16,top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: account.isPrimary
                    ? const Icon(Icons.check_circle, color: Color(0xFF2E5AF5), size: 20)
                    : const Icon(Icons.circle_outlined, color: Color(0xFFBFC4CC), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${account.bankName} ${account.maskedAccountNumber}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (account.isPrimary) ...[
                          const SizedBox(width: 8),
                          StatusBadge.primary(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.accountHolderName} · ${account.ifscCode}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    // if (isVerificationPending) ...[
                      // const SizedBox(height: 6),
                      // Row(
                      //   children: [
                      //     const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF9A6600)),
                      //     const SizedBox(width: 4),
                      //     const Text(
                      //       'Verification in progress',
                      //       style: TextStyle(
                      //         fontSize: 12.5,
                      //         color: Color(0xFF9A6600),
                      //         fontWeight: FontWeight.w500,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    // ],
                  ],
                ),
              ),
              isUpdating
                  ? const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'remove') onRemove();
                },
                itemBuilder: (context) => [
                  // const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  // const PopupMenuItem(value: 'remove', child: Text('Remove')),
                ],
              ),
            ],
          ),
          if (!account.isPrimary && !isUpdating)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 2),
              child: OutlinedButton(
                onPressed: onSetPrimary,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Set as primary', style: TextStyle(fontSize: 13)),
              ),
            ),
        ],
      ),
    );
  }
}
