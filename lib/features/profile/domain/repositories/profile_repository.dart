import 'dart:io';
import 'package:stayindia_owner/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
  });
  Future<ProfileEntity> uploadAvatar(File image);
  Future<void> deleteAccount();
}
