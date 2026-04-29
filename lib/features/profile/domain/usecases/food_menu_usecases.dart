import 'package:stayindia_owner/features/profile/domain/entities/food_menu.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/food_menu_repository.dart';

class GetFoodMenuUseCase {
  final FoodMenuRepository repository;
  GetFoodMenuUseCase(this.repository);

  Future<FoodMenu> call(String hostelId, String day) {
    return repository.getFoodMenu(hostelId, day);
  }
}

class SaveFoodMenuUseCase {
  final FoodMenuRepository repository;
  SaveFoodMenuUseCase(this.repository);

  Future<void> call(FoodMenu menu) {
    return repository.saveFoodMenu(menu);
  }
}
