import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  int _bedsPerRoom = 2;

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
              _buildLabel('Floor Identity'),
              _buildPremiumTextField(_floorNameController, hint: 'e.g. 3rd Floor'),
              SizedBox(height: 32.h),
              
              Text(
                'Capacity Configuration',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
              ),
              SizedBox(height: 16.h),
              
              _buildCounterRow(
                label: 'Total Rooms',
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
              SizedBox(height: 20.h),
              _buildCounterRow(
                label: 'Beds per Room',
                value: _bedsPerRoom,
                onDecrement: () {
                  if (_bedsPerRoom > 1) {
                    setState(() => _bedsPerRoom--);
                    HapticFeedback.lightImpact();
                  }
                },
                onIncrement: () {
                  if (_bedsPerRoom < 10) {
                    setState(() => _bedsPerRoom++);
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add New Floor',
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
    return BlocConsumer<RoomCubit, RoomState>(
      bloc: widget.roomCubit,
      listener: (context, state) {
        if (state is RoomOperationSuccess) {
          Navigator.pop(context);
          widget.dashboardCubit.fetchDashboardData(widget.hostelId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is RoomError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is RoomLoading;

        return BouncingWrapper(
          onTap: isLoading
              ? () {}
              : () {
                  final floorName = _floorNameController.text.trim();
                  
                  if (floorName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a floor name')),
                    );
                    return;
                  }

                  final ownerId = context.read<AuthCubit>().currentOwner?.id ?? '';

                  widget.roomCubit.addFloor(
                    hostelId: widget.hostelId,
                    ownerId: ownerId,
                    floorName: floorName,
                    roomCount: _roomCount,
                    bedsPerRoom: _bedsPerRoom,
                  );
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
                    'Create New Floor',
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
