import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:stayindia_owner/features/notifications/presentation/pages/notifications_page.dart';
import 'package:url_launcher/url_launcher.dart';

class UnifiedHeader extends StatelessWidget {
  const UnifiedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostelCubit, HostelState>(
      builder: (context, state) {
        String selectedHostelName = StringUtils.translate(
          "select_property",
          context: context,
        );
        if (state is HostelLoaded && state.hostels.isNotEmpty) {
          if (state.selectedHostelIndices.length > 1) {
            selectedHostelName =
            "${state.selectedHostelIndices.length} ${StringUtils.translate("properties", context: context)}";
          } else {
            final index = state.selectedHostelIndices.isNotEmpty
                ? state.selectedHostelIndices.first
                : state.selectedHostelIndex;

            if (index < state.hostels.length) {
              selectedHostelName = state.hostels[index].name;
            }
          }
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          color: Colors.white,
          child: Row(
            children: [
              SizedBox(
                width: 48.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                        'assets/images/login_logo_nobg.png',
                        fit: BoxFit.contain,
                        height: 44.h,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 40.sp,
                          color: Colors.grey,
                        ),
                      ),
                    // Commented partner text in logo
                    // Container(
                    //   width: double.infinity,
                    //   padding: EdgeInsets.symmetric(vertical: 2.h,horizontal: 1.h),
                    //   decoration: BoxDecoration(
                    //     color: AppColors.primaryBlue, // Blue background
                    //     borderRadius: BorderRadius.only(
                    //       bottomLeft: Radius.circular(4.r),
                    //       bottomRight: Radius.circular(4.r),
                    //     ),
                    //   ),
                    //   child: Center(
                    //     child: Text(
                    //       'PARTNER',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 12.sp,
                    //         fontWeight: FontWeight.w700,
                    //         letterSpacing: 0.5,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),

              Expanded(
                child: Semantics(
                  label: StringUtils.translate(
                    'switch_property',
                    context: context,
                  ),
                  hint:
                  '${StringUtils.translate('current_property', context: context)}: $selectedHostelName',
                  button: true,
                  child: GestureDetector(
                    onTap: () => _showSwitchHostelSheet(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf4f5f9),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE8ECF5), // Border color
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Container(
                          //   width: 32.w,
                          //   height: 32.w,
                          //   decoration: BoxDecoration(
                          //     color:  AppColors.orangeColor,
                          //     borderRadius: BorderRadius.circular(10.r),
                          //   ),
                          //   child: Center(
                          //     child: Image.asset(
                          //       'assets/images/hostel.png',
                          //       width: 20,
                          //       height: 20,
                          //       fit: BoxFit.contain,
                          //       colorBlendMode: BlendMode.srcIn,
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              selectedHostelName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0a3462),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFF6B7C93),
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // commented report
              // Container(
              //   width: 44.w,
              //   height: 44.w,
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFf4f5f9),
              //     borderRadius: BorderRadius.circular(12.r),
              //     border: Border.all(
              //       color: const Color(0xFFE8ECF5), // Border color
              //       width: 1.0,
              //     ),
              //   ),
              //   child:  Center(
              //     child: Image.asset(
              //       'assets/images/report.png',
              //       width: 20,
              //       height: 20,
              //       fit: BoxFit.contain,
              //       // color: Color(0xFF0a3462),
              //       colorBlendMode: BlendMode.srcIn,
              //     ),
              //   ),
              // ),

              GestureDetector(
                onTap: ()=>{
                  _launchUrl('https://wa.me/919888936836'),
                },
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf4f5f9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFE8ECF5), // Border color
                      width: 1.0,
                    ),
                  ),
                  child:Center(
                    child: Image.asset(
                      'assets/images/whatsapp.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      // color: Color(0xFF0a3462),
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Semantics(
                label: StringUtils.translate('notifications', context: context),
                button: true,
                child: Tooltip(
                  message: StringUtils.translate(
                    'notifications',
                    context: context,
                  ),
                  child: BouncingWrapper(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                    child: BlocBuilder<NotificationCubit, NotificationState>(
                      builder: (context, notificationState) {
                        final int unreadCount = notificationState is NotificationLoaded
                            ? notificationState.unreadCount
                            : 0;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFf4f5f9),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFE8ECF5), // Border color
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/bell.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  // color: Color(0xFF0a3462),
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: 8.h,
                                right: 8.w,
                                child: Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.orangeColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.orangeColor,
                                        width: 1.5),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSwitchHostelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          if (state is! HostelLoaded) return const SizedBox.shrink();

          return Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  StringUtils.translate('switch_property', context: context),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 0.6.sh),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: state.hostels.length,
                    itemBuilder: (context, index) {
                      final hostel = state.hostels[index];
                      final isSelected = state.selectedHostelIndices.contains(
                        index,
                      );
                      return BouncingWrapper(
                        onTap: () {
                          context.read<HostelCubit>().selectHostel(
                            index,
                          );
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue.withValues(alpha: 0.05)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue.withValues(
                                    alpha: 0.1,
                                  )
                                      : AppColors.backgroundSecondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.apartment_rounded,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.textSecondary,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  hostel.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primaryBlue,
                                  size: 24.sp,
                                ),
                              SizedBox(width: 4.w),
                              // Commented Delete Hostel Property in switch dialog
                              // Container(
                              //   child: GestureDetector(
                              //     onTap: () async {
                              //       final confirm = await showDialog<bool>(
                              //         context: context,
                              //         builder: (_) => AlertDialog(
                              //           title: const Text('Delete Hostel'),
                              //             content: RichText(
                              //               text: TextSpan(
                              //                 style: DefaultTextStyle.of(context).style,
                              //                 children: [
                              //                   const TextSpan(
                              //                     text: 'Are you sure you want to delete ',
                              //                   ),
                              //                   TextSpan(
                              //                     text: hostel.name,
                              //                     style: const TextStyle(
                              //                       fontWeight: FontWeight.bold,
                              //                       color: Colors.black
                              //                     ),
                              //                   ),
                              //                   const TextSpan(
                              //                     text: '?',
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           actions: [
                              //             TextButton(
                              //               onPressed: () => Navigator.pop(context, false),
                              //               child: const Text('Cancel'),
                              //             ),
                              //             ElevatedButton(
                              //               style: ElevatedButton.styleFrom(
                              //                 backgroundColor: Colors.red,
                              //               ),
                              //               onPressed: () => Navigator.pop(context, true),
                              //               child: const Text(
                              //                 'Delete',
                              //                 style: TextStyle(color: Colors.white),
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       );
                              //
                              //       if (confirm == true && context.mounted) {
                              //         context.read<HostelCubit>().deleteHostel(hostel.id);
                              //       }
                              //     },
                              //     child: Container(
                              //       padding: EdgeInsets.all(6.r),
                              //       decoration: BoxDecoration(
                              //         color: Colors.red.withValues(alpha: 0.08),
                              //         shape: BoxShape.circle,
                              //       ),
                              //       child: Icon(
                              //         Icons.delete_outline_rounded,
                              //         color: Colors.red.shade700,
                              //         size: 16.sp,
                              //       ),
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
