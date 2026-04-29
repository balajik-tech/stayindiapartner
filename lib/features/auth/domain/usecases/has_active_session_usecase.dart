import '../repositories/auth_repository.dart';


class HasActiveSessionUseCase {
  final AuthRepository repository;

  const HasActiveSessionUseCase(this.repository);

  Future<bool> call() => repository.hasActiveSession();
}
