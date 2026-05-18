import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/domain/entities/food_menu.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/food_menu_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/widgets/add_food_item_sheet.dart';
import 'package:stayindia_owner/core/widgets/shimmer_loading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class FoodMenuPage extends StatefulWidget {
  const FoodMenuPage({super.key});

  @override
  State<FoodMenuPage> createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _mealTabController;
  late FoodMenuCubit _cubit;
  int _selectedDayIndex = 0;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  final Map<String, Map<String, List<FoodItem>>> _menuData = {};
  final bool _isApplyingTemplate = false;

  @override
  void initState() {
    super.initState();
    _mealTabController = TabController(length: 4, vsync: this);
    _cubit = sl<FoodMenuCubit>();
    for (final day in _days) {
      _menuData[day] = {
        'Breakfast': [],
        'Lunch': [],
        'Dinner': [],
        'Snacks': [],
      };
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDay());
  }

  @override
  void dispose() {
    _mealTabController.dispose();
    _cubit.close();
    super.dispose();
  }

  String get _hostelId {
    final state = context.read<HostelCubit>().state;
    if (state is HostelLoaded && state.hostels.isNotEmpty) {
      return state.hostels[state.selectedHostelIndex].id;
    }
    return '';
  }

  void _loadDay() {
    final hostelId = _hostelId;
    if (hostelId.isEmpty) return;
    _cubit.loadMenu(hostelId, _dayKeys[_selectedDayIndex]);
  }

  void _applyMenuToLocal(FoodMenu menu) {
    final day = _days[_selectedDayIndex];
    setState(() {
      _menuData[day] = {
        'Breakfast': List<FoodItem>.from(menu.breakfast),
        'Lunch': List<FoodItem>.from(menu.lunch),
        'Dinner': List<FoodItem>.from(menu.dinner),
        'Snacks': List<FoodItem>.from(menu.snacks),
      };
    });
  }

  Future<void> _saveCurrentDay() async {
    final hostelId = _hostelId;
    if (hostelId.isEmpty) return;
    final day = _days[_selectedDayIndex];
    final menu = FoodMenu(
      hostelId: hostelId,
      day: _dayKeys[_selectedDayIndex],
      breakfast: _menuData[day]!['Breakfast']!,
      lunch: _menuData[day]!['Lunch']!,
      dinner: _menuData[day]!['Dinner']!,
      snacks: _menuData[day]!['Snacks']!,
    );
    await _cubit.saveMenu(menu);
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<FoodMenuCubit, FoodMenuState>(
        listener: (context, state) {
          if (state is FoodMenuLoaded) {
            _applyMenuToLocal(state.menu);
          } else if (state is FoodMenuSaved) {
            
          } else if (state is FoodMenuError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              Column(
                children: [
                  _buildDaySelector(),
                  _buildMealTypeTabs(),
                  Expanded(
                    child: BlocBuilder<FoodMenuCubit, FoodMenuState>(
                      builder: (context, state) {
                        if (state is FoodMenuLoading && !_isApplyingTemplate) {
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            itemCount: 5,
                            itemBuilder: (context, index) => const TenantCardSkeleton(),
                          );
                        }
                        return TabBarView(
                          controller: _mealTabController,
                          children: _mealTypes
                              .map((type) => _buildFoodList(type))
                              .toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (_isApplyingTemplate)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => AddFoodItemSheet.show(
              context,
              day: _days[_selectedDayIndex],
              mealType: _mealTypes[_mealTabController.index],
              onSave: (itemData) {
                final day = _days[_selectedDayIndex];
                final mealType = _mealTypes[_mealTabController.index];
                setState(() {
                  _menuData[day]![mealType]!.add(FoodItem(
                    name: itemData['name'],
                    desc: itemData['description'] ?? {},
                    price: itemData['price'] ?? 0.0,
                    isVeg: itemData['foodType'] == 'VEG',
                    isActive: itemData['isAvailable'] ?? true,
                  ));
                });
                _saveCurrentDay();
              },
            ),
            backgroundColor: AppColors.primaryBlue,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(StringUtils.translate('add_dish', context: context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        StringUtils.translate('weekly_food_menu', context: context),
        style: TextStyle(
          color: AppColors.darkText,
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }


  Widget _buildDaySelector() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: List.generate(_days.length, (index) {
            final isSelected = _selectedDayIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedDayIndex = index);
                _loadDay();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: isSelected ? [
                    BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                  ] : [],
                ),
                child: Text(
                  StringUtils.translate('day_${_dayKeys[index]}', context: context),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMealTypeTabs() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TabBar(
          controller: _mealTabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900),
          unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.zero,
          tabs: _mealTypes.map((type) => Tab(text: StringUtils.translate('meal_${type.toLowerCase()}', context: context))).toList(),
        ),
      ),
    );
  }

  Widget _buildFoodList(String mealType) {
    final day = _days[_selectedDayIndex];
    final items = _menuData[day]?[mealType] ?? [];

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: Icon(Icons.restaurant_menu_rounded, size: 40.sp, color: const Color(0xFF94A3B8)),
            ),
            SizedBox(height: 16.h),
            Text(StringUtils.translate('no_dishes_for_meal', namedArgs: {'meal': StringUtils.translate('meal_${mealType.toLowerCase()}', context: context)}, context: context),
                style: TextStyle(fontSize: 15.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Text(StringUtils.translate('add_dish_instruction', context: context),
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFFCBD5E1), fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildVegIndicator(item.isVeg),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      item.getName(context.locale.languageCode),
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _menuData[day]![mealType]!.removeAt(index);
                      });
                      _saveCurrentDay();
                    },
                    icon: Icon(Icons.delete_outline_rounded, size: 20.sp, color: Colors.redAccent.withValues(alpha: 0.7)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (item.getDesc(context.locale.languageCode).isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(item.getDesc(context.locale.languageCode), style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500, height: 1.4)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildVegIndicator(bool isVeg) {
    return Container(
      width: 14.w,
      height: 14.w,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isVeg ? Colors.green : Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
