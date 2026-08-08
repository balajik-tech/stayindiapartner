import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/associate_member_entity.dart';
import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

class CommitteeMemberTile extends StatelessWidget {
  final CommitteeMemberEntity member;
  final CommunityThemeEntity theme;
  final bool showDivider;

  const CommitteeMemberTile({
    super.key,
    required this.member,
    required this.theme,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final textSecondary = theme.textSecondary.toColor();
    final badgeBg = theme.badgeBackground.toColor();
    final badgeBorder = theme.badgeBorder.toColor();
    final badgeText = theme.badgeText.toColor();
    final accent = theme.accentColor.toColor();
    final textPrimary = theme.textPrimary.toColor();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: accent.withValues(alpha: 0.15),
                backgroundImage: member.photoUrl.isNotEmpty ? NetworkImage(member.photoUrl) : null,
                child: member.photoUrl.isEmpty ? Icon(Icons.person, color: accent) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      member.position,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: member.isHighlighted ? FontWeight.w500 : FontWeight.w500,
                        color: member.isHighlighted ? primary : textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  border: Border.all(color: badgeBorder.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID ${member.id}',
                  style: GoogleFonts.inter(fontSize: 11, color: badgeText),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, indent: 18, endIndent: 18, color: Colors.grey.shade200),
      ],
    );
  }
}