import 'package:dio/dio.dart';
import '../models/stock_item_model.dart';
import '../models/stock_transaction_model.dart';

abstract class StockRemoteDataSource {
  Future<List<StockItemModel>> getStockItems(
    String propertyId, {
    String? category,
    String? search,
  });
  Future<StockItemModel> createStockItem(StockItemModel stockItem);
  Future<StockItemModel> updateStockItem(
    String id,
    Map<String, dynamic> updates,
  );
  Future<void> deleteStockItem(String id);
  Future<StockItemModel> addStock(
    String id,
    double quantity,
    double pricePerUnit,
    double totalCost,
    String paymentMode,
    DateTime entryDate,
    String? note,
  );
  Future<StockItemModel> consumeStock(String id, double quantity, String? note);
  Future<List<StockTransactionModel>> getStockHistory(String id);
  Future<Map<String, dynamic>> getStockSummary(String propertyId);
}

class StockRemoteDataSourceImpl implements StockRemoteDataSource {
  final Dio dio;

  StockRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StockItemModel>> getStockItems(
    String propertyId, {
    String? category,
    String? search,
  }) async {
    final response = await dio.get(
      '/owner/stocks',
      queryParameters: {
        'propertyId': propertyId,
        'category': category,
        'search': search,
      },
    );
    return (response.data as List)
        .map((json) => StockItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<StockItemModel> createStockItem(StockItemModel stockItem) async {
    final response = await dio.post('/owner/stocks', data: stockItem.toJson());
    return StockItemModel.fromJson(response.data);
  }

  @override
  Future<StockItemModel> updateStockItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await dio.put('/owner/stocks/$id', data: updates);
    return StockItemModel.fromJson(response.data);
  }

  @override
  Future<void> deleteStockItem(String id) async {
    await dio.delete('/owner/stocks/$id');
  }

  @override
  Future<StockItemModel> addStock(
    String id,
    double quantity,
    double pricePerUnit,
    double totalCost,
    String paymentMode,
    DateTime entryDate,
    String? note,
  ) async {
    final response = await dio.post(
      '/owner/stocks/$id/add',
      data: {
        'quantity': quantity,
        'pricePerUnit': pricePerUnit,
        'totalCost': totalCost,
        'paymentMode': paymentMode,
        'entryDate': entryDate.toIso8601String(),
        'note': note,
      },
    );
    return StockItemModel.fromJson(response.data['stock']);
  }

  @override
  Future<StockItemModel> consumeStock(
    String id,
    double quantity,
    String? note,
  ) async {
    final response = await dio.post(
      '/owner/stocks/$id/consume',
      data: {'quantity': quantity, 'note': note},
    );
    return StockItemModel.fromJson(response.data['stock']);
  }

  @override
  Future<List<StockTransactionModel>> getStockHistory(String id) async {
    final response = await dio.get('/owner/stocks/$id/history');
    return (response.data as List)
        .map((json) => StockTransactionModel.fromJson(json))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getStockSummary(String propertyId) async {
    final response = await dio.get(
      '/owner/stocks/summary',
      queryParameters: {'propertyId': propertyId},
    );
    return response.data;
  }
}
