import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';

class BulkRoomSetupScreen extends StatelessWidget {
  const BulkRoomSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room Setup',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
              ),
              _buildBulkToggle(context),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Define how many rooms and beds you have.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
          ),
          SizedBox(height: 32.h),

          _buildRangeInputs(context),
          
          SizedBox(height: 32.h),
          _buildSharingSelection(context),
          
          SizedBox(height: 32.h),
          Text(
            'Room Type',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
          ),
          SizedBox(height: 16.h),
          _buildRoomTypeSelection(context),

          SizedBox(height: 40.h),
          _buildAddButton(context),

          SizedBox(height: 40.h),
          _buildPreview(context),
        ],
      ),
    );
  }

  Widget _buildBulkToggle(BuildContext context) {
    final isBulk = context.watch<PropertySetupCubit>().state.isBulkMode;
    return GestureDetector(
      onTap: () => context.read<PropertySetupCubit>().toggleBulkMode(!isBulk),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isBulk ? AppColors.primaryBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Icon(Icons.bolt_rounded, color: isBulk ? Colors.white : Colors.grey, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              'Bulk Mode',
              style: TextStyle(
                color: isBulk ? Colors.white : Colors.grey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeInputs(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(
            label: 'Start Range',
            hint: '101',
            onChanged: (val) {
              final cubit = context.read<PropertySetupCubit>();
              cubit.updateRoomRange(val, cubit.state.roomEndRange);
            },
            initialValue: context.read<PropertySetupCubit>().state.roomStartRange,
          ),
        ),
        SizedBox(width: 16.w),
        Padding(
          padding: EdgeInsets.only(top: 24.h),
          child: Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade300),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildInputField(
            label: 'End Range',
            hint: '110',
            onChanged: (val) {
              final cubit = context.read<PropertySetupCubit>();
              cubit.updateRoomRange(cubit.state.roomStartRange, val);
            },
            initialValue: context.read<PropertySetupCubit>().state.roomEndRange,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({required String label, required String hint, required Function(String) onChanged, String? initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildSharingSelection(BuildContext context) {
    final List<int> types = [1, 2, 3, 4, 5, 6];
    final selectedType = context.watch<PropertySetupCubit>().state.sharingType;

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      alignment: WrapAlignment.start,
      children: types.map((type) {
        final isSelected = selectedType == type;
        return GestureDetector(
          onTap: () => context.read<PropertySetupCubit>().updateSharingType(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 70.w, 
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  type.toString(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : AppColors.darkText,
                  ),
                ),
                Text(
                  'Sharing',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white.withValues(alpha: 0.7) : AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoomTypeSelection(BuildContext context) {
    final List<String> types = ['AC', 'Non-AC'];
    final selectedType = context.watch<PropertySetupCubit>().state.roomType;

    return Row(
      children: types.map((type) {
        final isSelected = selectedType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => context.read<PropertySetupCubit>().updateRoomType(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: type == 'AC' ? 12.w : 0),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF04214E) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: isSelected ? const Color(0xFF04214E) : Colors.grey.shade200, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type == 'AC' ? Icons.ac_unit_rounded : Icons.mode_fan_off_rounded,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.read<PropertySetupCubit>().addRoomBatch();
          FocusScope.of(context).unfocus();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
            SizedBox(width: 12.w),
            Text(
              'ADD TO PROPERTY',
              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return BlocBuilder<PropertySetupCubit, PropertySetupState>(
      builder: (context, state) {
        if (state.rooms.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.bed_rounded, size: 48.sp, color: Colors.grey.shade200),
                SizedBox(height: 16.h),
                Text(
                  'Auto-generated rooms will appear here',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Preview (${state.rooms.length} Rooms)',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
                ),
                TextButton(
                  onPressed: () => context.read<PropertySetupCubit>().clearRooms(),
                  child: Text('Clear All', style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 140.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: state.rooms.length,
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  return Container(
                    width: 160.w,
                    margin: EdgeInsets.only(right: 16.w, bottom: 8.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Room ${room['roomNumber']}',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: (room['roomType'] ?? 'Non-AC') == 'AC' ? Colors.blue.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                room['roomType'] ?? 'Non-AC',
                                style: TextStyle(
                                  fontSize: 12.sp, 
                                  fontWeight: FontWeight.w900, 
                                  color: (room['roomType'] ?? 'Non-AC') == 'AC' ? Colors.blue : Colors.orange.shade800
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${room['sharingType']} Sharing',
                          style: TextStyle(fontSize: 10.sp, color: AppColors.greyText, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 4.w,
                              children: List.generate(room['sharingType'], (i) => Icon(Icons.bed_rounded, size: 14.sp, color: AppColors.primaryBlue)),
                            ),
                            GestureDetector(
                              onTap: () => context.read<PropertySetupCubit>().removeRoom(room['roomNumber']),
                              child: Icon(Icons.cancel_rounded, size: 18.sp, color: Colors.red.shade200),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
