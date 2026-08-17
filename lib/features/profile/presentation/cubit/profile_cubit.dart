import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/utils/image_utils.dart';
import 'package:stayindia_owner/features/profile/domain/entities/profile_entity.dart';
import 'package:stayindia_owner/features/profile/domain/entities/dl_kyc_entity.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/profile_usecases.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final ProfileEntity profile;
  final String message;
  const ProfileUpdateSuccess(
    this.profile, {
    this.message = 'Profile updated successfully',
  });
  @override
  List<Object?> get props => [profile, message];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final UploadAvatarUseCase _uploadAvatar;
  final DeleteOwnerAccountUseCase _deleteAccount;
  final GenerateReferralUseCase _generateReferral;
  final GetRateUsUrlUseCase _getRateUsUrl;

  ProfileCubit({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UploadAvatarUseCase uploadAvatarUseCase,
    required DeleteOwnerAccountUseCase deleteOwnerAccountUseCase,
    required GenerateReferralUseCase generateReferralUseCase,
    required GetRateUsUrlUseCase getRateUsUrlUseCase,
  }) : _getProfile = getProfileUseCase,
       _updateProfile = updateProfileUseCase,
       _uploadAvatar = uploadAvatarUseCase,
       _deleteAccount = deleteOwnerAccountUseCase,
       _generateReferral = generateReferralUseCase,
       _getRateUsUrl = getRateUsUrlUseCase,
       super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await _getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      AppLogger.error('loadProfile failed', e);
      emit(ProfileError(ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<String?> generateReferral() async {
    try {
      return await _generateReferral();
    } catch (e) {
      AppLogger.error('generateReferral failed', e);
      return null;
    }
  }

  Future<String?> getRateUsUrl() async {
    try {
      return await _getRateUsUrl();
    } catch (e) {
      AppLogger.error('getRateUsUrl failed', e);
      return null;
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
    DlKycEntity? dlKyc,
  }) async {
    emit(ProfileUpdating());
    try {
      final profile = await _updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        dob: dob,
        gender: gender,
        dlKyc: dlKyc,
      );
      emit(ProfileUpdateSuccess(profile));
      emit(ProfileLoaded(profile));
    } catch (e) {
      AppLogger.error('updateProfile failed', e);
      emit(ProfileError(ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> uploadProfileImage(File image) async {
    emit(ProfileUpdating());
    try {
      final compressedImage = await ImageUtils.compressImage(image) ?? image;
      final profile = await _uploadAvatar(compressedImage);
      emit(ProfileUpdateSuccess(profile, message: 'Profile picture updated'));
      emit(ProfileLoaded(profile));
    } catch (e) {
      AppLogger.error('uploadProfileImage failed', e);
      emit(ProfileError(ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> deleteAccount() async {
    emit(ProfileLoading());
    try {
      await _deleteAccount();
    } catch (e) {
      AppLogger.error('deleteAccount failed', e);
      emit(ProfileError(ErrorHelper.toFriendlyMessage(e)));
    }
  }
}
