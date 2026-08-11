import '../entities/community_theme_entity.dart';
import '../repositories/associate_repository.dart';

class GetCommunityThemeUseCase {
  final AssociateRepository repository;
  const GetCommunityThemeUseCase(this.repository);

  Future<CommunityThemeEntity> call(String associationId) => repository.getCommunityTheme(associationId);
}