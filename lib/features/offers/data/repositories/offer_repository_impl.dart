import '../../domain/entities/offer_entity.dart';
import '../../domain/repositories/offer_repository.dart';
import '../datasources/offer_remote_datasource.dart';

class OfferRepositoryImpl implements OfferRepository {
  final OfferRemoteDataSource remoteDataSource;

  OfferRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OfferEntity>> getOffers({
    String? hostelId,
    String? createdBy,
  }) async {
    return await remoteDataSource.getOffers(
      hostelId: hostelId,
      createdBy: createdBy,
    );
  }

  @override
  Future<OfferEntity> createOffer(OfferEntity offer) async {
    return await remoteDataSource.createOffer(offer);
  }

  @override
  Future<OfferEntity> updateOffer(
    String id,
    Map<String, dynamic> updateData,
  ) async {
    return await remoteDataSource.updateOffer(id, updateData);
  }

  @override
  Future<void> deleteOffer(String id) async {
    return await remoteDataSource.deleteOffer(id);
  }

  @override
  Future<String> uploadOfferImage(String filePath) async {
    return await remoteDataSource.uploadOfferImage(filePath);
  }
}
