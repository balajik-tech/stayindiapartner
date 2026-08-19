import 'dart:io';
import 'package:stayindia_owner/features/profile/domain/entities/profile_entity.dart';
import 'package:stayindia_owner/features/profile/domain/entities/dl_kyc_entity.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<ProfileEntity> call() => repository.getProfile();
}

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<ProfileEntity> call({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
    DlKycEntity? dlKyc,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      address: address,
      dob: dob,
      gender: gender,
      dlKyc: dlKyc,
    );
  }
}

class UploadAvatarUseCase {
  final ProfileRepository repository;
  UploadAvatarUseCase(this.repository);

  Future<ProfileEntity> call(File image) => repository.uploadAvatar(image);
}

class DeleteOwnerAccountUseCase {
  final ProfileRepository repository;
  DeleteOwnerAccountUseCase(this.repository);

  Future<void> call() => repository.deleteAccount();
}

class DeactivateAccountUseCase {
  final ProfileRepository repository;
  DeactivateAccountUseCase(this.repository);

  Future<void> call(String action) => repository.deactivateAccount(action);
}

class GenerateReferralUseCase {
  final ProfileRepository repository;
  GenerateReferralUseCase(this.repository);

  Future<String> call() => repository.generateReferralId();
}

class GetRateUsUrlUseCase {
  final ProfileRepository repository;
  GetRateUsUrlUseCase(this.repository);

  Future<String> call() => repository.getRateUsUrl();
}
