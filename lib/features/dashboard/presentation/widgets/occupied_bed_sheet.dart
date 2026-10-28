import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/widgets/side_view_bed_icon.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_state.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/tenant_details_sheet.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_state.dart';
import 'package:stayindia_owner/features/bookings/pages/room_selection_page.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/checkout_settlement_modal.dart';
import 'package:stayindia_owner/features/movement_history/presentation/widgets/tenant_movement_history_section.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/bookings/domain/settlement_payment.dart';

const Color _navy = Color(0xFF1B2838);
const Color _orange = Color(0xFFE8722A);

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
            create: (context) =>
                sl<TenantDetailCubit>()..loadDetail(tenantId, hostelId),
          ),
          BlocProvider(create: (context) => sl<BookingsCubit>()),
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
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: BlocBuilder<TenantDetailCubit, TenantDetailState>(
        builder: (context, state) {
          final detail = state is TenantDetailLoaded ? state.detail : null;
          final String rent = detail?.stay?.rent != null
              ? detail!.stay!.rent.toStringAsFixed(0)
              : '';
          final String stayStatus = detail?.stay?.status ?? 'OCCUPIED';
          final bool isCheckedIn = stayStatus == 'CHECKED_IN';

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
                SizedBox(height: 16.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: _orange, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: _orange.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            children: [
                              SideViewBedIcon(size: 22.sp, color: _navy),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BED $bedNumber',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w900,
                                        color: _navy,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      tenantName.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[500],
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _navy,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  'ACCESS PASS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        TextButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.refresh_rounded, size: 16.sp, color: _orange),
                          label: Text(
                            'GENERATE NEW',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: _orange,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionIcon(
                        icon: Icons.currency_rupee_rounded,
                        label: 'RENT',
                        value: rent.isNotEmpty ? '₹$rent' : '—',
                        color: const Color(0xFF4CAF50),
                      ),
                      _buildActionIcon(
                        icon: Icons.share_rounded,
                        label: 'SHARE',
                        color: AppColors.primaryBlue,
                      ),
                      _buildActionIcon(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'SCAN',
                        color: _orange,
                      ),
                      _buildActionIcon(
                        icon: Icons.qr_code_rounded,
                        label: 'QR',
                        color: _navy,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _LiveTimeDateRow(),
                ),

                SizedBox(height: 20.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: BlocConsumer<BookingsCubit, BookingsState>(
                    listener: (context, BookingsState bookingsState) {
                      if (bookingsState.status == BookingsStatus.success &&
                          bookingsState.successMessage != null) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(bookingsState.successMessage!),
                          ),
                        );
                      }
                    },
                    builder: (context, BookingsState bookingsState) {
                      final isLoading =
                          bookingsState.status == BookingsStatus.loading;

                      return Row(
                        children: [
                          Expanded(
                            child: _buildCheckinButton(
                              context: context,
                              detail: detail,
                              isCheckedIn: isCheckedIn,
                              isLoading: isLoading,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildCheckoutButton(
                              context: context,
                              detail: detail,
                              isCheckedIn: isCheckedIn,
                              isLoading: isLoading,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildBillCard(
                          icon: Icons.bolt_rounded,
                          iconColor: const Color(0xFFFFD54F),
                          label: 'ELECTRICITY',
                          value: '—',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildBillCard(
                          icon: Icons.two_wheeler_rounded,
                          iconColor: _orange,
                          label: 'PARKING',
                          value: '—',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
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
                                      bookedSharingType: detail.stay!.roomTypename.toLowerCase().contains('single') 
                                          ? 'SINGLE' 
                                          : detail.stay!.roomTypename.toLowerCase().contains('double') || detail.stay!.roomTypename.toLowerCase().contains('2 sharing')
                                              ? 'DOUBLE'
                                              : detail.stay!.roomTypename.toLowerCase().contains('triple') || detail.stay!.roomTypename.toLowerCase().contains('3 sharing')
                                                  ? 'TRIPLE'
                                                  : detail.stay!.roomTypename.toLowerCase().contains('quadruple') || detail.stay!.roomTypename.toLowerCase().contains('4 sharing')
                                                      ? 'QUADRUPLE'
                                                      : detail.stay!.roomTypename.toLowerCase().contains('quintuple') || detail.stay!.roomTypename.toLowerCase().contains('5 sharing')
                                                          ? 'QUINTUPLE'
                                                          : detail.stay!.roomTypename.toLowerCase().contains('dormitory')
                                                              ? 'DORMITORY'
                                                              : null,
                                      bookedRoomType: detail.stay!.roomTypename.toLowerCase().contains('non ac') || detail.stay!.roomTypename.toLowerCase().contains('non-ac')
                                          ? 'NON-AC'
                                          : detail.stay!.roomTypename.toLowerCase().contains('ac')
                                              ? 'AC'
                                              : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _navy,
                        side: BorderSide(color: _navy.withValues(alpha: 0.2)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      icon: Icon(Icons.swap_horiz_rounded, size: 20.sp),
                      label: Text(
                        'CHANGE ROOM',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: GestureDetector(
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
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          CustomAvatar(
                            imageUrl: tenantAvatar,
                            name: tenantName,
                            size: 42.0,
                            isCircle: true,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tenantName,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _navy,
                                  ),
                                ),
                                Text(
                                  'View full profile',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16.sp,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                TenantMovementHistorySection(tenantId: tenantId),

                SizedBox(height: 16.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      icon: Icon(Icons.check_circle_outline_rounded, size: 20.sp),
                      label: Text(
                        'DONE',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    String? value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Icon(icon, size: 24.sp, color: color),
        ),
        SizedBox(height: 6.h),
        if (value != null)
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBillCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _orange.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 18.sp, color: iconColor),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 14.sp, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinButton({
    required BuildContext context,
    required dynamic detail,
    required bool isCheckedIn,
    required bool isLoading,
  }) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: isCheckedIn || isLoading || detail == null
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
                        bookedSharingType: detail.stay!.roomTypename.toLowerCase().contains('single') 
                            ? 'SINGLE' 
                            : detail.stay!.roomTypename.toLowerCase().contains('double') || detail.stay!.roomTypename.toLowerCase().contains('2 sharing')
                                ? 'DOUBLE'
                                : detail.stay!.roomTypename.toLowerCase().contains('triple') || detail.stay!.roomTypename.toLowerCase().contains('3 sharing')
                                    ? 'TRIPLE'
                                    : detail.stay!.roomTypename.toLowerCase().contains('quadruple') || detail.stay!.roomTypename.toLowerCase().contains('4 sharing')
                                        ? 'QUADRUPLE'
                                        : detail.stay!.roomTypename.toLowerCase().contains('quintuple') || detail.stay!.roomTypename.toLowerCase().contains('5 sharing')
                                            ? 'QUINTUPLE'
                                            : detail.stay!.roomTypename.toLowerCase().contains('dormitory')
                                                ? 'DORMITORY'
                                                : null,
                        bookedRoomType: detail.stay!.roomTypename.toLowerCase().contains('non ac') || detail.stay!.roomTypename.toLowerCase().contains('non-ac')
                            ? 'NON-AC'
                            : detail.stay!.roomTypename.toLowerCase().contains('ac')
                                ? 'AC'
                                : null,
                      ),
                    ),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isCheckedIn ? Colors.grey[200] : const Color(0xFFE8F5E9),
          foregroundColor: isCheckedIn ? Colors.grey : const Color(0xFF2E7D32),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(
              color: isCheckedIn ? Colors.grey[300]! : const Color(0xFF4CAF50).withValues(alpha: 0.3),
            ),
          ),
        ),
        icon: Icon(Icons.login_rounded, size: 18.sp),
        label: Text(
          'CHECK IN',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutButton({
    required BuildContext context,
    required dynamic detail,
    required bool isCheckedIn,
    required bool isLoading,
  }) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: !isCheckedIn || isLoading || detail == null
            ? null
            : () {
                CheckoutSettlementModal.show(
                  context,
                  tenantName: tenantName,
                  tenantId: tenantId,
                  hostelId: hostelId,
                  bookingId: detail.stay!.bookingId,
                  securityDeposit: detail.stay!.deposit,
                  onCheckoutConfirmed: ({
                    required double securityDeposit,
                    required double pendingRent,
                    required double utilityDue,
                    required double finalSettlement,
                    required List<SettlementPayment> settlementPayments,
                  }) {
                    context
                        .read<BookingsCubit>()
                        .checkoutBooking(
                          detail.stay!.bookingId,
                          securityDeposit: securityDeposit,
                          pendingRent: pendingRent,
                          utilityDue: utilityDue,
                          finalSettlement: finalSettlement,
                          settlementPayments: settlementPayments,
                        );
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: !isCheckedIn ? Colors.grey[200] : const Color(0xFFFBE9E7),
          foregroundColor: !isCheckedIn ? Colors.grey : const Color(0xFFC62828),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(
              color: !isCheckedIn ? Colors.grey[300]! : const Color(0xFFEF5350).withValues(alpha: 0.3),
            ),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.logout_rounded, size: 18.sp),
        label: Text(
          'CHECK OUT',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LiveTimeDateRow extends StatefulWidget {
  @override
  State<_LiveTimeDateRow> createState() => _LiveTimeDateRowState();
}

class _LiveTimeDateRowState extends State<_LiveTimeDateRow> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(_now);
    final dateStr = DateFormat('dd MMM').format(_now).toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE TIME',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: _navy,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 36.h,
          color: Colors.grey[200],
        ),
        SizedBox(width: 20.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'DATE',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16.sp, color: _navy),
                SizedBox(width: 6.w),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
