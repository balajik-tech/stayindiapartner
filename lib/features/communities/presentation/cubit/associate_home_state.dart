import 'package:equatable/equatable.dart';

import '../../domain/entities/associate_member_entity.dart';
import '../../domain/entities/executive_member_entity.dart';
import '../../domain/entities/it_wing_member_entity.dart';
import '../../domain/entities/community_theme_entity.dart';
import '../../domain/entities/association_details_entity.dart';

enum AccordionSection { executiveCommittee, executiveMembers, itWing }

abstract class AssociateHomeDataState extends Equatable {
  const AssociateHomeDataState();

  @override
  List<Object?> get props => [];
}

class AssociateHomeDataInitial extends AssociateHomeDataState {
  const AssociateHomeDataInitial();
}

class AssociateHomeDataLoading extends AssociateHomeDataState {
  const AssociateHomeDataLoading();
}

class AssociateHomeDataError extends AssociateHomeDataState {
  final String message;
  const AssociateHomeDataError(this.message);

  @override
  List<Object?> get props => [message];
}

class AssociateHomeDataLoaded extends AssociateHomeDataState {
  final CommunityThemeEntity theme;
  final List<CommitteeMemberEntity> executiveCommittee;
  final List<ExecutiveMemberEntity> executiveMembers;
  final List<ItWingMemberEntity> itWingMembers;
  final AssociationDetailsEntity? details;
  final String? detailsError;

  /// Tracks which accordion section(s) are currently expanded.
  final Set<AccordionSection> expandedSections;

  const AssociateHomeDataLoaded({
    required this.theme,
    required this.executiveCommittee,
    required this.executiveMembers,
    required this.itWingMembers,
    this.details,
    this.detailsError,
    this.expandedSections = const {AccordionSection.executiveCommittee},
  });

  AssociateHomeDataLoaded copyWith({
    CommunityThemeEntity? theme,
    List<CommitteeMemberEntity>? executiveCommittee,
    List<ExecutiveMemberEntity>? executiveMembers,
    List<ItWingMemberEntity>? itWingMembers,
    AssociationDetailsEntity? details,
    String? detailsError,
    Set<AccordionSection>? expandedSections,
  }) {
    return AssociateHomeDataLoaded(
      theme: theme ?? this.theme,
      executiveCommittee: executiveCommittee ?? this.executiveCommittee,
      executiveMembers: executiveMembers ?? this.executiveMembers,
      itWingMembers: itWingMembers ?? this.itWingMembers,
      details: details ?? this.details,
      detailsError: detailsError ?? this.detailsError,
      expandedSections: expandedSections ?? this.expandedSections,
    );
  }

  @override
  List<Object?> get props => [
        theme,
        executiveCommittee,
        executiveMembers,
        itWingMembers,
        details,
        detailsError,
        expandedSections,
      ];
}
