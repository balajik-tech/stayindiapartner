import '../entities/association_portal_entity.dart';
import '../repositories/associate_repository.dart';

class GetAssociationsPortalUseCase {
  final AssociateRepository repository;

  GetAssociationsPortalUseCase(this.repository);

  Future<List<AssociationPortalEntity>> call() async {
    return await repository.getAssociations();
  }
}
