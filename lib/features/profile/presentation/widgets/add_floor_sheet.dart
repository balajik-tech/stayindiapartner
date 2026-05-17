import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/profile/presentation/pages/room_management_page.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';

class AddFloorSheet extends StatefulWidget {
  final String hostelId;
  final RoomCubit roomCubit;
  final DashboardCubit dashboardCubit;

  const AddFloorSheet({
    super.key,
    required this.hostelId,
    required this.roomCubit,
    required this.dashboardCubit,
  });

  static Future<void> show(BuildContext context, {
    required String hostelId,
    required RoomCubit roomCubit,
    required DashboardCubit dashboardCubit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFloorSheet(
        hostelId: hostelId,
        roomCubit: roomCubit,
        dashboardCubit: dashboardCubit,
      ),
    );
  }

  @override
  State<AddFloorSheet> createState() => _AddFloorSheetState();
}

class _AddFloorSheetState extends State<AddFloorSheet> {
  final _floorNameController = TextEditingController();
  int _roomCount = 1;
  bool _isBasement = false;

  @override
  void initState() {
    super.initState();
    final nextStd = getNextStandardFloorNumber();
    _floorNameController.text = nextStd == 1 
        ? '1st Floor' 
        : nextStd == 2 
            ? '2nd Floor' 
            : nextStd == 3 
                ? '3rd Floor' 
                : '${nextStd}th Floor';
  }

  int getNextStandardFloorNumber() {
    int maxFloor = 0;
    final dashboardState = widget.dashboardCubit.state;
    if (dashboardState is DashboardLoaded) {
      for (var floor in dashboardState.data.occupancy.floors) {
        final num = floor.floorNum;
        if (num != null && num > maxFloor) {
          maxFloor = num;
        }
      }
    }
    return maxFloor + 1;
  }

  int getNextBasementNumber() {
    int count = 0;
    final dashboardState = widget.dashboardCubit.state;
    if (dashboardState is DashboardLoaded) {
      for (var floor in dashboardState.data.occupancy.floors) {
        final name = floor.floorName.toLowerCase();
        final num = floor.floorNum;
        if (name.contains('basement') || name == 'b' || (num != null && num < 0)) {
          count++;
        }
      }
    }
    return count + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 40.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFloorTypeSelector(),
                  _buildLabel('floor_identity'.tr()),
                  _buildPremiumTextField(_floorNameController, hint: 'floor_name_hint'.tr()),
                  SizedBox(height: 32.h),
                  
                  Text(
                    'capacity_config'.tr(),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                  ),
                  SizedBox(height: 16.h),
                  
                  _buildCounterRow(
                    label: 'total_rooms'.tr(),
                    value: _roomCount,
                    onDecrement: () {
                      if (_roomCount > 1) {
                        setState(() => _roomCount--);
                        HapticFeedback.lightImpact();
                      }
                    },
                    onIncrement: () {
                      if (_roomCount < 50) {
                        setState(() => _roomCount++);
                        HapticFeedback.mediumImpact();
                      }
                    },
                  ),
                  
                  SizedBox(height: 48.h),
                  _buildAddButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorTypeSelector() {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      height: 48.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isBasement) {
                  setState(() {
                    _isBasement = false;
                    final nextStd = getNextStandardFloorNumber();
                    _floorNameController.text = nextStd == 1 ? '1st Floor' : nextStd == 2 ? '2nd Floor' : nextStd == 3 ? '3rd Floor' : '${nextStd}th Floor';
                  });
                  HapticFeedback.lightImpact();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !_isBasement ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: !_isBasement ? [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Standard Floor',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: !_isBasement ? AppColors.primaryBlue : AppColors.greyText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isBasement) {
                  setState(() {
                    _isBasement = true;
                    final nextB = getNextBasementNumber();
                    _floorNameController.text = nextB == 1 ? 'Basement' : 'Basement $nextB';
                  });
                  HapticFeedback.lightImpact();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _isBasement ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: _isBasement ? [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Basement Floor',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _isBasement ? AppColors.primaryBlue : AppColors.greyText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'add_new_floor'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: AppColors.greyText, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.greyText,
        ),
      ),
    );
  }

  Widget _buildPremiumTextField(TextEditingController controller, {required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCounterRow({required String label, required int value, required VoidCallback onDecrement, required VoidCallback onIncrement}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                _buildSmallIconButton(
                  icon: Icons.remove_rounded,
                  onTap: onDecrement,
                ),
                Container(
                  width: 40.w,
                  alignment: Alignment.center,
                  child: Text(
                    value.toString(),
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                  ),
                ),
                _buildSmallIconButton(
                  icon: Icons.add_rounded,
                  isPrimary: true,
                  onTap: onIncrement,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton({required IconData icon, required VoidCallback onTap, bool isPrimary = false}) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        margin: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: isPrimary ? [
            BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
          ] : [],
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : AppColors.primaryBlue, size: 20.sp),
      ),
    );
  }

  Widget _buildAddButton() {
    return BlocBuilder<RoomCubit, RoomState>(
      bloc: widget.roomCubit,
      builder: (context, state) {
        final isLoading = state is RoomLoading;

        return BouncingWrapper(
          onTap: isLoading
              ? () {}
              : () {
                  final floorName = _floorNameController.text.trim();
                  
                  if (floorName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('please_enter_floor_name'.tr())),
                    );
                    return;
                  }

                  final hostelState = context.read<HostelCubit>().state;
                  Hostel? hostel;
                  if (hostelState is HostelLoaded) {
                    hostel = hostelState.hostels[hostelState.selectedHostelIndex];
                  }

                  if (hostel != null) {
                    Navigator.pop(context);
                    
                    int floorNumCalculated;
                    if (_isBasement) {
                      final numStr = floorName.replaceAll(RegExp(r'[^0-9]'), '');
                      final parsed = int.tryParse(numStr);
                      floorNumCalculated = parsed != null ? -parsed : -getNextBasementNumber();
                    } else {
                      floorNumCalculated = int.tryParse(floorName.replaceAll(RegExp(r'[^0-9]'), '')) ?? getNextStandardFloorNumber();
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: widget.roomCubit),
                            BlocProvider.value(value: widget.dashboardCubit),
                          ],
                          child: RoomManagementPage(
                            hostel: hostel!,
                            floorName: floorName,
                            floorNum: floorNumCalculated,
                            isDraftMode: true,
                            draftRoomCount: _roomCount,
                          ),
                        ),
                      ),
                    );
                  }
                },
          child: Container(
            width: double.infinity,
            height: 54.h,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    'create_new_floor'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
