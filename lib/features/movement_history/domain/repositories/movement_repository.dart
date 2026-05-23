import 'package:stayindia_owner/features/movement_history/data/datasources/movement_remote_datasource.dart';
import 'package:stayindia_owner/features/movement_history/domain/entities/movement_history_entity.dart';

class MovementRepository {
  final MovementRemoteDataSource remoteDataSource;

  MovementRepository({required this.remoteDataSource});

  Future<List<MovementHistoryEntity>> getLocationHistory(String tenantId) async {
    return await remoteDataSource.getLocationHistory(tenantId);
  }
}
