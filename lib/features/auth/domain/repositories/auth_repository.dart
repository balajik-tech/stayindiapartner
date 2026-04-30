import '../entities/owner_entity.dart';




abstract class AuthRepository {
  
  Future<String?> requestOtp(String phone);
  Future<({OwnerEntity owner, bool isNewUser})> verifyOtp(
      String phone, String otp);
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
}
