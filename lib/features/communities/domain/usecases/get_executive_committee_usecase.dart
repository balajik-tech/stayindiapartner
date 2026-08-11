import '../entities/associate_member_entity.dart';
import '../repositories/associate_repository.dart';

class GetExecutiveCommitteeUseCase {
  final AssociateRepository repository;
  const GetExecutiveCommitteeUseCase(this.repository);

  Future<List<CommitteeMemberEntity>> call(String associationId) => repository.getExecutiveCommittee(associationId);
}