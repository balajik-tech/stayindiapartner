import 'package:stayindia_owner/core/error/app_exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/entities/stock_item.dart';
import 'stock_state.dart';

class StockCubit extends Cubit<StockState> {
  final StockRepository repository;

  StockCubit({required this.repository}) : super(StockInitial());

  Future<void> loadStocks(
    String propertyId, {
    String? category,
    String? search,
  }) async {
    emit(StockLoading(items: state.items, summary: state.summary));
    try {
      final items = await repository.getStockItems(
        propertyId,
        category: category,
        search: search,
      );
      final summary = await repository.getStockSummary(propertyId);
      emit(StockLoaded(items: items, summary: summary));
    } catch (e) {
      emit(StockError(GlobalErrorMapper.map(e).message));
    }
  }

  Future<void> createItem(StockItem item) async {
    emit(StockLoading(items: state.items, summary: state.summary));
    try {
      final newItem = await repository.createStockItem(item);
      final updatedItems = List<StockItem>.from(state.items)
        ..insert(0, newItem);
      emit(
        StockActionSuccess(
          'Item created successfully',
          items: updatedItems,
          summary: state.summary,
        ),
      );
      loadStocks(item.propertyId);
    } catch (e) {
      emit(
        StockError(
          GlobalErrorMapper.map(e).message,
          items: state.items,
          summary: state.summary,
        ),
      );
    }
  }

  Future<void> updateItem(
    String id,
    String propertyId,
    Map<String, dynamic> updates,
  ) async {
    emit(StockLoading(items: state.items, summary: state.summary));
    try {
      final updatedItem = await repository.updateStockItem(id, updates);
      final updatedItems = state.items
          .map((i) => i.id == id ? updatedItem : i)
          .toList();
      emit(
        StockActionSuccess(
          'Item updated successfully',
          items: updatedItems,
          summary: state.summary,
        ),
      );
      loadStocks(propertyId);
    } catch (e) {
      emit(
        StockError(
          GlobalErrorMapper.map(e).message,
          items: state.items,
          summary: state.summary,
        ),
      );
    }
  }

  Future<void> deleteItem(String id, String propertyId) async {
    emit(StockLoading(items: state.items, summary: state.summary));
    try {
      await repository.deleteStockItem(id);
      final updatedItems = state.items.where((i) => i.id != id).toList();
      emit(
        StockActionSuccess(
          'Item deleted successfully',
          items: updatedItems,
          summary: state.summary,
        ),
      );
      loadStocks(propertyId);
    } catch (e) {
      emit(
        StockError(
          GlobalErrorMapper.map(e).message,
          items: state.items,
          summary: state.summary,
        ),
      );
    }
  }

  Future<void> loadItemDetail(String id) async {
    emit(StockLoading(items: state.items, summary: state.summary));
    try {
      final item = state.items.isEmpty
          ? null
          : state.items.firstWhere((i) => i.id == id);

      final history = await repository.getStockHistory(id);

      if (item != null) {
        emit(
          StockItemDetailLoaded(
            item: item,
            history: history,
            items: state.items,
            summary: state.summary,
          ),
        );
      } else {
        emit(
          StockError(
            'Item not found in current state',
            items: state.items,
            summary: state.summary,
          ),
        );
      }
    } catch (e) {
      emit(
        StockError(
          GlobalErrorMapper.map(e).message,
          items: state.items,
          summary: state.summary,
        ),
      );
    }
  }

  Future<void> addStockTransaction(
    String id,
    String propertyId,
    double quantity,
    double pricePerUnit,
    double totalCost,
    String paymentMode,
    DateTime entryDate,
    String? note,
  ) async {
    emit(StockLoading(items: state.items, summary: state.summary));
    try {
      final updatedItem = await repository.addStock(
        id,
        quantity,
        pricePerUnit,
        totalCost,
        paymentMode,
        entryDate,
        note,
      );
      final updatedItems = state.items
          .map((i) => i.id == id ? updatedItem : i)
          .toList();
      emit(
        StockActionSuccess(
          'Stock added successfully',
          items: updatedItems,
          summary: state.summary,
        ),
      );
      await loadStocks(propertyId);
      await loadItemDetail(id);
    } catch (e) {
      emit(
        StockError(
          GlobalErrorMapper.map(e).message,
          items: state.items,
          summary: state.summary,
        ),
      );
    }
  }

  Future<void> consumeStockTransaction(
    String id,
    String propertyId,
    double quantity,
    String? note,
  ) async {
    emit(StockLoading(items: state.items, summary: state.summary));
    try {
      final updatedItem = await repository.consumeStock(id, quantity, note);
      final updatedItems = state.items
          .map((i) => i.id == id ? updatedItem : i)
          .toList();
      emit(
        StockActionSuccess(
          'Stock consumed successfully',
          items: updatedItems,
          summary: state.summary,
        ),
      );
      await loadStocks(propertyId);
      await loadItemDetail(id);
    } catch (e) {
      emit(
        StockError(
          GlobalErrorMapper.map(e).message,
          items: state.items,
          summary: state.summary,
        ),
      );
    }
  }

  Future<void> addTransaction({
    required String propertyId,
    required String itemName,
    required String category,
    required String unit,
    required double quantity,
    required double totalAmount,
    required String paymentMode,
    required String notes,
  }) async {
    emit(StockLoading(items: state.items, summary: state.summary));
    try {
      final existingItemIndex = state.items.indexWhere(
        (i) =>
            i.name.toLowerCase() == itemName.toLowerCase() &&
            i.propertyId == propertyId,
      );

      String itemId;
      double pricePerUnit = quantity > 0 ? totalAmount / quantity : 0;

      if (existingItemIndex != -1) {
        itemId = state.items[existingItemIndex].id;
      } else {
        final newItem = await repository.createStockItem(
          StockItem(
            id: '',
            propertyId: propertyId,
            name: itemName,
            category: category,
            unit: unit,
            currentQuantity: 0,
            minimumThreshold: 10,
            pricePerUnit: pricePerUnit,
            createdBy: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        itemId = newItem.id;
      }

      await repository.addStock(
        itemId,
        quantity,
        pricePerUnit,
        totalAmount,
        paymentMode,
        DateTime.now(),
        notes,
      );
      emit(
        StockActionSuccess(
          'Transaction added successfully',
          items: state.items,
          summary: state.summary,
        ),
      );
      loadStocks(propertyId);
    } catch (e) {
      emit(
        StockError(
          GlobalErrorMapper.map(e).message,
          items: state.items,
          summary: state.summary,
        ),
      );
    }
  }
}
