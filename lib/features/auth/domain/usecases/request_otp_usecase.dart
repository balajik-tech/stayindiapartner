import '../repositories/auth_repository.dart';

class RequestOtpUseCase {
  final AuthRepository repository;

  const RequestOtpUseCase(this.repository);

  Future<String?> call(String phone) => repository.requestOtp(phone);
}
