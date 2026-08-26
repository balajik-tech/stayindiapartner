import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/executive_member_entity.dart';
import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

class ExecutiveMemberTile extends StatelessWidget {
  final ExecutiveMemberEntity member;
  final CommunityThemeEntity theme;
  final bool showDivider;
  final VoidCallback? onTap;
  final Map<String, dynamic>? timeline;

  const ExecutiveMemberTile({
    super.key,
    required this.member,
    required this.theme,
    this.showDivider = true,
    this.onTap,
    this.timeline,
  });



  @override
  Widget build(BuildContext context) {
    final textSecondary = theme.textSecondary.toColor();
    final badgeBg = theme.badgeBackground.toColor();
    final badgeBorder = theme.badgeBorder.toColor();
    final badgeText = theme.badgeText.toColor();
    final accent = theme.accentColor.toColor();
    final textPrimary = theme.textPrimary.toColor();
    final primary = theme.primaryColor.toColor();


    String? statusText;
    if (timeline != null) {
      if (timeline!['idIssued'] == true) {
        statusText = 'ID ISSUED';
      } else if (timeline!['paid'] == true) {
        statusText = 'PAID';
      } else if (timeline!['approved'] == true) {
        statusText = 'APPROVED';
      } else if (timeline!['applied'] == true) {
        statusText = 'APPLIED';
      }
    }

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: accent.withValues(alpha: 0.15),
                  backgroundImage: member.photoUrl.isNotEmpty ? NetworkImage(member.photoUrl) : null,
                  child: member.photoUrl.isEmpty ? Icon(Icons.person, color: accent) : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600,
                      color: textPrimary)),
                      if (member.role.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          member.role,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: member.isHighlighted ? primary : textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.circle, size: 6, color: accent),
                              const SizedBox(width: 6),
                              Text(
                                member.zone,
                                style: GoogleFonts.inter(fontSize: 13, color: accent, fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          const SizedBox(width: 8),
                           if(statusText == true)...[
                              Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => _makePhoneCall(member.phone ?? ''),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.phone_rounded,
                                      size: 20,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 16),

                              InkWell(
                                onTap: () => _openWhatsApp(member.phone ?? ''),
                                child: Image.asset(
                                  'assets/images/whatsapp.png',
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                           ]
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: textSecondary),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, indent: 18, endIndent: 18, color: Colors.grey.shade200),
      ],
    );
  }
  Future<void> _makePhoneCall(String phone) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');

    final Uri uri = Uri.parse(
      'https://wa.me/$cleanNumber',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}