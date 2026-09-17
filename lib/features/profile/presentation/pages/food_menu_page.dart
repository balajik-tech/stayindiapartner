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
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class FoodMenuPage extends StatefulWidget {
  const FoodMenuPage({super.key});

  @override
  State<FoodMenuPage> createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  late FoodMenuCubit _cubit;
  int _selectedDayIndex = 0;
  String _rotationType = 'weekly';

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _dayKeys = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  final Map<String, Map<String, List<FoodItem>>> _menuData = {};
  final bool _isApplyingTemplate = false;

  String get _hostelName {
    final state = context.read<HostelCubit>().state;
    if (state is HostelLoaded && state.hostels.isNotEmpty) {
      return state.hostels[state.selectedHostelIndex].name;
    }
    return 'Hostel';
  }

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - 1;
    final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
    final daysSinceMonday = date.difference(firstMonday).inDays;
    return (daysSinceMonday / 7).floor() + 1;
  }

  List<FoodItem> _parseFoodItems(String rawText) {
    if (rawText.isEmpty) return [];
    final parts = rawText.split(RegExp(r'[,+&/]'));
    return parts
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .map((p) => FoodItem(
              name: {'en': p},
              desc: {},
              price: 0.0,
              isVeg: true,
              isActive: true,
            ))
        .toList();
  }

  void _autoPopulateMenuBasedOnRotation() {
    final now = DateTime.now();
    final weekNum = _getWeekOfYear(now);
    
    bool useWeek1 = true;
    if (_rotationType == 'weekly') {
      useWeek1 = weekNum % 2 == 1;
    } else {
      useWeek1 = (weekNum / 2).floor() % 2 == 1;
    }

    final activeTemplate = useWeek1 ? _week1Menu : _week2Menu;
    final dayIndex = _selectedDayIndex;
    final templateDay = activeTemplate[dayIndex];
    final day = _days[dayIndex];

    setState(() {
      _menuData[day] = {
        'Breakfast': _parseFoodItems(templateDay.breakfast),
        'Lunch': _parseFoodItems(templateDay.lunch),
        'Snacks': _parseFoodItems(templateDay.snacks),
        'Dinner': _parseFoodItems(templateDay.dinner),
      };
    });

    _saveCurrentDay();
  }

  @override
  void initState() {
    super.initState();
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

  String _getSelectedDayDateString() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final targetWeekday = _selectedDayIndex + 1;
    final difference = targetWeekday - currentWeekday;
    final targetDate = now.add(Duration(days: difference));

    final dayName = DateFormat('EEEE').format(targetDate).toUpperCase();
    final monthName = DateFormat('MMMM').format(targetDate).toUpperCase();
    final dayNum = targetDate.day;

    return "$dayName, $monthName $dayNum";
  }

  String _getCurrentlyServingMeal() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final currentTime = hour + (minute / 60.0);

    if (currentTime >= 7.5 && currentTime <= 9.0) {
      return 'Breakfast';
    } else if (currentTime >= 12.5 && currentTime <= 14.5) {
      return 'Lunch';
    } else if (currentTime >= 16.0 && currentTime <= 18.0) {
      return 'Snacks';
    } else if (currentTime >= 19.5 && currentTime <= 21.5) {
      return 'Dinner';
    }

    if (hour < 11) return 'Breakfast';
    if (hour < 16) return 'Lunch';
    if (hour < 19) return 'Snacks';
    return 'Dinner';
  }

  String _getFoodEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('rice') ||
        lower.contains('biryani') ||
        lower.contains('pulao')) {
      return '🍚';
    } else if (lower.contains('dal') ||
        lower.contains('sambhar') ||
        lower.contains('rasam') ||
        lower.contains('soup')) {
      return '🥣';
    } else if (lower.contains('curry') ||
        lower.contains('paneer') ||
        lower.contains('chicken') ||
        lower.contains('meat') ||
        lower.contains('egg')) {
      return '🍛';
    } else if (lower.contains('roti') ||
        lower.contains('chapati') ||
        lower.contains('paratha') ||
        lower.contains('bread')) {
      return '🫓';
    } else if (lower.contains('fruit') ||
        lower.contains('apple') ||
        lower.contains('banana') ||
        lower.contains('salad')) {
      return '🍎';
    } else if (lower.contains('tea') ||
        lower.contains('coffee') ||
        lower.contains('milk') ||
        lower.contains('beverage')) {
      return '☕';
    } else if (lower.contains('curd') ||
        lower.contains('yogurt') ||
        lower.contains('butter')) {
      return '🥛';
    } else if (lower.contains('snacks') ||
        lower.contains('samosa') ||
        lower.contains('biscuit') ||
        lower.contains('pakoda')) {
      return '🍪';
    } else if (lower.contains('dosa') ||
        lower.contains('idli') ||
        lower.contains('poha') ||
        lower.contains('upma')) {
      return '🥞';
    }
    return '🍽️';
  }

  void _showPredefinedMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PREDEFINED MENU TEMPLATES",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Copy items to easily paste into your schedule",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFE2E8F0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppColors.primaryBlue,
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: "WEEK 1: Traditional Mix"),
                      Tab(text: "WEEK 2: Special Combos"),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTemplateWeekList(_week1Menu),
                      _buildTemplateWeekList(_week2Menu),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemplateWeekList(List<PredefinedMenuDay> days) {
    return ListView.builder(
      itemCount: days.length,
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 40.h),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final day = days[index];
        return Container(
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(23.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day.dayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "TEMPLATE",
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    _buildTemplateMealRow("Breakfast", "🌅", day.breakfast),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildTemplateMealRow("Lunch", "☀️", day.lunch),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildTemplateMealRow("Snacks", "🍪", day.snacks),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildTemplateMealRow("Dinner", "🌙", day.dinner),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateMealRow(
    String mealName,
    String emoji,
    String foodValue,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 85.w,
          child: Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 13.sp)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  mealName,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Text(
            foodValue,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: foodValue));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Copied to clipboard: $foodValue"),
                backgroundColor: AppColors.primaryBlue,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.copy_rounded,
                  size: 11.sp,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 4.w),
                Text(
                  "Copy",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoHostelView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.domain_disabled_rounded,
                color: const Color(0xFF64748B),
                size: 64.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "No Property Setup Found",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Please complete your property setup in the Property Setup section first to start managing your weekly food menu.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_rounded, size: 18.sp),
              label: const Text("Go Back"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<FoodMenuCubit, FoodMenuState>(
            listener: (context, state) {
              if (state is FoodMenuLoaded) {
                final hasBreakfast = state.menu.breakfast.isNotEmpty;
                final hasLunch = state.menu.lunch.isNotEmpty;
                final hasSnacks = state.menu.snacks.isNotEmpty;
                final hasDinner = state.menu.dinner.isNotEmpty;
                if (!hasBreakfast && !hasLunch && !hasSnacks && !hasDinner) {
                  _autoPopulateMenuBasedOnRotation();
                } else {
                  _applyMenuToLocal(state.menu);
                }
              } else if (state is FoodMenuSaved) {
                context.read<HostelCubit>().getHostels(forceRefresh: true);
              } else if (state is FoodMenuError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<HostelCubit, HostelState>(
            listener: (context, state) {
              if (state is HostelLoaded && state.hostels.isNotEmpty) {
                _loadDay();
              }
            },
          ),
        ],
        child: BlocBuilder<HostelCubit, HostelState>(
          builder: (context, hostelState) {
            if (hostelState is HostelLoading) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: _buildAppBar(),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (hostelState is HostelLoaded && hostelState.hostels.isEmpty) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: _buildAppBar(),
                body: _buildNoHostelView(),
              );
            }
            if (hostelState is! HostelLoaded) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: _buildAppBar(),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: _buildAppBar(),
              body: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLiveServingBanner(),
                      _buildRotationSelector(),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVerticalDaySelector(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(12.w, 12.h, 16.w, 10.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _getSelectedDayDateString(),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.darkText,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _showPredefinedMenuSheet(context),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 6.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryBlue.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius: BorderRadius.circular(10.r),
                                              border: Border.all(
                                                color: AppColors.primaryBlue.withValues(
                                                  alpha: 0.15,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.menu_book_rounded,
                                                  color: AppColors.primaryBlue,
                                                  size: 13.sp,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  "TEMPLATES",
                                                  style: TextStyle(
                                                    color: AppColors.primaryBlue,
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Container(
                                          padding: EdgeInsets.all(8.r),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.wb_sunny_rounded,
                                            color: Colors.amber,
                                            size: 20.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: BlocBuilder<FoodMenuCubit, FoodMenuState>(
                                      builder: (context, state) {
                                        if (state is FoodMenuLoading &&
                                            !_isApplyingTemplate) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          padding: EdgeInsets.fromLTRB(
                                            12.w,
                                            4.h,
                                            16.w,
                                            80.h,
                                          ),
                                          physics: const BouncingScrollPhysics(),
                                          child: Column(
                                            children: _mealTypes
                                                .map((type) => _buildMealColumnCard(type))
                                                .toList(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
            );
          },
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
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.darkText,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "$_hostelName Menu",
        style: TextStyle(
          color: AppColors.darkText,
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildLiveServingBanner() {
    final currentMeal = _getCurrentlyServingMeal();
    final todayIndex = DateTime.now().weekday - 1;
    final todayDayKey = _days[todayIndex];
    final items = _menuData[todayDayKey]?[currentMeal] ?? [];
    final dishText = items.isNotEmpty
        ? items.map((i) => i.getName(context.locale.languageCode)).join(" + ")
        : "Standard Hostel Special";
    final emoji = items.isNotEmpty ? _getFoodEmoji(items.first.getName(context.locale.languageCode)) : "🍽️";

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15803D).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const _PulseDot(),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NOW SERVING: ${currentMeal.toUpperCase()}",
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF166534),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      emoji,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        dishText.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF14532D),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotationSelector() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.autorenew_rounded, size: 16.sp, color: AppColors.primaryBlue),
              SizedBox(width: 6.w),
              Text(
                "MENU AUTOMATION",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildRotationButton(
                  "Weekly Rotate",
                  "Rotates Week 1/2 every week",
                  _rotationType == 'weekly',
                  () {
                    setState(() {
                      _rotationType = 'weekly';
                      _autoPopulateMenuBasedOnRotation();
                    });
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildRotationButton(
                  "2 Weeks Rotate",
                  "Rotates Week 1/2 every 2 weeks",
                  _rotationType == 'two_week',
                  () {
                    setState(() {
                      _rotationType = 'two_week';
                      _autoPopulateMenuBasedOnRotation();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRotationButton(
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: isSelected ? AppColors.primaryBlue : const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDaySelector() {
    return Container(
      width: 70.w,
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 4.w, 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFFFF).withValues(alpha: 0.85),
            const Color(0xFFF1F5F9).withValues(alpha: 0.75),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.builder(
              itemCount: _days.length,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final isSelected = _selectedDayIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDayIndex = index);
                    _loadDay();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44.h,
                    margin: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 3,
                                offset: const Offset(0, 1.5),
                              ),
                            ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _days[index].toUpperCase(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealColumnCard(String mealType) {
    final day = _days[_selectedDayIndex];
    final items = _menuData[day]?[mealType] ?? [];
    final currentlyServing = _getCurrentlyServingMeal();
    final isActive = currentlyServing == mealType;

    Color headerBg;
    Color headerText;
    String timeRange;

    switch (mealType) {
      case 'Breakfast':
        headerBg = const Color(0xFFE3F2FD);
        headerText = const Color(0xFF1565C0);
        timeRange = '07:30 - 09:00 AM';
        break;
      case 'Lunch':
        headerBg = const Color(0xFFE8F5E9);
        headerText = const Color(0xFF2E7D32);
        timeRange = '12:30 - 02:30 PM';
        break;
      case 'Snacks':
        headerBg = const Color(0xFFFFF3E0);
        headerText = const Color(0xFFEF6C00);
        timeRange = '04:00 - 06:00 PM';
        break;
      default:
        headerBg = const Color(0xFFF3E5F5);
        headerText = const Color(0xFF6A1B9A);
        timeRange = '07:30 - 09:30 PM';
        break;
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: isActive ? Border.all(color: headerText, width: 1.5) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w900,
                          color: headerText,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        timeRange,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: headerText.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => AddFoodItemSheet.show(
                    context,
                    day: _days[_selectedDayIndex],
                    mealType: mealType,
                    onSave: (itemData) {
                      setState(() {
                        _menuData[day]![mealType]!.add(
                          FoodItem(
                            name: itemData['name'],
                            desc: itemData['description'] ?? {},
                            price: itemData['price'] ?? 0.0,
                            isVeg: itemData['foodType'] == 'VEG',
                            isActive: itemData['isAvailable'] ?? true,
                          ),
                        );
                      });
                      _saveCurrentDay();
                    },
                  ),
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.add_rounded, color: headerText, size: 20.sp),
                  ),
                ),

              ],
            ),
          ),

          if (items.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  "NO MEALS ADDED YET",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              itemBuilder: (context, index) {
                final item = items[index];
                final foodName = item.getName(context.locale.languageCode);
                return Container(
                  margin: EdgeInsets.only(bottom: 4.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getFoodEmoji(foodName),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          foodName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _menuData[day]![mealType]!.removeAt(index);
                          });
                          _saveCurrentDay();
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 14.sp,
                          color: Colors.redAccent.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class PredefinedMenuDay {
  final String dayName;
  final String breakfast;
  final String lunch;
  final String snacks;
  final String dinner;

  PredefinedMenuDay({
    required this.dayName,
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
  });
}

final List<PredefinedMenuDay> _week1Menu = [
  PredefinedMenuDay(
    dayName: "Day 1",
    breakfast: "Idli + Sambar & Ginger Chutney",
    lunch: "Rice, Dal, Potato Fry, Curd",
    snacks: "Samosa + Tea",
    dinner: "Chapati, Paneer Butter Masala, White Rice",
  ),
  PredefinedMenuDay(
    dayName: "Day 2",
    breakfast: "Alu Paratha + Curd/Pickle",
    lunch: "Rice, Leafy Vegetable Dal, Brinjal Masala, Buttermilk",
    snacks: "Mirchi Bajji + Tea",
    dinner: "Rice, Tomato Dal, Chicken Curry / Mushroom Masala",
  ),
  PredefinedMenuDay(
    dayName: "Day 3",
    breakfast: "Puri + Curry (Bombay Chutney)",
    lunch: "Veg Pulao, Raitha, Papad",
    snacks: "Masala Vada + Tea",
    dinner: "Chapati, Mixed Veg Kurma, White Rice",
  ),
  PredefinedMenuDay(
    dayName: "Day 4",
    breakfast: "Pongal + Coconut Chutney",
    lunch: "Rice, Fenugreek Dal (Menthi Dal), Dondakaya Fry, Curd",
    snacks: "Onion Pakoda + Tea",
    dinner: "Veg Noodles + Veg Manchuria",
  ),
  PredefinedMenuDay(
    dayName: "Day 5",
    breakfast: "Masala Dosa + Peanut Chutney",
    lunch: "Rice, Sambar, Egg Bhurji / Omelet",
    snacks: "Alu Bonda + Tea",
    dinner: "Chapati, Dal Tadka, Jeera Rice",
  ),
  PredefinedMenuDay(
    dayName: "Day 6",
    breakfast: "Semiya Upma",
    lunch: "Rajma Chawal, White Rice, Curd",
    snacks: "Pav Bhaji / Cutlet",
    dinner: "White Sauce Pasta / Fried Rice",
  ),
  PredefinedMenuDay(
    dayName: "Day 7",
    breakfast: "Vada Sambar",
    lunch: "Chicken/Veg Dum Biryani, Raitha",
    snacks: "Biscuits/Mixture + Tea",
    dinner: "Chapati, Moong Dal Fry, White Rice",
  ),
];

final List<PredefinedMenuDay> _week2Menu = [
  PredefinedMenuDay(
    dayName: "Day 8",
    breakfast: "Pesarattu + Upma",
    lunch: "Rice, Tomato Dal, Arbi Fry (Chamagadda)",
    snacks: "Punugulu + Chutney",
    dinner: "Chapati, Alu Mutter Curry",
  ),
  PredefinedMenuDay(
    dayName: "Day 9",
    breakfast: "Gobi Paratha + Curd",
    lunch: "Rice, Drumstick Dal, Vankaya Fry",
    snacks: "Veg Cutlet + Tea",
    dinner: "Egg Noodles / Paneer Noodles",
  ),
  PredefinedMenuDay(
    dayName: "Day 10",
    breakfast: "Mysore Bajji + Chutney",
    lunch: "Lemon Rice & Curd Rice Combo",
    snacks: "Bread Pakoda + Tea",
    dinner: "Chapati, Methi Chicken / Methi Paneer",
  ),
  PredefinedMenuDay(
    dayName: "Day 11",
    breakfast: "Bread Omelet / Bread Jam",
    lunch: "Rice, Pappu Charu, Raw Banana Fry",
    snacks: "Corn Vada + Tea",
    dinner: "Red Sauce Pasta / Special Maggi",
  ),
  PredefinedMenuDay(
    dayName: "Day 12",
    breakfast: "Onion Uttapam + Chutney",
    lunch: "Rice, Spinach Dal (Palakura), Fryums",
    snacks: "Muntha Masala (Puffed Rice Mix)",
    dinner: "Chapati, Kadai Paneer, White Rice",
  ),
  PredefinedMenuDay(
    dayName: "Day 13",
    breakfast: "Semiya Bath / Lemon Semiya",
    lunch: "Bisi Bele Bath + Papad",
    snacks: "Samosa Chat",
    dinner: "Chinese Fried Rice + Chilli Chicken/Paneer",
  ),
  PredefinedMenuDay(
    dayName: "Day 14",
    breakfast: "Masala Idli / Fried Idli",
    lunch: "Bagara Rice + Dalcha / Chicken Fry",
    snacks: "Sweet (Gulab Jamun / Pastry)",
    dinner: "Chapati, Egg Curry, Rasam & Rice",
  ),
];

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 10.r,
        height: 10.r,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
