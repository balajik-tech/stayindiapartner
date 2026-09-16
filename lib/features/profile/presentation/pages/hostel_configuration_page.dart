import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/bed_card.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/pages/property_setup_stepper_page.dart';
import '../../../communities/presentation/widgets/dotted_circle_painter.dart';
import '../widgets/dash_dotter_line.dart';
import '../widgets/dashed_divider.dart';
import 'hostel_profile_page.dart';
import 'amenities_page.dart';
import 'house_rules_page.dart';
import 'food_menu_page.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

class HostelConfigurationPage extends StatelessWidget {
  const HostelConfigurationPage({super.key});

  void _handleAddProperty(BuildContext context) {
    final profileState = context.read<ProfileCubit>().state;
    bool isVerified = false;

    if (profileState is ProfileLoaded) {
      isVerified = profileState.profile.dlKyc?.isAadharVerified ?? false;
    } else if (profileState is ProfileUpdateSuccess) {
      isVerified = profileState.profile.dlKyc?.isAadharVerified ?? false;
    }

    if (isVerified) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PropertySetupStepperPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete your KYC verification'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f8fc),
      appBar: _buildAppBar(context),
      body: BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          if (state is HostelLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HostelLoaded) {
            final hostels = state.hostels;
            if (hostels.isEmpty) {
              return _buildEmptyState(context);
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: hostels.length,
                    itemBuilder: (context, index) {
                      return _HostelConfigCard(
                        hostel: hostels[index],
                        index: index,
                      );
                    },
                  ),
                ),
                _buildAddPropertyButton(context),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final state = context.watch<HostelCubit>().state;
    int totalBeds = 0;
    int hostelCount = 0;
    if (state is HostelLoaded) {
      hostelCount = state.hostels.length;
      for (var h in state.hostels) {
        totalBeds += h.totalBeds ?? 0;
      }
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'hostel_configuration'.tr(),
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          if (hostelCount > 0)
            Text(
              '${'properties_count'.tr(namedArgs: {'count': hostelCount.toString()})} • ${'beds_count'.tr(namedArgs: {'count': totalBeds.toString()})}',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: AppColors.primaryBlue, size: 28.sp),
          onPressed: () => _handleAddProperty(context),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildAddPropertyButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F8FC),
      ),
      child: BouncingWrapper(
        onTap: () => _handleAddProperty(context),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: const Color(0xFFa5bddb),
            strokeWidth: 2,
            dashWidth: 6,
            dashSpace: 4,
          ),
          child: Container(
            height: 52.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FC),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 20.sp,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8.w),
                Text(
                  'add_property'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.business_rounded, size: 64.sp, color: AppColors.primaryBlue.withValues(alpha: 0.3)),
            ),
            SizedBox(height: 24.h),
            Text(
              'no_properties_found'.tr(),
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
            ),
            SizedBox(height: 12.h),
            Text(
              'no_properties_desc'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B), height: 1.5),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => _handleAddProperty(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('add_property'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HostelConfigCard extends StatelessWidget {
  final Hostel hostel;
  final int index;

  const _HostelConfigCard({required this.hostel, required this.index});

  void _handleAddProperty(BuildContext context) {
    final profileState = context.read<ProfileCubit>().state;
    bool isVerified = false;

    if (profileState is ProfileLoaded) {
      isVerified = profileState.profile.dlKyc?.isAadharVerified ?? false;
    } else if (profileState is ProfileUpdateSuccess) {
      isVerified = profileState.profile.dlKyc?.isAadharVerified ?? false;
    }

    if (isVerified) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PropertySetupStepperPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ekyc_pending'.tr()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = "all_set".tr();
    Color statusBg = const Color(0xFFE6F4EA);
    Color statusText = const Color(0xFF1E8E3E);

    // if (index == 1) {
    //   status = 'pending_count'.tr(namedArgs: {'count': '1'});
    //   statusBg = const Color(0xFFFEF7E0);
    //   statusText = const Color(0xFFB45309);
    // } else if (index == 2) {
    //   status = 'pending_count'.tr(namedArgs: {'count': '2'});
    //   statusBg = const Color(0xFFFEF2F2);
    //   statusText = const Color(0xFFB91C1C);
    // }

    status = '';

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              context.read<HostelCubit>().selectHostel(index);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HostelProfilePage()),
              );
            },
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: index % 3 == 0
                          ? const Color(0xFFe8f1fa)
                          : (index % 3 == 1
                              ? const Color(0xFFe5f5f0)
                              : const Color(0xFFf8efdc)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.apartment_outlined,
                      color: index % 3 == 0
                          ? const Color(0xFF2f5ea0)
                          : (index % 3 == 1
                              ? const Color(0xFF336d57)
                              : const Color(0xFF7e521d)),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hostel.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${hostel.area ?? hostel.city ?? ""} • ${'beds_count'.tr(namedArgs: {'count': (hostel.totalBeds ?? 0).toString()})}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF8891a1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // if (index == 2)
                        //    Text(
                        //     'Draft',
                        //     style: TextStyle(
                        //       fontSize: 11.sp,
                        //       color: const Color(0xFF94A3B8),
                        //       fontWeight: FontWeight.w600,
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                  if(status.isNotEmpty)
                    Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: statusText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildDashedDivider(),
          _ConfigSubItem(
            icon: Icons.wifi_rounded,
            title: 'amenities'.tr(),
            // status: index == 2 ? null : (index == 1 ? 'listed_count'.tr(namedArgs: {'count': '7'}) : 'listed_count'.tr(namedArgs: {'count': '9'})),
            // actionLabel: index == 2 ? 'add'.tr() : null,
            status: null,
            actionLabel:  null,
            onTap: () {
              context.read<HostelCubit>().selectHostel(index);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AmenitiesPage()),
              );
            },
          ),
          _buildDashedDivider(),
          _ConfigSubItem(
            icon: Icons.list_alt_rounded,
            title: 'house_rules'.tr(),
            // status: index == 0 ? 'rules_count'.tr(namedArgs: {'count': '6'}) : (index == 1 ? 'rules_count'.tr(namedArgs: {'count': '5'}) : null),
            // actionLabel: index == 2 ? 'add'.tr() : null,
            status: null,
            actionLabel:  null,
            onTap: () {
              context.read<HostelCubit>().selectHostel(index);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HouseRulesPage()),
              );
            },
          ),
          _buildDashedDivider(),
          _ConfigSubItem(
            icon: Icons.restaurant_rounded,
            title: 'food_menu'.tr(),
            // status: index == 0 ? 'this_week'.tr() : (index == 2 ? 'this_week'.tr() : null),
            // actionLabel: index == 1 ? 'add_menu'.tr() : null,
            status: null,
            actionLabel:  null,
            isLast: true,
            onTap: () {
              context.read<HostelCubit>().selectHostel(index);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodMenuPage()),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildDashedDivider() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: 1,
        width: double.infinity,
        child: CustomPaint(
          painter: DashedDividerPainter(
            color: Color(0xFFdfe5ee),
            dashWidth: 5,
            dashSpace: 4,
          ),
        ),
      ),
    );
  }
}

class _ConfigSubItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? status;
  final String? actionLabel;
  final bool isLast;
  final VoidCallback onTap;

  const _ConfigSubItem({
    required this.icon,
    required this.title,
    this.status,
    this.actionLabel,
    this.isLast = false,
    required this.onTap,
  });

  void _handleAddProperty(BuildContext context) {
    final profileState = context.read<ProfileCubit>().state;
    bool isVerified = false;

    if (profileState is ProfileLoaded) {
      isVerified = profileState.profile.dlKyc?.isAadharVerified ?? false;
    } else if (profileState is ProfileUpdateSuccess) {
      isVerified = profileState.profile.dlKyc?.isAadharVerified ?? false;
    }

    if (isVerified) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PropertySetupStepperPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ekyc_pending'.tr()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: actionLabel != null ? const Color(0xFFfffbf4) : null,
          borderRadius: isLast
              ? BorderRadius.vertical(bottom: Radius.circular(24.r))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5e6b83), size: 20.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1a294b),
                ),
              ),
            ),
            if (status != null)
              Text(
                status!,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3b7843),
                ),
              ),
            if (actionLabel != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7e521d),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            SizedBox(width: 8.w),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF2d539f)),
          ],
        ),
      ),
    );
  }
}
