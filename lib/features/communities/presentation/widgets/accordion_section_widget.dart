import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

/// Generic collapsible section matching the "home icon | title+subtitle |
/// count badge | chevron" header seen across all three sections in the
/// screenshots.
class AccordionSectionWidget extends StatelessWidget {
  final CommunityThemeEntity theme;
  final String title;
  final String subtitle;
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;
  final Widget? footer;
  final Icon? groupIcon;
  final Map<String, dynamic>? timeline;

  const AccordionSectionWidget({
    super.key,
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
    required this.groupIcon,
    this.footer,
    this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.accentColor.toColor();
    final primary = theme.primaryColor.toColor();
    final textSecondary = theme.textSecondary.toColor();
    final cardColor = theme.cardColor.toColor();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: accent.withValues(alpha: 0.15),
                    child: groupIcon,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            color: primary,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: GoogleFonts.inter(
                            color: textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count',
                      style:  GoogleFonts.inter(color: primary, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down, color: textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
              children: [
                const Divider(height: 1),
                ...children,
                ?footer,
              ],
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}