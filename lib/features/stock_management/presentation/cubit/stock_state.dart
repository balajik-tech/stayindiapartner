import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_item.dart';
import '../../domain/entities/stock_transaction.dart';

abstract class StockState extends Equatable {
  final List<StockItem> items;
  final Map<String, dynamic> summary;

  const StockState({
    this.items = const [],
    this.summary = const {
      'totalItems': 0,
      'lowStockCount': 0,
      'totalValue': 0.0,
      'categorySpend': {},
    },
  });

  @override
  List<Object?> get props => [items, summary];
}

class StockInitial extends StockState {
  const StockInitial() : super();
}

class StockLoading extends StockState {
  const StockLoading({super.items, super.summary});
}

class StockLoaded extends StockState {
  const StockLoaded({required super.items, required super.summary});
}

class StockItemDetailLoaded extends StockState {
  final StockItem item;
  final List<StockTransaction> history;

  const StockItemDetailLoaded({
    required this.item, 
    required this.history,
    super.items,
    super.summary,
  });

  @override
  List<Object?> get props => [item, history, items, summary];
}

class StockError extends StockState {
  final String message;
  const StockError(this.message, {super.items, super.summary});

  @override
  List<Object?> get props => [message, items, summary];
}

class StockActionSuccess extends StockState {
  final String message;
  const StockActionSuccess(this.message, {super.items, super.summary});

  @override
  List<Object?> get props => [message, items, summary];
}
