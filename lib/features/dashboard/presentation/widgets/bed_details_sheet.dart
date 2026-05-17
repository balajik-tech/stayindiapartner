import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_state.dart';
import 'package:stayindia_owner/features/bookings/widgets/qr_scanner_screen.dart';


enum BedStatus { free, occupied, notice, away, booked }

class BedState {
  final BedStatus status;
  final String bedNumber;
  final String? tenantName;
  final String? profileImage;
  final String? joiningDate;
  final String? vacatingDate;
  final String? tenantId;
  final String? hostelId;
  final String? roomNumber;
  final double? rent;
  final double? dailyRent;
  final double? maintenance;
  final List<String>? amenities;
  final String? hostelName;
  final String? hostelAddress;
  final String? awayReturnDate;

  BedState({
    required this.status,
    required this.bedNumber,
    this.tenantName,
    this.profileImage,
    this.joiningDate,
    this.vacatingDate,
    this.tenantId,
    this.hostelId,
    this.roomNumber,
    this.rent,
    this.dailyRent,
    this.maintenance,
    this.amenities,
    this.hostelName,
    this.hostelAddress,
    this.awayReturnDate,
  });
}

class BedDetailsSheet extends StatelessWidget {
  final BedState state;

  const BedDetailsSheet({super.key, required this.state});

  static void show(BuildContext context, BedState state) {
    final bookingsCubit = context.read<BookingsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: bookingsCubit,
        child: BedDetailsSheet(state: state),
      ),
    );
  }

  String _formatReturnDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'no_return_date'.tr() == 'no_return_date' ? 'No Return Date Set' : 'no_return_date'.tr();
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return DateFormat('dd MMM yyyy').format(parsed);
      }
    } catch (_) {}
    return rawDate;
  }

  Color get _statusColor {
    switch (state.status) {
      case BedStatus.free:     return const Color(0xFF87CEEB);
      case BedStatus.occupied: return const Color(0xFFFF8600);
      case BedStatus.notice:   return const Color(0xFFFFB300);
      case BedStatus.away:     return const Color(0xFFE91E63);
      case BedStatus.booked:   return const Color(0xFF9C27B0);
    }
  }

  Color get _statusBgColor {
    switch (state.status) {
      case BedStatus.free:     return const Color(0xFFD6EEF8);
      case BedStatus.occupied: return const Color(0xFFFFEDD5);
      case BedStatus.notice:   return const Color(0xFFFFF3CD);
      case BedStatus.away:     return const Color(0xFFFFE4EE);
      case BedStatus.booked:   return const Color(0xFFF3E8FF);
    }
  }


  Color get _statusTextColor {
    switch (state.status) {
      case BedStatus.free:     return const Color(0xFF1A6F8A);
      case BedStatus.occupied: return const Color(0xFF8B4000);
      case BedStatus.notice:   return const Color(0xFF7A5800);
      case BedStatus.away:     return const Color(0xFF9C0040);
      case BedStatus.booked:   return const Color(0xFF6A0080);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth < 360 ? 16.w : 36.w;

    return BlocConsumer<BookingsCubit, BookingsState>(
      listener: (context, bookingsState) {
        if (bookingsState.status == BookingsStatus.success && bookingsState.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(bookingsState.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (bookingsState.status == BookingsStatus.failure && bookingsState.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(bookingsState.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, bookingsState) {
        final isLoading = bookingsState.status == BookingsStatus.loading;

        return Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 12.h),
                      Container(
                        width: 50.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      _buildPassHeader(context),
                      _buildBrandingSection(context),
                      _buildQRSection(context),
                      SizedBox(height: 32.h),
                      _buildActionRow(context),
                      SizedBox(height: 32.h),
                      _buildDoneButton(context),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.15),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPassHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Row(
        children: [
          CustomAvatar(
            imageUrl: ApiConstants.getImageUrl(state.profileImage),
            name: state.tenantName ?? '?',
            size: 44.r,
            isCircle: false,
            borderRadius: 12.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${'bed'.tr()} ${state.bedNumber}".toUpperCase(),
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: -0.5),
                ),
                Text(
                  state.tenantName ?? 'available'.tr(),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Text(
              'access_pass'.tr(),
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingSection(BuildContext context) {
    String? name = state.hostelName;
    String? address = state.hostelAddress;

    if (name == null || address == null) {
      final hostelState = context.read<HostelCubit>().state;
      if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
        final hostel = hostelState.hostels[hostelState.selectedHostelIndex];
        name ??= hostel.name;
        address ??= hostel.address;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          Text(
            (name ?? 'app_name'.tr()).toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp, 
              fontWeight: FontWeight.w900, 
              color: const Color(0xFF0F172A), 
              letterSpacing: 1.5
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded, color: const Color(0xFFCBD5E1), size: 14.sp),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  address ?? 'india'.tr(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp, 
                    fontWeight: FontWeight.w600, 
                    color: const Color(0xFF94A3B8)
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRSection(BuildContext context) {
    final statusColor = _statusColor;
    final statusBgColor = _statusBgColor;
    final statusTextColor = _statusTextColor;
    final isFree = state.status == BedStatus.free;

    return AspectRatio(
      aspectRatio: 1.1,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(color: statusColor, width: 3),
          boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 5)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isFree)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150.r,
                    height: 150.r,
                    decoration: BoxDecoration(color: statusBgColor, shape: BoxShape.circle),
                    child: Center(child: Icon(Icons.qr_code_scanner_rounded, color: statusTextColor, size: 75.sp)),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'scan_to_checkin'.tr(),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: statusTextColor, letterSpacing: 1.2),
                  ),
                ],
              )
            else if (state.status == BedStatus.away)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130.r,
                    height: 130.r,
                    decoration: BoxDecoration(color: statusBgColor, shape: BoxShape.circle),
                    child: Center(child: Icon(Icons.directions_walk_rounded, color: statusTextColor, size: 60.sp)),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'AWAY'.toUpperCase(),
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: statusTextColor),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.awayReturnDate != null
                        ? "${'returning_on'.tr() == 'returning_on' ? 'Returning On' : 'returning_on'.tr()}: ${_formatReturnDate(state.awayReturnDate)}"
                        : ('no_return_date'.tr() == 'no_return_date' ? 'No Return Date Set' : 'no_return_date'.tr()),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
                  ),
                ],
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: "BED-${state.bedNumber}",
                    version: QrVersions.auto,
                    size: 160.r,
                    padding: EdgeInsets.all(12.r),
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ..._buildCornerAccents(statusColor),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerAccents(Color color) {
    return [
      Positioned(top: 0, left: 0, child: _accent(color, isTop: true, isLeft: true)),
      Positioned(top: 0, right: 0, child: _accent(color, isTop: true, isLeft: false)),
      Positioned(bottom: 0, left: 0, child: _accent(color, isTop: false, isLeft: true)),
      Positioned(bottom: 0, right: 0, child: _accent(color, isTop: false, isLeft: false)),
    ];
  }

  Widget _accent(Color color, {required bool isTop, required bool isLeft}) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: color.withValues(alpha: 0.4), width: 3) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: color.withValues(alpha: 0.4), width: 3) : BorderSide.none,
          left: isLeft ? BorderSide(color: color.withValues(alpha: 0.4), width: 3) : BorderSide.none,
          right: !isLeft ? BorderSide(color: color.withValues(alpha: 0.4), width: 3) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    final bool isOccupied = state.status != BedStatus.free;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionPillItem('rent'.tr(), "₹${state.rent?.toInt() ?? 0}", _statusTextColor, _statusBgColor),
        if (isOccupied)
          _buildActionPillIcon(
            Icons.exit_to_app_rounded, 
            'checkout'.tr(), 
            iconColor: Colors.red,
            onTap: () => _confirmCheckout(context),
          )
        else
          _buildActionPillIcon(
            Icons.qr_code_scanner_rounded, 
            'scan'.tr(), 
            iconColor: const Color(0xFFFF8600), 
            onTap: () => _openScanner(context)
          ),
        _buildActionPillIcon(Icons.qr_code_rounded, 'qr'.tr(), iconColor: const Color(0xFF2563EB)),
      ],
    );
  }

  void _confirmCheckout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('confirm_checkout'.tr() == 'confirm_checkout' ? 'Confirm Check-out' : 'confirm_checkout'.tr()),
        content: Text('checkout_confirm_msg'.tr(
          namedArgs: {'tenant': state.tenantName ?? ('this_tenant'.tr() == 'this_tenant' ? 'this tenant' : 'this_tenant'.tr())},
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr() == 'cancel' ? 'Cancel' : 'cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingsCubit>().checkoutBooking(state.tenantId ?? '');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(('checkout'.tr() == 'checkout' ? 'Check-out' : 'checkout'.tr()).toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _openScanner(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (result != null && context.mounted) {
      context.read<BookingsCubit>().scanBooking(result, hostelId: state.hostelId);
    }
  }

  Widget _buildActionPillItem(String label, String value, Color color, Color bgColor) {
    return Container(
      width: 80.w,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: color)),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionPillIcon(IconData icon, String label, {Color? iconColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: iconColor ?? const Color(0xFF475569)),
            SizedBox(height: 4.h),
            Text(label, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: _statusTextColor, size: 22.sp),
            SizedBox(width: 12.w),
            Text('done'.tr(), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }
}



