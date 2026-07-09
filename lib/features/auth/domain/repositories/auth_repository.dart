import '../entities/owner_entity.dart';

abstract class AuthRepository {
  Future<String?> requestOtp(String phone);
  Future<String?> requestOtpViaSms(String phone);
  Future<({OwnerEntity owner, bool isNewUser})> verifyOtp(
    String phone,
    String otp, {
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  });
  Future<Map<String, dynamic>> loginWithGoogle(String role);
  Future<OwnerEntity> getCurrentOwner();
  Future<OwnerEntity> completeProfile(Map<String, dynamic> data);

  Future<OwnerEntity> updateProfile(Map<String, dynamic> data);

  Future<void> logout();

  Future<void> deleteAccount();

  Future<bool> hasActiveSession();
  Future<void> updateDeviceToken({
    required String pushToken,
    required String platform,
    String? deviceId,
  });
  Future<OwnerEntity> acceptPolicy({String version = '1.0'});
  Future<OwnerEntity> staffLogin(String phone, String password);
  Future<OwnerEntity> linkPhone(String phone);
}
