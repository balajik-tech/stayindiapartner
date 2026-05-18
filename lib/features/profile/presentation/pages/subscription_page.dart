import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostelCubit, HostelState>(
      builder: (context, state) {
        int totalBeds = 0;
        List<Hostel> hostels = [];
        if (state is HostelLoaded) {
          hostels = state.hostels;
          totalBeds = hostels.fold(0, (sum, h) => sum + (h.totalBeds ?? 0));
        }

        final authState = context.watch<AuthCubit>().state;
        int bedLimit = 10;
        String currentPlan = 'free';
        
        if (authState is AuthAuthenticated) {
          bedLimit = authState.owner.bedLimit;
          currentPlan = authState.owner.plan;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.darkText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Subscription',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.h),
              child: Divider(height: 1, color: AppColors.roomCardBorder),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, MediaQuery.of(context).padding.bottom + 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 _buildCurrentPlanCard(totalBeds, bedLimit, currentPlan),
                SizedBox(height: 32.h),
                Text(
                  'Billing Breakdown',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 16.h),
                ...hostels.map((hostel) => _buildHostelBillingRow(hostel)),
                if (hostels.isEmpty)
                   Text('No properties added yet.', style: TextStyle(color: AppColors.greyText, fontSize: 14.sp)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPlanCard(int usage, int limit, String plan) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.05),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'FREE TIER',
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_outline_rounded,
                color: const Color(0xFF10B981),
                size: 24.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Completely Free Plan',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 8.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '₹0',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
                TextSpan(
                  text: ' /month',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bed Capacity',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.greyText, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '$usage beds (Unlimited)',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.darkText, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 8.h,
                  backgroundColor: AppColors.greyText.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  'Active & fully unrestricted. Enjoy Stay India for free!',
                  style: TextStyle(color: const Color(0xFF10B981), fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),
          _buildFeatureRow('100% Free Forever'),
          _buildFeatureRow('Unlimited properties & beds'),
          _buildFeatureRow('Full SaaS Platform Access'),
          _buildFeatureRow('Priority 24/7 support'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 18.sp),
          SizedBox(width: 12.w),
          Text(
            feature,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostelBillingRow(Hostel hostel) {
    int beds = hostel.totalBeds ?? 0;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.business, color: const Color(0xFF10B981), size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hostel.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  '$beds beds @ Free',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                ),
              ],
            ),
          ),
          Text(
            '₹0',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
