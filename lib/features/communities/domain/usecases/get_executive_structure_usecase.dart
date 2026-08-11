import '../entities/executive_structure_entity.dart';
import '../repositories/associate_repository.dart';

class GetExecutiveStructureUseCase {
  final AssociateRepository repository;
  const GetExecutiveStructureUseCase(this.repository);

  Future<List<ExecutiveStructureLeaderEntity>> call(String execId) => repository.getExecutiveStructure(execId);
}
