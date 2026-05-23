import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/core/food_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class AddFoodItemSheet extends StatefulWidget {
  final String day;
  final String mealType;
  final void Function(Map<String, dynamic> item) onSave;

  const AddFoodItemSheet({
    super.key,
    required this.day,
    required this.mealType,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required String day,
    required String mealType,
    required void Function(Map<String, dynamic> item) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddFoodItemSheet(day: day, mealType: mealType, onSave: onSave),
    );
  }

  @override
  State<AddFoodItemSheet> createState() => _AddFoodItemSheetState();
}

class _AddFoodItemSheetState extends State<AddFoodItemSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _isVeg = true;
  Map<String, String> _nameTranslations = {};
  Map<String, String> _descTranslations = {};
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final query = _nameController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final queryWords = query.split(' ').where((w) => w.isNotEmpty).toList();
    if (queryWords.isEmpty) return;

    final List<Map<String, dynamic>> allMatches = [];

    FoodConstants.foodLibrary.forEach((category, items) {
      for (final item in items) {
        final nameMap = item['name'] as Map<String, dynamic>;
        final descMap = (item['desc'] ?? {}) as Map<String, dynamic>;

        bool matches = true;
        for (final word in queryWords) {
          bool wordFound = false;

          if (nameMap.values.any(
            (val) => val.toString().toLowerCase().contains(word),
          )) {
            wordFound = true;
          }

          if (!wordFound &&
              descMap.values.any(
                (val) => val.toString().toLowerCase().contains(word),
              )) {
            wordFound = true;
          }

          if (!wordFound) {
            matches = false;
            break;
          }
        }

        if (matches) {
          final isDuplicate = allMatches.any(
            (m) => m['name']['en'] == nameMap['en'],
          );
          if (!isDuplicate) {
            allMatches.add({...item, 'originalCategory': category});
          }
        }
      }
    });

    allMatches.sort((a, b) {
      if (a['originalCategory'] == widget.mealType &&
          b['originalCategory'] != widget.mealType) {
        return -1;
      }
      if (a['originalCategory'] != widget.mealType &&
          b['originalCategory'] == widget.mealType) {
        return 1;
      }
      return 0;
    });

    setState(() {
      _suggestions = allMatches.take(10).toList();
      _showSuggestions = _suggestions.isNotEmpty;
      debugPrint(
        'Food Search Universal: query="$query", matches=${allMatches.length}, show=$_showSuggestions',
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _selectFromLibrary(Map<String, dynamic> item) {
    setState(() {
      _nameTranslations = Map<String, String>.from(item['name']);
      _descTranslations = Map<String, String>.from(item['desc'] ?? {});
      final locale = context.locale.languageCode;
      _nameController.text =
          _nameTranslations[locale] ?? _nameTranslations['en'] ?? '';
      _descController.text =
          _descTranslations[locale] ?? _descTranslations['en'] ?? '';
      _isVeg = item['isVeg'] ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24.w,
                    0,
                    24.w,
                    MediaQuery.of(context).viewInsets.bottom +
                        MediaQuery.of(context).padding.bottom +
                        24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      _buildLabel(
                        StringUtils.translate(
                          'dish_name_label',
                          context: context,
                        ),
                      ),
                      CompositedTransformTarget(
                        link: _layerLink,
                        child: _buildTextField(
                          _nameController,
                          hint: StringUtils.translate(
                            'dish_name_hint',
                            context: context,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildLabel(
                        StringUtils.translate(
                          'dish_category_label',
                          context: context,
                        ),
                      ),
                      Row(
                        children: [
                          _buildCategoryOption(
                            StringUtils.translate('veg', context: context),
                            true,
                          ),
                          SizedBox(width: 12.w),
                          _buildCategoryOption(
                            StringUtils.translate('non_veg', context: context),
                            false,
                          ),
                        ],
                      ),
                      SizedBox(height: 48.h),
                      _buildSaveButton(),
                    ],
                  ),
                ),
                if (_showSuggestions)
                  CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: Offset(0, 56.h),
                    child: Material(
                      elevation: 12,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16.r),
                      color: Colors.white,
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 300.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _suggestions
                                  .map((item) => _buildSuggestionTile(item))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(Map<String, dynamic> item) {
    final locale = context.locale.languageCode;
    final name = item['name'][locale] ?? item['name']['en'] ?? '';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectFromLibrary(item);
            _showSuggestions = false;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
          ),
          child: Row(
            children: [
              _buildVegIndicator(item['isVeg'] ?? true),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12.sp,
                color: const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVegIndicator(bool isVeg) {
    return Container(
      width: 12.w,
      height: 12.w,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isVeg ? Colors.green : Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildCategoryOption(String label, bool isVeg) {
    final isSelected = _isVeg == isVeg;
    return GestureDetector(
      onTap: () => setState(() => _isVeg = isVeg),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (isVeg ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? (isVeg ? Colors.green : Colors.red)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            _buildVegIndicator(isVeg),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isVeg ? Colors.green : Colors.red)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringUtils.translate('add_dish_to_menu', context: context),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  "${StringUtils.translate('day_${widget.day.toLowerCase()}', context: context)} • ${StringUtils.translate('meal_${widget.mealType.toLowerCase()}', context: context)}",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.greyText, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final name = _nameController.text.trim();
          final desc = _descController.text.trim();
          final locale = context.locale.languageCode;

          if (name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  StringUtils.translate(
                    'please_enter_dish_name',
                    context: context,
                  ),
                ),
              ),
            );
            return;
          }

          if (_nameTranslations.isEmpty) _nameTranslations = {'en': name};
          _nameTranslations[locale] = name;

          if (_descTranslations.isEmpty && desc.isNotEmpty) {
            _descTranslations = {'en': desc};
          }
          if (desc.isNotEmpty) _descTranslations[locale] = desc;

          Navigator.pop(context);
          widget.onSave({
            'name': _nameTranslations,
            'description': _descTranslations,
            'price': 0.0,
            'foodType': _isVeg ? 'VEG' : 'NON_VEG',
            'isAvailable': true,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          elevation: 0,
        ),
        child: Text(
          StringUtils.translate('add_to_menu', context: context),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
