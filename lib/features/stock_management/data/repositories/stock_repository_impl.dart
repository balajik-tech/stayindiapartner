import '../../domain/entities/stock_item.dart';
import '../../domain/entities/stock_transaction.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_remote_datasource.dart';
import '../models/stock_item_model.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource remoteDataSource;

  StockRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StockItem>> getStockItems(String propertyId, {String? category, String? search}) {
    return remoteDataSource.getStockItems(propertyId, category: category, search: search);
  }

  @override
  Future<StockItem> createStockItem(StockItem stockItem) {
    final model = stockItem is StockItemModel 
        ? stockItem 
        : StockItemModel(
            id: stockItem.id,
            propertyId: stockItem.propertyId,
            name: stockItem.name,
            nameTelugu: stockItem.nameTelugu,
            category: stockItem.category,
            unit: stockItem.unit,
            currentQuantity: stockItem.currentQuantity,
            minimumThreshold: stockItem.minimumThreshold,
            pricePerUnit: stockItem.pricePerUnit,
            createdBy: stockItem.createdBy,
            createdAt: stockItem.createdAt,
            updatedAt: stockItem.updatedAt,
          );
    return remoteDataSource.createStockItem(model);
  }

  @override
  Future<StockItem> updateStockItem(String id, Map<String, dynamic> updates) {
    return remoteDataSource.updateStockItem(id, updates);
  }

  @override
  Future<void> deleteStockItem(String id) {
    return remoteDataSource.deleteStockItem(id);
  }

  @override
  Future<StockItem> addStock(String id, double quantity, double pricePerUnit, double totalCost, String paymentMode, DateTime entryDate, String? note) {
    return remoteDataSource.addStock(id, quantity, pricePerUnit, totalCost, paymentMode, entryDate, note);
  }

  @override
  Future<StockItem> consumeStock(String id, double quantity, String? note) {
    return remoteDataSource.consumeStock(id, quantity, note);
  }

  @override
  Future<List<StockTransaction>> getStockHistory(String id) {
    return remoteDataSource.getStockHistory(id);
  }

  @override
  Future<Map<String, dynamic>> getStockSummary(String propertyId) {
    return remoteDataSource.getStockSummary(propertyId);
  }
}
