import '../../domain/entities/offer_entity.dart';

abstract class OfferRepository {
  Future<List<OfferEntity>> getOffers({String? hostelId, String? createdBy});
  Future<OfferEntity> createOffer(OfferEntity offer);
  Future<OfferEntity> updateOffer(String id, Map<String, dynamic> updateData);
  Future<void> deleteOffer(String id);
  Future<String> uploadOfferImage(String filePath);
}
