import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/it_wing_member_entity.dart';
import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

class ItWingMemberTile extends StatelessWidget {
  final ItWingMemberEntity member;
  final CommunityThemeEntity theme;
  final bool showDivider;
  final Map<String, dynamic>? timeline;

  const ItWingMemberTile({
    super.key,
    required this.member,
    required this.theme,
    this.showDivider = true,
    this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = theme.textSecondary.toColor();
    final accent = theme.accentColor.toColor();
    final textPrimary = theme.textPrimary.toColor();

    bool? statusText =false;
    if (timeline != null) {
      if (timeline!['idIssued'] == true) {
        statusText = true;
      } else if (timeline!['paid'] == true) {
        statusText = true;
      } else if (timeline!['approved'] == true) {
        statusText = true;
      }
    }

    return Column(
      children: [
        Padding(
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
                    const SizedBox(height: 3),
                    Text(member.role, style: GoogleFonts.inter(fontSize: 12.5, color: textSecondary)),
                  ],
                ),
              ),
              if(statusText == true)...[
                Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _makePhoneCall(member.phone),
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
                              onTap: () => _openWhatsApp(member.phone),
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