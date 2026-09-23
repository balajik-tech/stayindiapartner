import 'package:google_sign_in/google_sign_in.dart';
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
  }) : _remote = remote,
       _tokenStorage = tokenStorage;

  @override
  Future<String?> requestOtp(String phone, {String? hashId, int? fileType}) =>
      _remote.requestOtp(phone, hashId: hashId, fileType: fileType);

  @override
  Future<({OwnerEntity owner, bool isNewUser})> verifyOtp(
    String phone,
    String otp, {
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) async {
    final result = await _remote.verifyOtp(
      phone,
      otp,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
    );

    return (owner: result.owner as OwnerEntity, isNewUser: result.isNewUser);
  }

  @override
  Future<Map<String, dynamic>> loginWithGoogle(String role) async {
    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google Sign-In was cancelled by the user.');
      }
      final name = account.displayName ?? 'Owner';
      final email = account.email;
      final avatar = account.photoUrl ?? '';

      final result = await _remote.googleLogin(
        email: email,
        name: name,
        avatar: avatar,
        role: role,
      );
      return result;
    } catch (e) {
      rethrow;
    }
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
  Future<Map<String, dynamic>> restoreAccount(String action) => _remote.restoreAccount(action);

  @override
  Future<bool> hasActiveSession() => _tokenStorage.hasToken();

  @override
  Future<void> updateDeviceToken({
    required String pushToken,
    required String platform,
    String? deviceId,
  }) => _remote.updateDeviceToken(
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

  @override
  Future<OwnerEntity> linkPhone(String phone) =>
      _remote.linkPhone(phone);
}
