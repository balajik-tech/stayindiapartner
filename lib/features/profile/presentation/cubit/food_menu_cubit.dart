import 'package:stayindia_owner/core/utils/error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/profile/domain/entities/food_menu.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/food_menu_usecases.dart';

abstract class FoodMenuState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FoodMenuInitial extends FoodMenuState {}

class FoodMenuLoading extends FoodMenuState {}

class FoodMenuLoaded extends FoodMenuState {
  final FoodMenu menu;
  FoodMenuLoaded(this.menu);
  @override
  List<Object?> get props => [menu];
}

class FoodMenuSaving extends FoodMenuState {}

class FoodMenuSaved extends FoodMenuState {}

class FoodMenuError extends FoodMenuState {
  final String message;
  FoodMenuError(this.message);
  @override
  List<Object?> get props => [message];
}

class FoodMenuCubit extends Cubit<FoodMenuState> {
  final GetFoodMenuUseCase _getFoodMenu;
  final SaveFoodMenuUseCase _saveFoodMenu;

  FoodMenuCubit({
    required GetFoodMenuUseCase getFoodMenuUseCase,
    required SaveFoodMenuUseCase saveFoodMenuUseCase,
  })  : _getFoodMenu = getFoodMenuUseCase,
        _saveFoodMenu = saveFoodMenuUseCase,
        super(FoodMenuInitial());

  Future<void> loadMenu(String hostelId, String day) async {
    emit(FoodMenuLoading());
    try {
      final menu = await _getFoodMenu(hostelId, day);
      emit(FoodMenuLoaded(menu));
    } catch (e) {
      emit(FoodMenuError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> saveMenu(FoodMenu menu) async {
    emit(FoodMenuSaving());
    try {
      await _saveFoodMenu(menu);
      emit(FoodMenuSaved());
    } catch (e) {
      emit(FoodMenuError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
