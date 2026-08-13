import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/executive_member_entity.dart';
import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

class ExecutiveMemberTile extends StatelessWidget {
  final ExecutiveMemberEntity member;
  final CommunityThemeEntity theme;
  final bool showDivider;
  final VoidCallback? onTap;

  const ExecutiveMemberTile({
    super.key,
    required this.member,
    required this.theme,
    this.showDivider = true,
    this.onTap,
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              border: Border.all(color: badgeBorder.withValues(alpha: 0.6)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${member.phone?.trim().isNotEmpty == true ? member.phone : ''}',
                              style: GoogleFonts.inter(fontSize: 10.5, color: badgeText),
                            ),
                          ),
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
}