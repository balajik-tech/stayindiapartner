import '../entities/owner_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentOwnerUseCase {
  final AuthRepository repository;

  const GetCurrentOwnerUseCase(this.repository);

  Future<OwnerEntity> call() => repository.getCurrentOwner();
}
