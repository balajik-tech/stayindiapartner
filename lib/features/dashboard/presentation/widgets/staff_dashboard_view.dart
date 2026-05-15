import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/auth/domain/entities/owner_entity.dart';

class StaffDashboardView extends StatelessWidget {
  final OwnerEntity owner;
  final String role;

  const StaffDashboardView({
    super.key,
    required this.owner,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        title: Text(
          '${role.toUpperCase()} DASHBOARD',
          style: const TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shield_rounded, size: 64.sp, color: AppColors.primaryBlue),
              ),
              SizedBox(height: 24.h),
              Text(
                'Welcome, ${owner.name}',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 8.h),
              Text(
                'Logged in as ${role.toUpperCase()}',
                style: TextStyle(color: AppColors.greyText, fontSize: 16.sp),
              ),
              SizedBox(height: 32.h),
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (role == 'cook') {
      return ElevatedButton.icon(
        onPressed: () => _showComingSoon(context, 'Kitchen Stock Management'),
        icon: const Icon(Icons.kitchen_rounded, color: Colors.white),
        label: const Text('Kitchen Stock Management'),
        style: _buttonStyle(),
      );
    } else if (role == 'cleaning_staff') {
      return ElevatedButton.icon(
        onPressed: () => _showComingSoon(context, 'Assigned Room Cleaning List'),
        icon: const Icon(Icons.cleaning_services_rounded, color: Colors.white),
        label: const Text('Assigned Room Cleaning List'),
        style: _buttonStyle(),
      );
    } else if (role == 'security') {
      return ElevatedButton.icon(
        onPressed: () => _showComingSoon(context, 'Visitor Logs & Verification'),
        icon: const Icon(Icons.security_rounded, color: Colors.white),
        label: const Text('Visitor Logs & Verification'),
        style: _buttonStyle(),
      );
    }
    return const SizedBox.shrink();
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $feature...')),
    );
  }
}
