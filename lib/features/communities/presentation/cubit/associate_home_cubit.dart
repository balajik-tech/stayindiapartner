import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_executive_committee_usecase.dart';
import '../../domain/usecases/get_executive_members_usecase.dart';
import '../../domain/usecases/get_it_wing_members_usecase.dart';
import '../../domain/usecases/get_community_theme_usecase.dart';
import '../../domain/usecases/get_association_details_usecase.dart';
import 'associate_home_state.dart';

class AssociateHomeDataCubit extends Cubit<AssociateHomeDataState> {
  final GetExecutiveCommitteeUseCase getExecutiveCommittee;
  final GetExecutiveMembersUseCase getExecutiveMembers;
  final GetItWingMembersUseCase getItWingMembers;
  final GetCommunityThemeUseCase getCommunityTheme;
  final GetAssociationDetailsUseCase getAssociationDetails;

  AssociateHomeDataCubit({
    required this.getExecutiveCommittee,
    required this.getExecutiveMembers,
    required this.getItWingMembers,
    required this.getCommunityTheme,
    required this.getAssociationDetails,
  }) : super(const AssociateHomeDataInitial());

  Future<void> loadCommunityData() async {
    emit(const AssociateHomeDataLoading());
    try {
      final results = await Future.wait([
        getCommunityTheme(),
        getExecutiveCommittee(),
        getExecutiveMembers(),
        getItWingMembers(),
      ]);

      emit(
        AssociateHomeDataLoaded(
          theme: results[0] as dynamic,
          executiveCommittee: (results[1] as List).cast(),
          executiveMembers: (results[2] as List).cast(),
          itWingMembers: (results[3] as List).cast(),
          details: null,
        ),
      );
    } catch (e) {
      emit(AssociateHomeDataError('Failed to load community data: $e'));
    }
  }

  /// Toggles a single accordion section open/closed.
  void toggleSection(AccordionSection section) {
    final current = state;
    if (current is! AssociateHomeDataLoaded) return;

    final updated = Set<AccordionSection>.from(current.expandedSections);
    if (updated.contains(section)) {
      updated.remove(section);
    } else {
      updated.add(section);
    }
    emit(current.copyWith(expandedSections: updated));
  }
}