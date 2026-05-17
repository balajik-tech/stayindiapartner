import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';

class RoomCategoryScreen extends StatelessWidget {
  const RoomCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertySetupCubit, PropertySetupState>(
      builder: (context, state) {
        final totalRooms = context.read<PropertySetupCubit>().totalRooms;
        final assignedRooms = context.read<PropertySetupCubit>().assignedCategoryRooms;
        final remainingRooms = totalRooms - assignedRooms;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'room_master'.tr(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2B5797),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'room_master_sub'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.roomCategories.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                      itemCount: state.roomCategories.length + 1,
                      separatorBuilder: (context, index) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        if (index == state.roomCategories.length) {
                          return _buildAddButton(context, remainingRooms);
                        }
                        return _buildCategoryCard(context, index, state.roomCategories[index], remainingRooms);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_rounded, size: 64.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
            Text(
              'no_room_master_defined'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF475569)),
            ),
          SizedBox(height: 24.h),
          _buildAddButton(context, 0),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, int index, Map<String, dynamic> category, int remaining) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'category_count'.tr(namedArgs: {'count': (index + 1).toString()}),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: const Color(0xFF2B5797)),
              ),
              IconButton(
                onPressed: () => context.read<PropertySetupCubit>().removeRoomCategory(index),
                icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<int>(
                  label: 'sharing_type_label'.tr(),
                  value: category['sharingType'],
                  items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: Text('$e ${'sharing'.tr()}'))).toList(),
                  onChanged: (val) => context.read<PropertySetupCubit>().updateRoomCategory(index, {'sharingType': val}),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDropdown<bool>(
                  label: 'room_type_label'.tr(),
                  value: category['isAC'],
                  items: [
                    DropdownMenuItem(value: true, child: Text('room_type_ac'.tr())),
                    DropdownMenuItem(value: false, child: Text('room_type_non_ac'.tr())),
                  ],
                  onChanged: (val) => context.read<PropertySetupCubit>().updateRoomCategory(index, {'isAC': val}),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: Divider(color: const Color(0xFFE2E8F0), thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  'pricing_master'.tr().toUpperCase(),
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1),
                ),
              ),
              Expanded(child: Divider(color: const Color(0xFFE2E8F0), thickness: 1)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'monthly_rent'.tr(),
                  hint: 'e.g. 8500',
                  prefix: '₹',
                  initialValue: category['monthlyRent'] ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (val) => context.read<PropertySetupCubit>().updateRoomCategory(index, {'monthlyRent': val}),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  label: 'deposit'.tr(),
                  hint: 'e.g. 5000',
                  prefix: '₹',
                  initialValue: category['securityDeposit'] ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (val) => context.read<PropertySetupCubit>().updateRoomCategory(index, {'securityDeposit': val}),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'daily_rent'.tr(),
                  hint: 'e.g. 500',
                  prefix: '₹',
                  initialValue: category['dailyRent'] ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (val) => context.read<PropertySetupCubit>().updateRoomCategory(index, {'dailyRent': val}),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  label: 'maintenance'.tr(),
                  hint: 'e.g. 500',
                  prefix: '₹',
                  initialValue: category['maintenance'] ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (val) => context.read<PropertySetupCubit>().updateRoomCategory(index, {'maintenance': val}),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            label: 'daily_rent_limit_label'.tr(),
            hint: 'e.g. 10',
            suffix: 'days',
            initialValue: category['dailyRentThresholdDays'] ?? '',
            keyboardType: TextInputType.number,
            onChanged: (val) => context.read<PropertySetupCubit>().updateRoomCategory(index, {'dailyRentThresholdDays': val}),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T value, required List<DropdownMenuItem<T>> items, required Function(T?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF2B5797), size: 24.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String initialValue,
    required Function(String) onChanged,
    String? suffix,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              if (prefix != null)
                Text(
                  prefix,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: const Color(0xFF64748B)),
                ),
              if (prefix != null) SizedBox(width: 4.w),
              Expanded(
                child: TextFormField(
                  initialValue: initialValue,
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(fontSize: 15.sp, color: const Color(0xFFCBD5E1)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                ),
              ),
              if (suffix != null)
                Text(
                  suffix,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8)),
                ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildAddButton(BuildContext context, int remaining) {
    return BouncingWrapper(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<PropertySetupCubit>().addRoomCategory();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFF2B5797).withValues(alpha: 0.3), style: BorderStyle.none),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2B5797).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: const Color(0xFF2B5797), size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'add_room_master'.tr().toUpperCase(),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: const Color(0xFF2B5797), letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
