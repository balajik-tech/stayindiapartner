import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/features/auth/domain/entities/owner_entity.dart';
import 'package:stayindia_owner/features/auth/domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenStorage tokenStorage,
  })  : _remote = remote,
        _tokenStorage = tokenStorage;

  @override
  Future<String?> requestOtp(String phone) => _remote.requestOtp(phone);

  @override
  Future<({OwnerEntity owner, bool isNewUser})> verifyOtp(
      String phone, String otp) async {
    final result = await _remote.verifyOtp(phone, otp);
    
    return (owner: result.owner as OwnerEntity, isNewUser: result.isNewUser);
  }

  @override
  Future<OwnerEntity> getCurrentOwner() => _remote.getCurrentOwner();

  @override
  Future<OwnerEntity> completeProfile(Map<String, dynamic> data) =>
      _remote.completeProfile(data);

  @override
  Future<OwnerEntity> updateProfile(Map<String, dynamic> data) =>
      _remote.updateProfile(data);

  @override
  Future<void> logout() => _remote.logout();

  @override
  Future<void> deleteAccount() => _remote.deleteAccount();

  @override
  Future<bool> hasActiveSession() => _tokenStorage.hasToken();

  @override
  Future<void> updateDeviceToken({
    required String pushToken,
    required String platform,
    String? deviceId,
  }) =>
      _remote.updateDeviceToken(
        pushToken: pushToken,
        platform: platform,
        deviceId: deviceId,
      );

  @override
  Future<OwnerEntity> acceptPolicy({String version = '1.0'}) =>
      _remote.acceptPolicy(version: version);

  @override
  Future<OwnerEntity> staffLogin(String phone, String password) =>
      _remote.staffLogin(phone, password);
}
