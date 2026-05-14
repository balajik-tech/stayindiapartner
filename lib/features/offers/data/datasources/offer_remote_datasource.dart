import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/offer_entity.dart';

abstract class OfferRemoteDataSource {
  Future<List<OfferEntity>> getOffers({String? hostelId, String? createdBy});
  Future<OfferEntity> createOffer(OfferEntity offer);
  Future<OfferEntity> updateOffer(String id, Map<String, dynamic> updateData);
  Future<void> deleteOffer(String id);
}

class OfferRemoteDataSourceImpl implements OfferRemoteDataSource {
  final Dio _dio;

  OfferRemoteDataSourceImpl(this._dio);

  @override
  Future<List<OfferEntity>> getOffers({String? hostelId, String? createdBy}) async {
    final Map<String, dynamic> params = {};
    if (hostelId != null) params['hostelId'] = hostelId;
    if (createdBy != null) params['createdBy'] = createdBy;

    final response = await _dio.get(
      ApiConstants.offers,
      queryParameters: params.isNotEmpty ? params : null,
    );

    if (response.statusCode == 200) {
      final dynamic responseData = response.data['data'];
      final List results = (responseData is List) ? responseData : [];
      return results.map((json) => OfferEntity.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch offers');
  }

  @override
  Future<OfferEntity> createOffer(OfferEntity offer) async {
    final response = await _dio.post(
      ApiConstants.offers,
      data: offer.toJson(),
    );

    if (response.statusCode == 201) {
      return OfferEntity.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to create offer');
  }

  @override
  Future<OfferEntity> updateOffer(String id, Map<String, dynamic> updateData) async {
    final response = await _dio.put(
      '${ApiConstants.offers}/$id',
      data: updateData,
    );

    if (response.statusCode == 200) {
      return OfferEntity.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update offer');
  }

  @override
  Future<void> deleteOffer(String id) async {
    final response = await _dio.delete('${ApiConstants.offers}/$id');
    if (response.statusCode != 200) {
      throw Exception(response.data['message'] ?? 'Failed to delete offer');
    }
  }
}
