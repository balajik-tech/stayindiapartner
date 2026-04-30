import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';

class SetupSuccessScreen extends StatelessWidget {
  const SetupSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 100.sp),
            ),
            SizedBox(height: 40.h),
            Text(
              'Setup Complete!',
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
            ),
            SizedBox(height: 16.h),
            Text(
              'Your property and rooms have been created successfully. You can now start managing tenants.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: AppColors.greyText, height: 1.5),
            ),
            SizedBox(height: 48.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  
                  context.read<HostelCubit>().getHostels(forceRefresh: true);
                  
                  
                  context.read<PropertySetupCubit>().resetState();
                  
                  
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text(
                  'Go to Dashboard',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
