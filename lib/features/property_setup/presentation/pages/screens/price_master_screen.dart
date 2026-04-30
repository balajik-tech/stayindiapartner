import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';

class PriceMasterScreen extends StatelessWidget {
  const PriceMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertySetupCubit, PropertySetupState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price Master',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
              ),
              SizedBox(height: 8.h),
              Text(
                'Set the rent for your rooms. This will sync across all rooms.',
                style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
              ),
              SizedBox(height: 32.h),
    
              _buildPricingSection(context, state, 'AC', Icons.ac_unit_rounded),
              SizedBox(height: 32.h),
              _buildPricingSection(context, state, 'Non-AC', Icons.mode_fan_off_rounded),
              
              SizedBox(height: 40.h),
              _buildSyncInfo(context, state),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPricingSection(BuildContext context, PropertySetupState state, String type, IconData icon) {
    final roomsOfType = state.rooms.where((r) => (r['roomType'] ?? 'Non-AC') == type).toList();
    
    if (roomsOfType.isEmpty) return const SizedBox.shrink();

    final uniqueSharingTypes = roomsOfType.map((r) => r['sharingType'] as int).toSet().toList();
    uniqueSharingTypes.sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              '$type ROOMS',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText, letterSpacing: 1),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...uniqueSharingTypes.map((sharing) => _buildPricingCard(context, state, type, sharing)),
      ],
    );
  }

  Widget _buildPricingCard(BuildContext context, PropertySetupState state, String type, int sharing) {
    final sharingStr = sharing.toString();
    final pricing = state.masterPricing[type] ?? {};
    final config = pricing[sharingStr];
    
    double rent = 0.0;
    double deposit = 0.0;
    double maintenance = 0.0;

    if (config is Map) {
      rent = (config['rent'] ?? 0.0).toDouble();
      deposit = (config['deposit'] ?? 0.0).toDouble();
      maintenance = (config['maintenance'] ?? 0.0).toDouble();
    } else if (config is num) {
      rent = config.toDouble();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$sharing Sharing',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Rent/Bed',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildPriceInput(
            label: 'Monthly Rent',
            value: rent > 0 ? rent.toString() : '',
            onChanged: (val) {
              final price = double.tryParse(val) ?? 0.0;
              context.read<PropertySetupCubit>().updatePricing(type, sharingStr, 'rent', price);
            },
          ),
          SizedBox(height: 12.h),
          _buildPriceInput(
            label: 'Security Deposit',
            value: deposit > 0 ? deposit.toString() : '',
            hint: 'e.g. 5000',
            onChanged: (val) {
              final price = double.tryParse(val) ?? 0.0;
              context.read<PropertySetupCubit>().updatePricing(type, sharingStr, 'deposit', price);
            },
          ),
          SizedBox(height: 12.h),
          _buildPriceInput(
            label: 'Maintenance',
            value: maintenance > 0 ? maintenance.toString() : '',
            hint: 'e.g. 500',
            onChanged: (val) {
              final price = double.tryParse(val) ?? 0.0;
              context.read<PropertySetupCubit>().updatePricing(type, sharingStr, 'maintenance', price);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput({required String label, required String value, required Function(String) onChanged, String hint = 'e.g. 5000'}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Text('₹', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextFormField(
                    initialValue: value,
                    onChanged: onChanged,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncInfo(BuildContext context, PropertySetupState state) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_rounded, color: Colors.orange, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Changes made here will automatically apply to all ${state.rooms.length} matching rooms.',
              style: TextStyle(fontSize: 13.sp, color: Colors.orange.shade800, fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
