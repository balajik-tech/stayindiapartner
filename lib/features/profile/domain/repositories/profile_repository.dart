import 'dart:io';
import 'package:stayindia_owner/features/profile/domain/entities/profile_entity.dart';
import 'package:stayindia_owner/features/profile/domain/entities/dl_kyc_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
    DlKycEntity? dlKyc,
  });
  Future<ProfileEntity> uploadAvatar(File image);
  Future<void> deleteAccount();
  Future<String> generateReferralId();
  Future<String> getRateUsUrl();
}
