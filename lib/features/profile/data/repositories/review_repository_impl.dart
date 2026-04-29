import 'package:stayindia_owner/features/profile/domain/entities/review.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Review>> getReviews(String hostelId) async {
    return await remoteDataSource.getReviews(hostelId);
  }

  @override
  Future<Review> getReviewById(String id) async {
    return await remoteDataSource.getReviewById(id);
  }
}
