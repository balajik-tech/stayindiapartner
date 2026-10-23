import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/property_entity.dart';
import 'bank_account_tile.dart';
import 'status_badge.dart';

class PropertyBankCard extends StatelessWidget {
  final PropertyEntity property;
  final String? updatingAccountId;
  final void Function(String accountId) onSetPrimary;
  final VoidCallback onAddAccount;
  final void Function(String accountId) onEditAccount;
  final void Function(String accountId) onRemoveAccount;

  const PropertyBankCard({
    super.key,
    required this.property,
    required this.onSetPrimary,
    required this.onAddAccount,
    required this.onEditAccount,
    required this.onRemoveAccount,
    this.updatingAccountId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFcee2fa),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.apartment_outlined, color: Color(0xFF2d4f86)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style:  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.black),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${property.location} ',
                            // '· '
                            // '${property.code}',
                        style: GoogleFonts.inter(fontSize: 14, color: Color(0xFF5b5b5b),fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if(property.accounts.isNotEmpty)...[
                  StatusBadge.verified()
                ]

                // property.verificationStatus == PropertyVerificationStatus.verified
                //     ? StatusBadge.verified()
                //     : StatusBadge.pending(),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDEEF1)),
          for (int i = 0; i < property.accounts.length; i++) ...[
            BankAccountTile(
              account: property.accounts[i],
              isUpdating: updatingAccountId == property.accounts[i].id,
              onSetPrimary: () => onSetPrimary(property.accounts[i].id),
              onEdit: () => onEditAccount(property.accounts[i].id),
              onRemove: () => onRemoveAccount(property.accounts[i].id),
            ),
            if (i != property.accounts.length - 1) const Divider(height: 1, color: Color(0xFFEDEEF1)),
          ],
          const Divider(height: 1, color: Color(0xFFEDEEF1)),
          InkWell(
            onTap: onAddAccount,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18, color:  Color(0xFF284b76)),
                  const SizedBox(width: 8),
                  Text(
                    'Add account to this property',
                    style: GoogleFonts.inter(color:  const Color(0xFF284b76), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
