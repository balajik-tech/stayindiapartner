import '../entities/community_wing_entity.dart';
import '../repositories/associate_repository.dart';

class GetCommunityWingsUseCase {
  final AssociateRepository repository;
  GetCommunityWingsUseCase(this.repository);

  Future<List<CommunityWingEntity>> call(String associationId) async {
    return await repository.getCommunityWings(associationId);
  }
}
