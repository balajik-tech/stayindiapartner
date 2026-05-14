import '../entities/stock_item.dart';
import '../entities/stock_transaction.dart';

abstract class StockRepository {
  Future<List<StockItem>> getStockItems(String propertyId, {String? category, String? search});
  Future<StockItem> createStockItem(StockItem stockItem);
  Future<StockItem> updateStockItem(String id, Map<String, dynamic> updates);
  Future<void> deleteStockItem(String id);
  Future<StockItem> addStock(String id, double quantity, double pricePerUnit, double totalCost, String paymentMode, DateTime entryDate, String? note);
  Future<StockItem> consumeStock(String id, double quantity, String? note);
  Future<List<StockTransaction>> getStockHistory(String id);
  Future<Map<String, dynamic>> getStockSummary(String propertyId);
}
