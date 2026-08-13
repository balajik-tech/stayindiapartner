import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/community_theme_entity.dart';
import '../../domain/entities/executive_member_entity.dart';
import '../../domain/entities/executive_structure_entity.dart';
import '../cubit/executive_detail_cubit.dart';
import '../cubit/executive_detail_state.dart';
import '../widgets/hex_color.dart';

class ExecutiveMemberDetailPage extends StatelessWidget {
  final ExecutiveMemberEntity member;
  final CommunityThemeEntity theme;

  const ExecutiveMemberDetailPage({
    super.key,
    required this.member,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ExecutiveDetailCubit>()..loadStructure(member.id),
      child: _ExecutiveMemberDetailView(member: member, theme: theme),
    );
  }
}

class _ExecutiveMemberDetailView extends StatelessWidget {
  final ExecutiveMemberEntity member;
  final CommunityThemeEntity theme;

  const _ExecutiveMemberDetailView({
    required this.member,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();
    final background = theme.backgroundColor.toColor();
    final textOnPrimary = theme.textOnPrimary.toColor();
    final textPrimary = theme.textPrimary.toColor();
    final textSecondary = theme.textSecondary.toColor();
    final badgeBg = theme.badgeBackground.toColor();
    final badgeBorder = theme.badgeBorder.toColor();
    final badgeText = theme.badgeText.toColor();

    return BlocBuilder<ExecutiveDetailCubit, ExecutiveDetailState>(
      builder: (context, state) {
        List<ExecutiveStructureMemberEntity> allMembers = [];
        if (state is ExecutiveDetailLoaded) {
          for (var leader in state.leaders) {
            allMembers.add(ExecutiveStructureMemberEntity(
              id: leader.id,
              name: leader.name,
              photoUrl: leader.photoUrl,
              phone: leader.phone,
            ));
            allMembers.addAll(leader.members);
          }
        }

        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: primary,
            elevation: 0,
            leadingWidth: 100,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: textOnPrimary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chevron_left, color: textOnPrimary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: GoogleFonts.inter(
                            color: textOnPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.inter(
                    color: textOnPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  member.zone.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: textOnPrimary.withValues(alpha: 0.2),
                  child: state is ExecutiveDetailLoading
                      ? const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '${allMembers.length}',
                          style: GoogleFonts.inter(
                            color: textOnPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
          body: state is ExecutiveDetailLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Card
                      Container(
                        margin: const EdgeInsets.all(18),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: accent, width: 1.5),
                              ),
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: accent.withValues(alpha: 0.15),
                                backgroundImage: member.photoUrl.isNotEmpty ? NetworkImage(member.photoUrl) : null,
                                child: member.photoUrl.isEmpty ? Icon(Icons.person, color: accent, size: 36) : null,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  if (member.role.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      member.role,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        color: textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.circle, size: 6, color: accent),
                                      const SizedBox(width: 6),
                                      Text(
                                        member.zone,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeBg,
                                      border: Border.all(color: badgeBorder.withValues(alpha: 0.6)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${member.phone}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: badgeText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Core Members Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.diamond, color: accent, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Core Members',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${allMembers.length} members',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: badgeText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (state is ExecutiveDetailError)
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            (state as ExecutiveDetailError).message,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Core Members List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allMembers.length,
                        itemBuilder: (context, index) {
                          final core = allMembers[index];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: accent, width: 1),
                                      ),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: accent.withValues(alpha: 0.1),
                                        backgroundImage: core.photoUrl.isNotEmpty ? NetworkImage(core.photoUrl) : null,
                                        child: core.photoUrl.isEmpty ? Icon(Icons.person, color: accent) : null,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            core.name,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: badgeBg,
                                              border: Border.all(color: badgeBorder.withValues(alpha: 0.4)),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${core.phone}',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color: badgeText,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'O${index + 1}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: badgeText,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (index != allMembers.length - 1)
                                Divider(height: 1, indent: 70, endIndent: 18, color: Colors.grey.shade200),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
