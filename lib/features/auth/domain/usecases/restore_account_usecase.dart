import '../repositories/auth_repository.dart';

class RestoreAccountUseCase {
  final AuthRepository repository;

  RestoreAccountUseCase(this.repository);

  Future<void> call(String action) {
    return repository.restoreAccount(action);
  }
}
