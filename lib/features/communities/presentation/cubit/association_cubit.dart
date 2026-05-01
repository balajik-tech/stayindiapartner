import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/communities/domain/usecases/community_usecases.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';

abstract class AssociationState extends Equatable {
  const AssociationState();
  @override
  List<Object?> get props => [];
}

class AssociationInitial extends AssociationState {}

class AssociationLoading extends AssociationState {}

class AssociationLoaded extends AssociationState {
  final List<Map<String, dynamic>> states;
  final List<Map<String, dynamic>>? districts;
  final List<Map<String, dynamic>>? wards;
  final List<Map<String, dynamic>>? locals;
  final bool isSubLoading;

  const AssociationLoaded({
    required this.states,
    this.districts,
    this.wards,
    this.locals,
    this.isSubLoading = false,
  });

  AssociationLoaded copyWith({
    List<Map<String, dynamic>>? states,
    List<Map<String, dynamic>>? districts,
    List<Map<String, dynamic>>? wards,
    List<Map<String, dynamic>>? locals,
    bool? isSubLoading,
  }) {
    return AssociationLoaded(
      states: states ?? this.states,
      districts: districts ?? this.districts,
      wards: wards ?? this.wards,
      locals: locals ?? this.locals,
      isSubLoading: isSubLoading ?? this.isSubLoading,
    );
  }

  @override
  List<Object?> get props => [states, districts, wards, locals, isSubLoading];
}

class AssociationError extends AssociationState {
  final String message;
  const AssociationError(this.message);
  @override
  List<Object?> get props => [message];
}

class AssociationSuccess extends AssociationState {}

class AssociationCubit extends Cubit<AssociationState> {
  final GetAssociationsUseCase _getAssociations;
  final JoinAssociationUseCase _joinAssociation;
  final CreateAssociationUseCase _createAssociation;
  final ProfileCubit _profileCubit;

  AssociationCubit({
    required GetAssociationsUseCase getAssociationsUseCase,
    required JoinAssociationUseCase joinAssociationUseCase,
    required CreateAssociationUseCase createAssociationUseCase,
    required ProfileCubit profileCubit,
  })  : _getAssociations = getAssociationsUseCase,
        _joinAssociation = joinAssociationUseCase,
        _createAssociation = createAssociationUseCase,
        _profileCubit = profileCubit,
        super(AssociationInitial());

  Future<void> createAssociation({
    required String name,
    required String level,
    String? parentId,
  }) async {
    emit(AssociationLoading());
    try {
      await _createAssociation(
        name: name,
        level: level,
        parentId: parentId,
      );
      
      if (level == 'STATE') {
        await loadStates();
      } else if (level == 'DISTRICT' && parentId != null) {
        await loadDistricts(parentId);
      } else if (level == 'WARD' && parentId != null) {
        await loadWards(parentId);
      } else if (level == 'LOCAL' && parentId != null) {
        await loadLocals(parentId);
      }
    } catch (e) {
      emit(AssociationError(e.toString()));
    }
  }

  Future<void> loadStates() async {
    emit(AssociationLoading());
    try {
      final states = await _getAssociations(level: 'STATE');
      emit(AssociationLoaded(states: states));
    } catch (e) {
      emit(AssociationError(e.toString()));
    }
  }

  Future<void> loadDistricts(String stateId) async {
    final currentState = state;
    if (currentState is AssociationLoaded) {
      emit(currentState.copyWith(isSubLoading: true));
      try {
        final districts = await _getAssociations(parentId: stateId, level: 'DISTRICT');
        emit(currentState.copyWith(districts: districts, wards: [], locals: [], isSubLoading: false));
      } catch (e) {
        emit(AssociationError(e.toString()));
      }
    }
  }

  Future<void> loadWards(String districtId) async {
    final currentState = state;
    if (currentState is AssociationLoaded) {
      emit(currentState.copyWith(isSubLoading: true));
      try {
        final wards = await _getAssociations(parentId: districtId, level: 'WARD');
        emit(currentState.copyWith(wards: wards, locals: [], isSubLoading: false));
      } catch (e) {
        emit(AssociationError(e.toString()));
      }
    }
  }

  Future<void> loadLocals(String wardId) async {
    final currentState = state;
    if (currentState is AssociationLoaded) {
      emit(currentState.copyWith(isSubLoading: true));
      try {
        final locals = await _getAssociations(parentId: wardId, level: 'LOCAL');
        emit(currentState.copyWith(locals: locals, isSubLoading: false));
      } catch (e) {
        emit(AssociationError(e.toString()));
      }
    }
  }

  Future<void> joinAssociation(String associationId) async {
    emit(AssociationLoading());
    try {
      await _joinAssociation(associationId);
      await _profileCubit.loadProfile(); 
      emit(AssociationSuccess());
    } catch (e) {
      emit(AssociationError(e.toString()));
    }
  }
}
