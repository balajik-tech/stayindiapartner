import '../repositories/auth_repository.dart';

class RestoreAccountUseCase {
  final AuthRepository repository;

  RestoreAccountUseCase(this.repository);

  Future<Map<String, dynamic>> call(String action) {
    return repository.restoreAccount(action);
  }
}
