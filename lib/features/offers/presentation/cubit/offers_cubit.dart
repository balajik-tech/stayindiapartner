import 'package:stayindia_owner/core/error/app_exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/offer_repository.dart';
import '../../domain/entities/offer_entity.dart';
import 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  final OfferRepository repository;

  OffersCubit({required this.repository}) : super(OffersInitial());

  Future<void> fetchOffers({String? hostelId, String? createdBy}) async {
    emit(OffersLoading());
    try {
      final offers = await repository.getOffers(hostelId: hostelId, createdBy: createdBy);
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OffersError(GlobalErrorMapper.map(e).message));
    }
  }

  Future<void> createOffer(OfferEntity offer, {String? refreshHostelId, String? refreshCreatedBy}) async {
    emit(OffersLoading());
    try {
      await repository.createOffer(offer);
      emit(const OfferOperationSuccess('Offer created successfully'));
      await fetchOffers(hostelId: refreshHostelId, createdBy: refreshCreatedBy);
    } catch (e) {
      emit(OffersError(GlobalErrorMapper.map(e).message));
    }
  }

  Future<void> updateOffer(String id, Map<String, dynamic> updateData, {String? refreshHostelId, String? refreshCreatedBy}) async {
    emit(OffersLoading());
    try {
      await repository.updateOffer(id, updateData);
      emit(const OfferOperationSuccess('Offer updated successfully'));
      await fetchOffers(hostelId: refreshHostelId, createdBy: refreshCreatedBy);
    } catch (e) {
      emit(OffersError(GlobalErrorMapper.map(e).message));
    }
  }

  Future<void> deleteOffer(String id, {String? refreshHostelId, String? refreshCreatedBy}) async {
    emit(OffersLoading());
    try {
      await repository.deleteOffer(id);
      emit(const OfferOperationSuccess('Offer deleted successfully'));
      await fetchOffers(hostelId: refreshHostelId, createdBy: refreshCreatedBy);
    } catch (e) {
      emit(OffersError(GlobalErrorMapper.map(e).message));
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      return await repository.uploadOfferImage(filePath);
    } catch (e) {
      emit(OffersError(GlobalErrorMapper.map(e).message));
      return null;
    }
  }
}
