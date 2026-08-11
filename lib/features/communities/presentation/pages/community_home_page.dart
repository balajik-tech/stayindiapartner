import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';

import '../cubit/associate_home_cubit.dart';
import '../cubit/associate_home_state.dart';
import '../widgets/hero_header_widget.dart';
import '../widgets/membership_card_widget.dart';
import '../widgets/accordion_section_widget.dart';
import '../widgets/committee_member_tile.dart';
import '../widgets/executive_member_tile.dart';
import '../widgets/it_wing_member_tile.dart';
import '../widgets/port_member_tile.dart';
import '../widgets/hex_color.dart';
import 'executive_member_detail_page.dart';

class AssociateHomePage extends StatelessWidget {
  final String associationId;
  const AssociateHomePage({super.key, required this.associationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AssociateHomeDataCubit>()..loadCommunityData(associationId),
      child: const _CommunityHomeView(),
    );
  }
}

class _CommunityHomeView extends StatelessWidget {
  const _CommunityHomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssociateHomeDataCubit, AssociateHomeDataState>(
      builder: (context, state) {
        if (state is AssociateHomeDataLoading || state is AssociateHomeDataInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is AssociateHomeDataError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.message, textAlign: TextAlign.center),
              ),
            ),
          );
        }

        final loaded = state as AssociateHomeDataLoaded;
        final theme = loaded.theme;
        final cubit = context.read<AssociateHomeDataCubit>();

        return Scaffold(
          backgroundColor: theme.backgroundColor.toColor(),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroHeaderWidget(
                    theme: theme,
                    details: loaded.details,
                    detailsError: loaded.detailsError,
                  ),
                  MembershipCardWidget(theme: theme),
                  const SizedBox(height: 8),

                  // Executive Committee
                  AccordionSectionWidget(
                    theme: theme,
                    title: 'Executive Committee',
                    subtitle: 'State office bearers',
                    count: loaded.executiveCommittee.length,
                    isExpanded: loaded.expandedSections.contains(AccordionSection.executiveCommittee),
                    onToggle: () => cubit.toggleSection(AccordionSection.executiveCommittee),
                    children: [
                      for (var i = 0; i < loaded.executiveCommittee.length; i++)
                        CommitteeMemberTile(
                          member: loaded.executiveCommittee[i],
                          theme: theme,
                          showDivider: i != loaded.executiveCommittee.length - 1,
                        ),
                    ],
                  ),


                  // Executive Members
                  AccordionSectionWidget(
                    theme: theme,
                    title: 'Executive Members',
                    subtitle: 'Photo, name & zone',
                    count: loaded.executiveMembers.length,
                    isExpanded: loaded.expandedSections.contains(AccordionSection.executiveMembers),
                    onToggle: () => cubit.toggleSection(AccordionSection.executiveMembers),
                    footer: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Tap a member to open their zone & core members.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                        child: Text(
                          'Tap a member to open their zone & core members.',
                          style: GoogleFonts.inter(fontSize: 12.5, color: Colors.grey),
                        ),
                      ),
                      for (var i = 0; i < loaded.executiveMembers.length; i++)
                        ExecutiveMemberTile(
                          member: loaded.executiveMembers[i],
                          theme: theme,
                          showDivider: i != loaded.executiveMembers.length - 1,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExecutiveMemberDetailPage(
                                  member: loaded.executiveMembers[i],
                                  theme: theme,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),

                  // IT Wing
                  AccordionSectionWidget(
                    theme: theme,
                    title: 'IT Wing',
                    subtitle: 'Technology & digital team',
                    count: loaded.itWingMembers.length,
                    isExpanded: loaded.expandedSections.contains(AccordionSection.itWing),
                    onToggle: () => cubit.toggleSection(AccordionSection.itWing),
                    children: [
                      for (var i = 0; i < loaded.itWingMembers.length; i++)
                        ItWingMemberTile(
                          member: loaded.itWingMembers[i],
                          theme: theme,
                          showDivider: i != loaded.itWingMembers.length - 1,
                        ),
                    ],
                  ),

                  // IT Wing
                  AccordionSectionWidget(
                    theme: theme,
                    title: 'Port Members',
                    subtitle: '',
                    count: loaded.portMembers.length,
                    isExpanded: loaded.expandedSections.contains(AccordionSection.portMembers),
                    onToggle: () => cubit.toggleSection(AccordionSection.portMembers),
                    children: [
                      for (var i = 0; i < loaded.portMembers.length; i++)
                        PortMemberTile(
                          member: loaded.portMembers[i],
                          theme: theme,
                          showDivider: i != loaded.portMembers.length - 1,
                        ),
                    ],
                  ),


                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '——  Office Bearers & Members Directory  ——',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
