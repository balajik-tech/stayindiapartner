import '../repositories/auth_repository.dart';

class RequestOtpViaSmsUseCase {
  final AuthRepository repository;

  const RequestOtpViaSmsUseCase(this.repository);

  Future<String?> call(String phone) => repository.requestOtpViaSms(phone);
}
