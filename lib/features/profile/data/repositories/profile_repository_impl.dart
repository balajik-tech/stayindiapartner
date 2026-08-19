import 'dart:io';
import 'package:stayindia_owner/features/profile/domain/entities/profile_entity.dart';
import 'package:stayindia_owner/features/profile/domain/entities/dl_kyc_entity.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/profile_repository.dart';
import 'package:stayindia_owner/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity> getProfile() => remoteDataSource.getProfile();

  @override
  Future<ProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? dob,
    String? gender,
    DlKycEntity? dlKyc,
  }) {
    return remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      address: address,
      dob: dob,
      gender: gender,
      dlKyc: dlKyc,
    );
  }

  @override
  Future<ProfileEntity> uploadAvatar(File image) async {
    final compressedImage = await _compressImage(image);
    return remoteDataSource.uploadAvatar(compressedImage ?? image);
  }

  @override
  Future<void> deleteAccount() => remoteDataSource.deleteAccount();

  @override
  Future<void> deactivateAccount(String action) => remoteDataSource.deactivateAccount(action);

  @override
  Future<String> generateReferralId() => remoteDataSource.generateReferralId();

  @override
  Future<String> getRateUsUrl() => remoteDataSource.getRateUsUrl();

  Future<File?> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        "${DateTime.now().millisecondsSinceEpoch}_compressed.jpg",
      );

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
