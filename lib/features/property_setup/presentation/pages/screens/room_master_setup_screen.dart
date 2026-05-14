import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';

class RoomMasterSetupScreen extends StatelessWidget {
  const RoomMasterSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertySetupCubit, PropertySetupState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSectionHeader(
                      'Room Master Setup',
                      'Configure your rooms and their standard prices',
                    ),
                  ),
                  SizedBox(width: 8.w),
                  BouncingWrapper(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showAddMasterDialog(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF98125).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFF98125).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline_rounded, color: const Color(0xFFF98125), size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Add New',
                            style: TextStyle(
                              color: const Color(0xFFF98125),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.roomMasters.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.roomMasters.length,
                      separatorBuilder: (context, index) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final master = state.roomMasters[index];
                        return _buildMasterCard(context, index, master);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2C5990),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.room_preferences_rounded, size: 48.sp, color: const Color(0xFF94A3B8)),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Room Masters Added',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'Add standard rooms (like Double Sharing AC) to automatically pre-populate rooms and prices in later steps.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
          SizedBox(height: 24.h),
          BouncingWrapper(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showAddMasterDialog(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2C5990),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2C5990).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                'Add Room Master Template',
                style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterCard(BuildContext context, int index, Map<String, dynamic> master) {
    final int sharing = master['sharingType'] ?? 2;
    final String type = master['roomType'] ?? 'NON-AC';
    final double rent = (master['rent'] ?? 0.0).toDouble();
    final double dailyRent = (master['dailyRent'] ?? 0.0).toDouble();
    final double deposit = (master['deposit'] ?? 0.0).toDouble();
    final double maintenance = (master['maintenance'] ?? 0.0).toDouble();

    final isAC = type.toUpperCase() == 'AC';

    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: isAC
                          ? const Color(0xFFE0F2FE)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      isAC ? Icons.ac_unit_rounded : Icons.mode_fan_off_rounded,
                      size: 20.sp,
                      color: isAC ? const Color(0xFF0EA5E9) : const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sharing == 1
                            ? 'Single Sharing'
                            : (sharing == 2
                                ? 'Double Sharing'
                                : (sharing == 3
                                    ? 'Triple Sharing'
                                    : (sharing == 4
                                        ? 'Quad Sharing'
                                        : '5 Sharing'))),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isAC ? 'Air Conditioned (AC)' : 'Non-Air Conditioned',
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.read<PropertySetupCubit>().removeRoomMaster(index);
                },
                icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(color: const Color(0xFFF1F5F9), height: 1.h),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildPriceChip(
                  'Monthly Rent',
                  '₹${rent.toInt()}',
                  const Color(0xFFF98125),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildPriceChip(
                  'Daily Rent',
                  '₹${dailyRent.toInt()}',
                  const Color(0xFF2C5990),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildPriceChip(
                  'Security Deposit',
                  '₹${deposit.toInt()}',
                  const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildPriceChip(
                  'Maintenance',
                  '₹${maintenance.toInt()}',
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildPriceChip(
            'Room Size',
            '${master['roomSize'] ?? 0} sqft',
            const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChip(String label, String value, Color themeColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: themeColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B)),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: themeColor),
          ),
        ],
      ),
    );
  }

  void _showAddMasterDialog(BuildContext context) {
    final cubit = context.read<PropertySetupCubit>();
    int selectedSharing = 2;
    String selectedRoomType = 'NON-AC';

    final rentController = TextEditingController();
    final dailyRentController = TextEditingController();
    final depositController = TextEditingController();
    final maintenanceController = TextEditingController();
    final roomSizeController = TextEditingController();

    rentController.addListener(() {
      final monthly = double.tryParse(rentController.text) ?? 0;
      if (monthly > 0) {
        final daily = (monthly / 30).round();
        dailyRentController.text = daily.toString();
      } else {
        dailyRentController.text = '';
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Room Master',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C5990),
                        fontSize: 20.sp,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: Icon(Icons.close_rounded, color: const Color(0xFF64748B), size: 24.sp),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text('Sharing Type', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B))),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedSharing,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF2C5990), size: 24.sp),
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Single Sharing')),
                        DropdownMenuItem(value: 2, child: Text('Double Sharing')),
                        DropdownMenuItem(value: 3, child: Text('Triple Sharing')),
                        DropdownMenuItem(value: 4, child: Text('Quad Sharing')),
                        DropdownMenuItem(value: 5, child: Text('5 Sharing')),
                      ],
                      onChanged: (val) => setSheetState(() => selectedSharing = val!),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text('Room Type', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF64748B))),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => selectedRoomType = 'NON-AC'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            color: selectedRoomType == 'NON-AC'
                                ? const Color(0xFF2C5990).withValues(alpha: 0.1)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: selectedRoomType == 'NON-AC'
                                  ? const Color(0xFF2C5990)
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'NON-AC',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedRoomType == 'NON-AC'
                                  ? const Color(0xFF2C5990)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w900,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => selectedRoomType = 'AC'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            color: selectedRoomType == 'AC'
                                ? const Color(0xFFF98125).withValues(alpha: 0.1)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: selectedRoomType == 'AC'
                                  ? const Color(0xFFF98125)
                                  : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'AC',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedRoomType == 'AC'
                                  ? const Color(0xFFF98125)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w900,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _DialogTextField(
                        controller: rentController,
                        label: 'Monthly Rent / Bed',
                        hint: 'e.g. 8000',
                        icon: Icons.currency_rupee_rounded,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _DialogTextField(
                        controller: dailyRentController,
                        label: 'Daily Rent',
                        hint: 'e.g. 500',
                        icon: Icons.today_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _DialogTextField(
                        controller: depositController,
                        label: 'Security Deposit',
                        hint: 'e.g. 5000',
                        icon: Icons.security_rounded,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _DialogTextField(
                        controller: maintenanceController,
                        label: 'Maintenance',
                        hint: 'e.g. 1000',
                        icon: Icons.handyman_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _DialogTextField(
                  controller: roomSizeController,
                  label: 'Room Size (sqft)',
                  hint: 'e.g. 120',
                  icon: Icons.square_foot_rounded,
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          side: const BorderSide(color: Color(0xFF64748B), width: 1.5),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final rent = double.tryParse(rentController.text) ?? 0.0;
                          final dailyRent = double.tryParse(dailyRentController.text) ?? 0.0;
                          final deposit = double.tryParse(depositController.text) ?? 0.0;
                          final maintenance = double.tryParse(maintenanceController.text) ?? 0.0;

                          if (rent <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Monthly rent must be greater than 0'), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }

                          cubit.addRoomMaster({
                            'sharingType': selectedSharing,
                            'roomType': selectedRoomType,
                            'rent': rent,
                            'dailyRent': dailyRent,
                            'deposit': deposit,
                            'maintenance': maintenance,
                            'roomSize': double.tryParse(roomSizeController.text) ?? 0.0,
                          });

                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Room Master Template Added!'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5990),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Add Template',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF94A3B8), size: 20.sp),
          labelText: label,
          labelStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w700),
          hintText: hint,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  const _PremiumCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF2C5990).withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}
