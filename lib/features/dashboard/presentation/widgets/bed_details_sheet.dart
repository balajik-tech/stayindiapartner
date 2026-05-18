import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/tenant_details_sheet.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_state.dart';
import 'package:stayindia_owner/features/bookings/widgets/qr_scanner_screen.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_state.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/profile/data/datasources/room_remote_datasource.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/checkout_settlement_modal.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';

enum BedStatus { free, occupied, notice, away, booked, maintenance }

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
  final String? roomId;
  final double? rent;
  final double? dailyRent;
  final double? maintenance;
  final double? deposit;
  final String? roomType;
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
    this.roomId,
    this.rent,
    this.dailyRent,
    this.maintenance,
    this.deposit,
    this.roomType,
    this.amenities,
    this.hostelName,
    this.hostelAddress,
    this.awayReturnDate,
  });
}

class BedDetailsSheet extends StatefulWidget {
  final BedState state;

  const BedDetailsSheet({super.key, required this.state});

  static void show(BuildContext context, BedState state) {
    final bookingsCubit = context.read<BookingsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: bookingsCubit),
          BlocProvider(
            create: (context) =>
                sl<TenantDetailCubit>()
                  ..loadDetail(state.tenantId ?? '', state.hostelId ?? ''),
          ),
        ],
        child: BedDetailsSheet(state: state),
      ),
    );
  }

  @override
  State<BedDetailsSheet> createState() => _BedDetailsSheetState();
}

class _BedDetailsSheetState extends State<BedDetailsSheet> {
  late BedStatus _currentStatus;
  bool _isTogglingMaintenance = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.state.status;
  }

  String _formatReturnDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return 'no_return_date'.tr() == 'no_return_date'
          ? 'No Return Date Set'
          : 'no_return_date'.tr();
    }
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        return DateFormat('dd MMM yyyy').format(parsed);
      }
    } catch (_) {}
    return rawDate;
  }

  Color get _statusColor {
    switch (_currentStatus) {
      case BedStatus.free:
        return const Color(0xFF87CEEB);
      case BedStatus.occupied:
        return const Color(0xFFFF8600);
      case BedStatus.notice:
        return const Color(0xFFFFB300);
      case BedStatus.away:
        return const Color(0xFFE91E63);
      case BedStatus.booked:
        return const Color(0xFF9C27B0);
      case BedStatus.maintenance:
        return const Color(0xFFCBD5E1);
    }
  }

  Color get _statusBgColor {
    switch (_currentStatus) {
      case BedStatus.free:
        return const Color(0xFFD6EEF8);
      case BedStatus.occupied:
        return const Color(0xFFFFEDD5);
      case BedStatus.notice:
        return const Color(0xFFFFF3CD);
      case BedStatus.away:
        return const Color(0xFFFFE4EE);
      case BedStatus.booked:
        return const Color(0xFFF3E8FF);
      case BedStatus.maintenance:
        return const Color(0xFFF1F5F9);
    }
  }

  Color get _statusTextColor {
    switch (_currentStatus) {
      case BedStatus.free:
        return const Color(0xFF1A6F8A);
      case BedStatus.occupied:
        return const Color(0xFF8B4000);
      case BedStatus.notice:
        return const Color(0xFF7A5800);
      case BedStatus.away:
        return const Color(0xFF9C0040);
      case BedStatus.booked:
        return const Color(0xFF6A0080);
      case BedStatus.maintenance:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth < 360 ? 16.w : 24.w;

    return BlocConsumer<BookingsCubit, BookingsState>(
      listener: (context, bookingsState) {
        if (bookingsState.status == BookingsStatus.success &&
            bookingsState.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(bookingsState.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (bookingsState.status == BookingsStatus.failure &&
            bookingsState.errorMessage != null) {
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: SafeArea(
                top: false,
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
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildQRSection(context),
                              SizedBox(height: 20.h),
                              _buildRoomDetailsCard(context),
                              SizedBox(height: 12.h),
                              _buildMaintenanceToggle(context),
                              SizedBox(height: 12.h),
                              _buildTenantProfileSection(context),
                              SizedBox(height: 20.h),
                              _buildDoneButton(context),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
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
                    child: CircularProgressIndicator(color: Color(0xFF0F172A)),
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
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        children: [
          CustomAvatar(
            imageUrl: ApiConstants.getImageUrl(widget.state.profileImage),
            name: widget.state.tenantName ?? '?',
            size: 38.r,
            isCircle: false,
            borderRadius: 10.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${'bed'.tr()} ${widget.state.bedNumber}".toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  _currentStatus == BedStatus.maintenance
                      ? 'Under Maintenance'
                      : (widget.state.tenantName ?? 'available'.tr()),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _currentStatus == BedStatus.maintenance
                        ? const Color(0xFF475569)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'STAY ',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2C599D),
                        letterSpacing: 0.5,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    TextSpan(
                      text: 'INDIA',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF98125),
                        letterSpacing: 0.5,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: _statusColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _currentStatus == BedStatus.maintenance
                      ? 'MAINTENANCE'
                      : (_currentStatus == BedStatus.free
                            ? 'AVAILABLE'
                            : 'ACCESS PASS'),
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w900,
                    color: _statusTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingSection(BuildContext context) {
    String? name = widget.state.hostelName;
    String? address = widget.state.hostelAddress;
    String? district;
    String? state;

    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostel = hostelState.hostels[hostelState.selectedHostelIndex];
      name ??= hostel.name;
      address ??= hostel.address;
      district = hostel.district;
      state = hostel.state;
    }

    final List<String> addressParts = [];
    if (address != null && address.trim().isNotEmpty) {
      addressParts.add(address.trim());
    }
    if (district != null && district.trim().isNotEmpty) {
      addressParts.add(district.trim());
    }
    if (state != null && state.trim().isNotEmpty) {
      addressParts.add(state.trim());
    }
    final String fullAddress = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'india'.tr();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          Text(
            (name ?? 'app_name'.tr()).toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: const Color(0xFFCBD5E1),
                size: 12.sp,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  fullAddress,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
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
    final isFree = _currentStatus == BedStatus.free;

    return Container(
      width: double.infinity,
      height: 160.h,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.05),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isFree)
            GestureDetector(
              onTap: () => _openScanner(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: statusTextColor,
                        size: 32.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'scan_to_checkin'.tr(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: statusTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          else if (_currentStatus == BedStatus.maintenance)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.handyman_rounded,
                      color: statusTextColor,
                      size: 28.sp,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'UNDER MAINTENANCE',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: statusTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Blocked for maintenance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            )
          else if (_currentStatus == BedStatus.away)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.directions_walk_rounded,
                      color: statusTextColor,
                      size: 28.sp,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'AWAY'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: statusTextColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.state.awayReturnDate != null
                      ? "Returning: ${_formatReturnDate(widget.state.awayReturnDate)}"
                      : 'No Return Date Set',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data: "BED-${widget.state.bedNumber}",
                  version: QrVersions.auto,
                  size: 110.r,
                  padding: EdgeInsets.all(4.r),
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0F172A),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ..._buildCornerAccents(statusColor),
        ],
      ),
    );
  }

  List<Widget> _buildCornerAccents(Color color) {
    return [
      Positioned(
        top: 0,
        left: 0,
        child: _accent(color, isTop: true, isLeft: true),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: _accent(color, isTop: true, isLeft: false),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: _accent(color, isTop: false, isLeft: true),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: _accent(color, isTop: false, isLeft: false),
      ),
    ];
  }

  Widget _accent(Color color, {required bool isTop, required bool isLeft}) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: color.withValues(alpha: 0.4), width: 3)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: color.withValues(alpha: 0.4), width: 3)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: color.withValues(alpha: 0.4), width: 3)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: color.withValues(alpha: 0.4), width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRoomDetailsCard(BuildContext context) {
    final roomType = widget.state.roomType ?? 'NON-AC';
    final isAc =
        roomType.toUpperCase().contains('AC') &&
        !roomType.toUpperCase().contains('NON');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room Configuration',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isAc
                      ? const Color(0xFFE0F2FE)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isAc
                        ? const Color(0xFFBAE6FD)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAc ? Icons.ac_unit_rounded : Icons.mode_fan_off_rounded,
                      size: 13.sp,
                      color: isAc
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF64748B),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      roomType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: isAc
                            ? const Color(0xFF0369A1)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildDetailGridItem(
                  Icons.payments_rounded,
                  'Monthly Rent',
                  '₹${widget.state.rent?.toInt() ?? 0}',
                  const Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDetailGridItem(
                  Icons.build_circle_rounded,
                  'Maintenance',
                  '₹${widget.state.maintenance?.toInt() ?? 0}',
                  const Color(0xFF475569),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildDetailGridItem(
                  Icons.shield_rounded,
                  'Security Deposit',
                  '₹${widget.state.deposit?.toInt() ?? 0}',
                  const Color(0xFF475569),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDetailGridItem(
                  Icons.today_rounded,
                  'Daily Rent',
                  '₹${widget.state.dailyRent?.toInt() ?? 0}',
                  const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailGridItem(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: const Color(0xFF94A3B8)),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceToggle(BuildContext context) {
    if (_currentStatus != BedStatus.free &&
        _currentStatus != BedStatus.maintenance) {
      return const SizedBox.shrink();
    }

    final isMaintenance = _currentStatus == BedStatus.maintenance;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        onPressed: _isTogglingMaintenance
            ? null
            : () => _updateBedStatus(
                context,
                isMaintenance ? 'FREE' : 'MAINTENANCE',
              ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isMaintenance
                ? const Color(0xFFCBD5E1)
                : const Color(0xFFCBD5E1),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: isMaintenance
              ? const Color(0xFFF1F5F9)
              : Colors.transparent,
        ),
        icon: _isTogglingMaintenance
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF475569),
                ),
              )
            : Icon(
                isMaintenance ? Icons.handyman_rounded : Icons.build_rounded,
                size: 18.sp,
                color: isMaintenance
                    ? const Color(0xFF475569)
                    : const Color(0xFF64748B),
              ),
        label: Text(
          isMaintenance ? 'Restore Bed to Available' : 'Put Under Maintenance',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: isMaintenance
                ? const Color(0xFF475569)
                : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Future<void> _updateBedStatus(
    BuildContext context,
    String newStatusStr,
  ) async {
    final rId = widget.state.roomId;
    if (rId == null || rId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Room ID is missing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fullBedNum = widget.state.bedNumber;
    final cleanBedNum = fullBedNum.contains('-')
        ? fullBedNum.split('-').last
        : fullBedNum;

    setState(() {
      _isTogglingMaintenance = true;
    });

    try {
      await sl<RoomRemoteDataSource>().updateBedStatus(
        rId,
        cleanBedNum,
        newStatusStr,
      );

      if (context.mounted) {
        setState(() {
          _currentStatus = newStatusStr == 'MAINTENANCE'
              ? BedStatus.maintenance
              : BedStatus.free;
          _isTogglingMaintenance = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatusStr == 'MAINTENANCE'
                  ? 'Bed is now marked as Under Maintenance!'
                  : 'Bed is now marked as Available!',
            ),
            backgroundColor: newStatusStr == 'MAINTENANCE'
                ? const Color(0xFF475569)
                : Colors.green,
          ),
        );

        final hostelId = widget.state.hostelId;
        if (hostelId != null && hostelId.isNotEmpty) {
          context.read<DashboardCubit>().fetchDashboardData(hostelId);
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isTogglingMaintenance = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update bed status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTenantProfileSection(BuildContext context) {
    if (widget.state.tenantId == null || widget.state.tenantId!.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<TenantDetailCubit, TenantDetailState>(
      builder: (context, tenantState) {
        if (tenantState is TenantDetailLoading) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F172A)),
            ),
          );
        }

        if (tenantState is TenantDetailError) {
          return _buildTenantCard(
            context,
            name: widget.state.tenantName ?? 'Tenant',
            avatar: widget.state.profileImage,
            mobile: '',
          );
        }

        if (tenantState is TenantDetailLoaded) {
          final detail = tenantState.detail;
          return _buildTenantCard(
            context,
            name: detail.name,
            avatar: detail.avatar,
            mobile: detail.mobile,
            detail: detail,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTenantCard(
    BuildContext context, {
    required String name,
    required String? avatar,
    required String mobile,
    TenantDetailEntity? detail,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned Tenant',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final tId = detail?.id ?? widget.state.tenantId;
                final hId = widget.state.hostelId;
                final rNum =
                    detail?.stay?.roomTypename ??
                    widget.state.roomNumber ??
                    'N/A';

                if (tId != null &&
                    tId.isNotEmpty &&
                    hId != null &&
                    hId.isNotEmpty) {
                  TenantDetailsSheet.show(
                    context,
                    name: name,
                    imageUrl: ApiConstants.getImageUrl(avatar),
                    room: rNum,
                    tenantId: tId,
                    hostelId: hId,
                  );
                }
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                child: Row(
                  children: [
                    CustomAvatar(
                      imageUrl: ApiConstants.getImageUrl(avatar),
                      name: name,
                      size: 48.r,
                      isCircle: true,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (mobile.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              mobile,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFF64748B),
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (mobile.isNotEmpty) ...[
                Expanded(
                  child: _buildTenantActionButton(
                    Icons.call_rounded,
                    'Call',
                    const Color(0xFF10B981),
                    const Color(0xFFECFDF5),
                    () => _launchUrl('tel:$mobile'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildTenantActionButton(
                    Icons.chat_bubble_rounded,
                    'WhatsApp',
                    const Color(0xFF06B6D4),
                    const Color(0xFFECFEFF),
                    () => _launchUrl('https://wa.me/$mobile'),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: _buildTenantActionButton(
                  Icons.exit_to_app_rounded,
                  'Check-out',
                  const Color(0xFFEF4444),
                  const Color(0xFFFEF2F2),
                  () => _confirmCheckout(context, detail),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(height: 1.h, color: const Color(0xFFF1F5F9)),
          SizedBox(height: 16.h),
          Text(
            'Quick Actions / Send Bills',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildTenantActionButton(
                  Icons.directions_car_rounded,
                  'Parking Bill',
                  const Color(0xFF475569),
                  const Color(0xFFF1F5F9),
                  () => _showSendBillDialog(context, 'PARKING'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildTenantActionButton(
                  Icons.flash_on_rounded,
                  'Electric Bill',
                  const Color(0xFF475569),
                  const Color(0xFFF1F5F9),
                  () => _showSendBillDialog(context, 'ELECTRICITY'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTenantActionButton(
    IconData icon,
    String label,
    Color color,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 44.h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: color.withValues(alpha: 0.15)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
        ),
        icon: Icon(icon, size: 14.sp),
        label: Text(
          label,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  void _showSendBillDialog(BuildContext context, String billType) {
    final TextEditingController amountController = TextEditingController();
    final bool isParking = billType.toUpperCase() == 'PARKING';
    final typeStr = isParking ? 'Parking' : 'Electricity';
    final icon = isParking ? '🚗' : '⚡';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 8.w),
            Text(
              'Send $typeStr Bill',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the bill amount to send a notification to ${widget.state.tenantName ?? "this tenant"}.',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
                labelText: 'Amount',
                labelStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF0F172A),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final double? amt = double.tryParse(amountController.text);
              if (amt == null || amt <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please enter a valid amount greater than 0.',
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(dialogCtx);
              await _sendBill(context, billType, amt);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            child: Text(
              'SEND BILL',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendBill(
    BuildContext context,
    String billType,
    double amount,
  ) async {
    final tId = widget.state.tenantId;
    if (tId == null || tId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Tenant ID is missing.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F172A)),
      ),
    );

    try {
      final dio = sl<Dio>();
      final response = await dio.post(
        '${ApiConstants.baseUrl}/api/v1/notifications/send-bill',
        data: {
          'tenantId': tId,
          'billType': billType.toUpperCase(),
          'amount': amount,
        },
      );

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${billType.toUpperCase() == 'PARKING' ? 'Parking' : 'Electricity'} bill sent successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to send bill');
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmCheckout(BuildContext context, TenantDetailEntity? detail) {
    if (detail == null) return;
    CheckoutSettlementModal.show(
      context,
      tenantName: detail.name,
      tenantId: detail.id,
      hostelId: widget.state.hostelId ?? '',
      bookingId: detail.stay?.bookingId ?? widget.state.tenantId ?? '',
      securityDeposit: detail.stay?.deposit ?? 0.0,
      onCheckoutConfirmed: () {
        context.read<BookingsCubit>().checkoutBooking(
          detail.stay?.bookingId ?? widget.state.tenantId ?? '',
        );
      },
    );
  }

  void _openScanner(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (result != null && context.mounted) {
      context.read<BookingsCubit>().scanBooking(
        result,
        hostelId: widget.state.hostelId,
      );
    }
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: _statusTextColor,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'done'.tr(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
