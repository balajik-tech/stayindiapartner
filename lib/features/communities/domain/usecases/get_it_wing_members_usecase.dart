import '../entities/it_wing_member_entity.dart';
import '../repositories/associate_repository.dart';

class GetItWingMembersUseCase {
  final AssociateRepository repository;
  const GetItWingMembersUseCase(this.repository);

  Future<List<ItWingMemberEntity>> call(String associationId) => repository.getItWingMembers(associationId);
}