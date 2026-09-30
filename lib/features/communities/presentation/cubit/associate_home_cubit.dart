import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/association_details_entity.dart';
import '../../domain/usecases/get_executive_committee_usecase.dart';
import '../../domain/usecases/get_executive_members_usecase.dart';
import '../../domain/usecases/get_it_wing_members_usecase.dart';
import '../../domain/usecases/get_port_members_usecase.dart';
import '../../domain/usecases/get_community_wings_usecase.dart';
import '../../domain/usecases/get_community_theme_usecase.dart';
import '../../domain/usecases/get_association_details_usecase.dart';
import 'associate_home_state.dart';

class AssociateHomeDataCubit extends Cubit<AssociateHomeDataState> {
  final GetExecutiveCommitteeUseCase getExecutiveCommittee;
  final GetExecutiveMembersUseCase getExecutiveMembers;
  final GetItWingMembersUseCase getItWingMembers;
  final GetPortMembersUseCase getPortMembers;
  final GetCommunityWingsUseCase getCommunityWings;
  final GetCommunityThemeUseCase getCommunityTheme;
  final GetAssociationDetailsUseCase getAssociationDetails;

  AssociateHomeDataCubit({
    required this.getExecutiveCommittee,
    required this.getExecutiveMembers,
    required this.getItWingMembers,
    required this.getPortMembers,
    required this.getCommunityWings,
    required this.getCommunityTheme,
    required this.getAssociationDetails,
  }) : super(const AssociateHomeDataInitial());

  Future<void> loadCommunityData(String associationId) async {
    emit(const AssociateHomeDataLoading());
    try {
      dynamic theme;
      try {
        theme = await getCommunityTheme(associationId);
      } catch (_) {}

      AssociationDetailsEntity? details;
      String? detailsError;

      try {
        details = await getAssociationDetails(associationId);
      } catch (e) {
        detailsError = _extractErrorString(e);
      }

      List executiveCommittee = [];
      List executiveMembers = [];
      List itWingMembers = [];
      List portMembers = [];
      List communityWings = [];

      try {
        executiveCommittee = await getExecutiveCommittee(associationId);
      } catch (e) {
        detailsError ??= _extractErrorString(e);
      }

      try {
        executiveMembers = await getExecutiveMembers(associationId);
      } catch (e) {
        detailsError ??= _extractErrorString(e);
      }

      try {
        itWingMembers = await getItWingMembers(associationId);
      } catch (e) {
        detailsError ??= _extractErrorString(e);
      }

      try {
        portMembers = await getPortMembers(associationId);
      } catch (e) {
        detailsError ??= _extractErrorString(e);
      }

      try {
        communityWings = await getCommunityWings(associationId);
      } catch (e) {
        detailsError ??= _extractErrorString(e);
      }

      // Ensure theme is non-null
      theme ??= await getCommunityTheme(associationId);

      emit(
        AssociateHomeDataLoaded(
          theme: theme,
          executiveCommittee: executiveCommittee.cast(),
          executiveMembers: executiveMembers.cast(),
          itWingMembers: itWingMembers.cast(),
          portMembers: portMembers.cast(),
          communityWings: communityWings.cast(),
          details: details,
          detailsError: detailsError,
        ),
      );
    } catch (e) {
      emit(AssociateHomeDataError(_extractErrorString(e)));
    }
  }

  String _extractErrorString(Object error) {
    String msg = error.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.substring('Exception: '.length);
    }
    return msg;
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