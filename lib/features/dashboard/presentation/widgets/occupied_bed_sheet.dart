import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_state.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/tenant_details_sheet.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_state.dart';
import 'package:stayindia_owner/features/bookings/pages/room_selection_page.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/checkout_settlement_modal.dart';
import 'package:stayindia_owner/injection_container.dart';

class OccupiedBedSheet extends StatelessWidget {
  final String roomNumber;
  final String bedNumber;
  final String tenantName;
  final String? tenantAvatar;
  final String tenantId;
  final String hostelId;

  const OccupiedBedSheet({
    super.key,
    required this.roomNumber,
    required this.bedNumber,
    required this.tenantName,
    this.tenantAvatar,
    required this.tenantId,
    required this.hostelId,
  });

  static void show(
    BuildContext context, {
    required String roomNumber,
    required String bedNumber,
    required String tenantName,
    String? tenantAvatar,
    required String tenantId,
    required String hostelId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => sl<TenantDetailCubit>()..loadDetail(tenantId, hostelId),
          ),
          BlocProvider(
            create: (context) => sl<BookingsCubit>(),
          ),
        ],
        child: OccupiedBedSheet(
          roomNumber: roomNumber,
          bedNumber: bedNumber,
          tenantName: tenantName,
          tenantAvatar: tenantAvatar,
          tenantId: tenantId,
          hostelId: hostelId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: BlocBuilder<TenantDetailCubit, TenantDetailState>(
        builder: (context, state) {
          final detail = state is TenantDetailLoaded ? state.detail : null;
          final String rent = detail?.stay?.rent != null ? detail!.stay!.rent.toStringAsFixed(0) : '';
          final String stayStatus = detail?.stay?.status ?? 'OCCUPIED';
          final bool isCheckedIn = stayStatus == 'CHECKED_IN';
          final bool isReserved = stayStatus == 'BOOKED' || stayStatus == 'CONFIRMED' || stayStatus == 'PENDING_PAYMENT' || stayStatus == 'LOCKED';
          
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isCheckedIn ? AppColors.primaryBlue : (isReserved ? Colors.orange : Colors.grey),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            stayStatus.replaceAll('_', ' '),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Bed $bedNumber',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 28.sp, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
              const Divider(),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.roomCardBorder),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: QrImageView(
                  data: detail?.stay?.qrToken ?? detail?.stay?.accessCode ?? detail?.stay?.bookingId ?? tenantId,
                  version: QrVersions.auto,
                  size: 160.w,
                  gapless: false,
                ),
              ),
              SizedBox(height: 16.h),
              if (detail != null && detail.stay != null) ...[
                Text(
                  'Manual Check-in ID: ${detail.stay!.accessCode ?? detail.stay!.bookingId.toUpperCase().substring(detail.stay!.bookingId.length > 8 ? detail.stay!.bookingId.length - 8 : 0)}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4.h),
              ],
              Text(
                'Access Pass',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyText,
                ),
              ),
              Text(
                'Valid for current stay',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greyText.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.access_time,
                        label: 'Checkout Time',
                        value: '11:00 AM',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDetailCard(
                        icon: Icons.currency_rupee,
                        label: 'Monthly Fee',
                        value: rent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.roomCardBorder),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      CustomAvatar(
                        imageUrl: tenantAvatar,
                        name: tenantName,
                        size: 48.0,
                        isCircle: true,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenantName,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  TenantDetailsSheet.show(
                                    context,
                                    name: tenantName,
                                    imageUrl: tenantAvatar,
                                    room: roomNumber,
                                    tenantId: tenantId,
                                    hostelId: hostelId,
                                  );
                                },
                                borderRadius: BorderRadius.circular(4.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                                  child: Text(
                                    'View full profile ',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: detail == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<BookingsCubit>(),
                                  child: RoomSelectionPage(
                                    bookingId: detail.stay!.bookingId,
                                    hostelId: hostelId,
                                    tenantName: tenantName,
                                    accessCode: detail.stay!.accessCode,
                                    isRoomChange: true,
                                  ),
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.swap_horiz, size: 20.sp),
                    label: Text(
                      'CHANGE ROOM',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BlocConsumer<BookingsCubit, BookingsState>(
                  listener: (context, BookingsState bookingsState) {
                    if (bookingsState.status == BookingsStatus.success && bookingsState.successMessage != null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(bookingsState.successMessage!)),
                      );
                    }
                  },
                  builder: (context, BookingsState bookingsState) {
                    final isLoading = bookingsState.status == BookingsStatus.loading;
                    
                    if (!isCheckedIn) {
                      
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading || detail == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<BookingsCubit>(),
                                        child: RoomSelectionPage(
                                          bookingId: detail.stay!.bookingId,
                                          hostelId: hostelId,
                                          tenantName: tenantName,
                                          accessCode: detail.stay!.accessCode,
                                          preAllocatedRoomId: detail.stay!.roomId,
                                          preAllocatedBedNumber: detail.stay!.bedNumber,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(Icons.login, size: 20.sp),
                          label: Text(
                            'COMPLETE CHECK-IN',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading || detail == null
                            ? null
                            : () {
                                CheckoutSettlementModal.show(
                                  context,
                                  tenantName: tenantName,
                                  tenantId: tenantId,
                                  hostelId: hostelId,
                                  bookingId: detail.stay!.bookingId,
                                  securityDeposit: detail.stay!.deposit,
                                  onCheckoutConfirmed: () {
                                    context.read<BookingsCubit>().checkoutBooking(detail.stay!.bookingId);
                                  },
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9FAFB),
                          foregroundColor: AppColors.darkText,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(color: AppColors.roomCardBorder),
                          ),
                        ),
                        icon: isLoading 
                          ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.logout, size: 20.sp),
                        label: Text(
                          'CHECK-OUT',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
      ),
    );
  }


  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.roomCardBorder),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppColors.greyText),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
