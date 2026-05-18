import '../entities/owner_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  const VerifyOtpUseCase(this.repository);

  Future<({OwnerEntity owner, bool isNewUser})> call(
    String phone,
    String otp, {
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) => repository.verifyOtp(
    phone,
    otp,
    email: email,
    firstName: firstName,
    lastName: lastName,
    avatar: avatar,
  );
}
