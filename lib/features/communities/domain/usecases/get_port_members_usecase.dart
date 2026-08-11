import '../entities/port_member_entity.dart';
import '../repositories/associate_repository.dart';

class GetPortMembersUseCase {
  final AssociateRepository repository;
  const GetPortMembersUseCase(this.repository);

  Future<List<PortMemberEntity>> call(String associationId) => repository.getPortMembers(associationId);
}
