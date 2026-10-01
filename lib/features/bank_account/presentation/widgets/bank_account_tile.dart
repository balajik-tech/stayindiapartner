import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

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

  void _showAccountDialog(
    BuildContext context, {
    required bool showDeleteAction,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        showDeleteAction
                            ? 'Delete Bank Account'
                            : 'Account Details',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: Colors.black87,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  showDeleteAction
                      ? 'Confirm to delete this account'
                      : 'View Account',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Account Holder Name',
                        value: account.accountHolderName,
                      ),
                      _DetailRow(
                        label: 'Account Number',
                        value: account.accountNumber,
                        monospace: true,
                      ),
                      _DetailRow(label: 'Bank Name', value: account.bankName),
                      _DetailRow(
                        label: 'Branch',
                        value: account.branchName,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (showDeleteAction) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          onRemove();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: const Color(0xFF4C6EF5),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Confirm & Remove Account',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: const Color(0xFF4C6EF5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVerificationPending =
        account.verificationStatus == AccountVerificationStatus.pending;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 0, bottom: 8, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: account.isPrimary
                    ? const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF254f85),
                        size: 20,
                      )
                    : const Icon(
                        Icons.radio_button_unchecked_rounded,
                        color: Color(0xFF858584),
                        size: 20,
                      ),
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
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
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
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Color(0xFF5b5b5b),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // if (isVerificationPending) ...[
                    //   const SizedBox(height: 6),
                    //   Row(
                    //     children: [
                    //       const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF9A6600)),
                    //       const SizedBox(width: 4),
                    //       const Text(
                    //         'Verification in progress',
                    //         style: TextStyle(
                    //           fontSize: 12.5,
                    //           color: Color(0xFF9A6600),
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
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
                      tooltip: '',
                      offset: const Offset(0, 40),
                      elevation: 8,
                      color: Colors.white,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      onSelected: (value) {
                        if (value == 'view') {
                          _showAccountDialog(context, showDeleteAction: false);
                        } else if (value == 'remove') {
                          _showAccountDialog(context, showDeleteAction: true);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'view',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.visibility_outlined,
                                size: 20,
                                color: Color(0xFF4B5563),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'View',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem<String>(
                          value: 'remove',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: GoogleFonts.inter(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

              // isUpdating
              //     ? const Padding(
              //   padding: EdgeInsets.all(8),
              //   child: SizedBox(
              //     width: 18,
              //     height: 18,
              //     child: CircularProgressIndicator(strokeWidth: 2),
              //   ),
              // )
              //     : PopupMenuButton<String>(
              //   icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
              //   onSelected: (value) {
              //     if (value == 'view') {
              //       _showAccountDialog(context, showDeleteAction: false);
              //     }
              //     if (value == 'remove') {
              //       _showAccountDialog(context, showDeleteAction: true);
              //     }
              //   },
              //   itemBuilder: (context) => [
              //     const PopupMenuItem(value: 'view', child: Text('View')),
              //     const PopupMenuItem(value: 'remove', child: Text('Delete')),
              //   ],
              // ),
            ],
          ),
          if (!account.isPrimary && !isUpdating)
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 2),
              child: OutlinedButton(
                onPressed: onSetPrimary,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  foregroundColor: Colors.black87,
                ),
                child: Text(
                  'Set as Primary',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
            ),

          Container(
            margin: const EdgeInsets.only(left: 30, right: 16,top: 8),
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (account.businessType.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:Color(0xFFFFE8DA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      account.businessType,
                      style: const TextStyle(
                        color: Color(0xFFF26B1A),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                SizedBox(width: 8),
                if (account.accountType.name.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: account.accountType.name == 'savings' ?
                      Color(0xFFDCFCE7):
                      Color(0xFFF2E9FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      StringUtils.captialLetter(account.accountType.name),
                      style:  TextStyle(
                        color: account.accountType.name == 'savings' ?
                        Color(0xFF15803D):
                        Color(0xFF7e57c2),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final bool showDivider;

  const _DetailRow({
    required this.label,
    required this.value,
    this.monospace = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    value,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}
