import 'package:stayindia_owner/features/auth/domain/entities/owner_entity.dart';
import 'package:stayindia_owner/features/auth/domain/repositories/auth_repository.dart';

class AcceptPolicyUseCase {
  final AuthRepository _repository;

  AcceptPolicyUseCase(this._repository);

  Future<OwnerEntity> call({String version = '1.0'}) {
    return _repository.acceptPolicy(version: version);
  }
}
