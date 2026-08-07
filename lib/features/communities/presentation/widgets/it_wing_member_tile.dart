import 'package:flutter/material.dart';

import '../../domain/entities/it_wing_member_entity.dart';
import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

class ItWingMemberTile extends StatelessWidget {
  final ItWingMemberEntity member;
  final CommunityThemeEntity theme;
  final bool showDivider;

  const ItWingMemberTile({
    super.key,
    required this.member,
    required this.theme,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = theme.textSecondary.toColor();
    final badgeBg = theme.badgeBackground.toColor();
    final badgeBorder = theme.badgeBorder.toColor();
    final badgeText = theme.badgeText.toColor();
    final accent = theme.accentColor.toColor();

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
                    Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(member.role, style: TextStyle(fontSize: 12.5, color: textSecondary)),
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
                  style: TextStyle(fontSize: 11.5, color: badgeText, fontFamily: 'monospace'),
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