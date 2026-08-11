import '../entities/executive_member_entity.dart';
import '../repositories/associate_repository.dart';

class GetExecutiveMembersUseCase {
  final AssociateRepository repository;
  const GetExecutiveMembersUseCase(this.repository);

  Future<List<ExecutiveMemberEntity>> call(String associationId) => repository.getExecutiveMembers(associationId);
}