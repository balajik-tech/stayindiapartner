import 'dart:io';
import 'package:stayindia_owner/features/profile/domain/entities/profile_entity.dart';
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
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      address: address,
      dob: dob,
      gender: gender,
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
