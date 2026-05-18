import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/domain/usecases/community_usecases.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';

abstract class OwnerCommunityState extends Equatable {
  const OwnerCommunityState();
  @override
  List<Object?> get props => [];
}

class OwnerCommunityInitial extends OwnerCommunityState {}

class OwnerCommunityLoading extends OwnerCommunityState {}

class OwnerCommunityLoaded extends OwnerCommunityState {
  final List<CommunityDetailsEntity> joinedCommunities;
  final List<CommunityDetailsEntity> availableCommunities;
  final List<Map<String, dynamic>> pendingRequests;
  final bool isJoining;
  final bool isCreating;

  const OwnerCommunityLoaded({
    required this.joinedCommunities,
    required this.availableCommunities,
    this.pendingRequests = const [],
    this.isJoining = false,
    this.isCreating = false,
  });

  OwnerCommunityLoaded copyWith({
    List<CommunityDetailsEntity>? joinedCommunities,
    List<CommunityDetailsEntity>? availableCommunities,
    List<Map<String, dynamic>>? pendingRequests,
    bool? isJoining,
    bool? isCreating,
  }) {
    return OwnerCommunityLoaded(
      joinedCommunities: joinedCommunities ?? this.joinedCommunities,
      availableCommunities: availableCommunities ?? this.availableCommunities,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      isJoining: isJoining ?? this.isJoining,
      isCreating: isCreating ?? this.isCreating,
    );
  }

  @override
  List<Object?> get props => [
    joinedCommunities,
    availableCommunities,
    pendingRequests,
    isJoining,
    isCreating,
  ];
}

class OwnerCommunityError extends OwnerCommunityState {
  final String message;
  const OwnerCommunityError({required this.message});
  @override
  List<Object?> get props => [message];
}

class OwnerCommunityCubit extends Cubit<OwnerCommunityState> {
  final GetJoinedOwnerCommunitiesUseCase _getJoined;
  final GetAvailableOwnerCommunitiesUseCase _getAvailable;
  final JoinOwnerCommunityUseCase _join;
  final CreateOwnerCommunityUseCase _create;
  final GetPendingJoinRequestsUseCase _getPending;
  final HandleJoinRequestUseCase _handleRequest;

  OwnerCommunityCubit({
    required GetJoinedOwnerCommunitiesUseCase getJoinedOwnerCommunitiesUseCase,
    required GetAvailableOwnerCommunitiesUseCase
    getAvailableOwnerCommunitiesUseCase,
    required JoinOwnerCommunityUseCase joinOwnerCommunityUseCase,
    required CreateOwnerCommunityUseCase createOwnerCommunityUseCase,
    required GetPendingJoinRequestsUseCase getPendingJoinRequestsUseCase,
    required HandleJoinRequestUseCase handleJoinRequestUseCase,
  }) : _getJoined = getJoinedOwnerCommunitiesUseCase,
       _getAvailable = getAvailableOwnerCommunitiesUseCase,
       _join = joinOwnerCommunityUseCase,
       _create = createOwnerCommunityUseCase,
       _getPending = getPendingJoinRequestsUseCase,
       _handleRequest = handleJoinRequestUseCase,
       super(OwnerCommunityInitial());

  Future<void> loadCommunities() async {
    emit(OwnerCommunityLoading());
    try {
      final results = await Future.wait([
        _getJoined(),
        _getAvailable(),
        _getPending(),
      ]);
      emit(
        OwnerCommunityLoaded(
          joinedCommunities: results[0] as List<CommunityDetailsEntity>,
          availableCommunities: results[1] as List<CommunityDetailsEntity>,
          pendingRequests: results[2] as List<Map<String, dynamic>>,
        ),
      );
    } catch (e) {
      emit(OwnerCommunityError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> discoverCommunities({
    String? level,
    String? stateId,
    String? districtId,
    String? wardId,
    String? localityId,
  }) async {
    final s = state;
    if (s is OwnerCommunityLoaded) {
      emit(OwnerCommunityLoading());
      try {
        final filters = <String, String>{};
        if (level != null) filters['level'] = level;
        if (stateId != null) filters['stateId'] = stateId;
        if (districtId != null) filters['districtId'] = districtId;
        if (wardId != null) filters['wardId'] = wardId;
        if (localityId != null) filters['localityId'] = localityId;

        final results = await _getAvailable(filters: filters);
        emit(s.copyWith(availableCommunities: results));
      } catch (e) {
        emit(OwnerCommunityError(message: ErrorHelper.toFriendlyMessage(e)));
      }
    }
  }

  Future<void> joinCommunity(String communityId) async {
    final s = state;
    if (s is OwnerCommunityLoaded) {
      emit(s.copyWith(isJoining: true));
      try {
        await _join(communityId);
        await loadCommunities();
      } catch (e) {
        emit(OwnerCommunityError(message: ErrorHelper.toFriendlyMessage(e)));
      }
    }
  }

  Future<void> handleJoinRequest(
    String communityId,
    String requesterId,
    String action,
  ) async {
    final s = state;
    if (s is OwnerCommunityLoaded) {
      try {
        await _handleRequest(
          communityId: communityId,
          requesterId: requesterId,
          action: action,
        );
        await loadCommunities();
      } catch (e) {
        emit(OwnerCommunityError(message: ErrorHelper.toFriendlyMessage(e)));
      }
    }
  }

  Future<void> createCommunity(
    String name,
    String description, {
    String? imagePath,
    String? coverImagePath,
    String? level,
    String? stateId,
    String? districtId,
    String? wardId,
    String? localityId,
    String? rules,
    String? executiveRole,
    String? fullName,
    String? phoneNumber,
    String? govtCertificatePath,
    String? associationCertificatePath,
  }) async {
    final s = state;
    List<CommunityDetailsEntity> joined = [];
    List<CommunityDetailsEntity> available = [];
    if (s is OwnerCommunityLoaded) {
      joined = s.joinedCommunities;
      available = s.availableCommunities;
    }
    emit(
      OwnerCommunityLoaded(
        joinedCommunities: joined,
        availableCommunities: available,
        isCreating: true,
      ),
    );
    try {
      await _create(
        name: name,
        description: description,
        imagePath: imagePath,
        coverImagePath: coverImagePath,
        level: level,
        stateId: stateId,
        districtId: districtId,
        wardId: wardId,
        localityId: localityId,
        rules: rules,
        executiveRole: executiveRole,
        fullName: fullName,
        phoneNumber: phoneNumber,
        govtCertificatePath: govtCertificatePath,
        associationCertificatePath: associationCertificatePath,
      );
      await loadCommunities();
    } catch (e) {
      emit(OwnerCommunityError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }
}
