import '../entities/association_details_entity.dart';
import '../repositories/associate_repository.dart';

class GetAssociationDetailsUseCase {
  final AssociateRepository repository;
  const GetAssociationDetailsUseCase(this.repository);

  Future<AssociationDetailsEntity> call(String id) => repository.getAssociationDetails(id);
}
