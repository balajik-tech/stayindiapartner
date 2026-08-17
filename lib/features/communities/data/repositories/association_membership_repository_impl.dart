import '../../domain/entities/association_membership_entity.dart';
import '../../domain/repositories/association_membership_repository.dart';
import '../datasources/association_membership_remote_datasource.dart';
import '../models/association_membership_model.dart';

class AssociationMembershipRepositoryImpl implements AssociationMembershipRepository {
  final AssociationMembershipRemoteDataSource remoteDataSource;

  AssociationMembershipRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AssociationMembershipEntity>> getMyApplications(String portalId) async {
    final list = await remoteDataSource.getMyApplications(portalId);
    return list.map((e) => AssociationMembershipModel.fromJson(e)).toList();
  }

  @override
  Future<List<MembershipPropertyEntity>> getEligibleProperties() async {
    final list = await remoteDataSource.getEligibleProperties();
    return list.map((e) => MembershipPropertyModel.fromJson(e)).toList();
  }

  @override
  Future<AssociationMembershipEntity> submitApplication({
    required String portalId,
    required List<String> propertyIds,
  }) async {
    final data = await remoteDataSource.submitApplication(
      portalId: portalId,
      propertyIds: propertyIds,
    );
    return AssociationMembershipModel.fromJson(data);
  }

  @override
  Future<MembershipPaymentDetailsEntity> getPaymentDetails(String membershipId) async {
    final data = await remoteDataSource.getPaymentDetails(membershipId);
    return MembershipPaymentDetailsModel.fromJson(data);
  }
}
