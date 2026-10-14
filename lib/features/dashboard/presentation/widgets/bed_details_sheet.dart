import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/features/movement_history/presentation/widgets/tenant_movement_history_section.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/tenant_details_sheet.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_state.dart';
import 'package:stayindia_owner/features/bookings/widgets/qr_scanner_screen.dart';
import 'package:stayindia_owner/features/bookings/pages/room_selection_page.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
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
  final String? sharingType;

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
    this.sharingType,
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
  double? _electricityBillAmount;
  double? _parkingBillAmount;
  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _parkingController = TextEditingController();

  String _formatBedNumber(String bedNumber) {
    if (bedNumber.contains('-')) {
      final parts = bedNumber.split('-');
      final lastPart = parts.last;
      final index = int.tryParse(lastPart);
      if (index != null && index >= 1 && index <= 26) {
        final letter = String.fromCharCode('A'.codeUnitAt(0) + index - 1);
        return '${parts.sublist(0, parts.length - 1).join('-')}-$letter';
      }
    }
    return bedNumber;
  }

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.state.status;
  }

  @override
  void dispose() {
    _electricityController.dispose();
    _parkingController.dispose();
    super.dispose();
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
            bookingsState.scannedBooking != null) {
          final scanned = bookingsState.scannedBooking!;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Confirm Check-in'),
              content: Text(
                'Do you want to assign ${scanned.tenantName} to Bed ${_formatBedNumber(widget.state.bedNumber)}?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<BookingsCubit>().clearScannedBooking();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<BookingsCubit>().finalizeCheckin(
                      bookingId: scanned.bookingId,
                      roomId: widget.state.roomId ?? '',
                      bedNumber: widget.state.bedNumber,
                    );
                    context.read<BookingsCubit>().clearScannedBooking();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );
        } else if (bookingsState.status == BookingsStatus.success &&
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
                maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                              if (widget.state.tenantId != null && widget.state.tenantId!.isNotEmpty) ...[
                                SizedBox(height: 20.h),
                                TenantMovementHistorySection(tenantId: widget.state.tenantId!),
                              ],
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

  void _showFullScreenImage(BuildContext context, String? imageUrl, String fallbackName) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CustomAvatar(
                  imageUrl: imageUrl,
                  name: fallbackName,
                  size: MediaQuery.of(context).size.width,
                  isCircle: false,
                  borderRadius: 0,
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassHeader(BuildContext context) {
    final avatarUrl = ApiConstants.getImageUrl(widget.state.profileImage);
    final fallbackName = widget.state.tenantName ?? '?';

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(context, avatarUrl, fallbackName),
            child: CustomAvatar(
              imageUrl: avatarUrl,
              name: fallbackName,
              size: 38.r,
              isCircle: false,
              borderRadius: 10.r,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${'bed'.tr()} ${_formatBedNumber(widget.state.bedNumber)}".toUpperCase(),
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
    if (_currentStatus != BedStatus.free && 
        _currentStatus != BedStatus.maintenance && 
        _currentStatus != BedStatus.away) {
      return const SizedBox.shrink();
    }

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
    return BlocBuilder<TenantDetailCubit, TenantDetailState>(
      builder: (context, tenantState) {
        double rent = widget.state.rent ?? 0;
        double deposit = widget.state.deposit ?? 0;
        double maintenance = widget.state.maintenance ?? 0;
        double electricityBill = 0;
        String? electricityBillStatus;
        double dailyRent = widget.state.dailyRent ?? 0;
        String roomType = widget.state.roomType ?? 'NON-AC';
        String? sharingType = widget.state.sharingType;

        final bool isOccupied = _currentStatus != BedStatus.free &&
            _currentStatus != BedStatus.maintenance &&
            widget.state.tenantId != null &&
            widget.state.tenantId!.isNotEmpty;

        if (tenantState is TenantDetailLoaded) {
          final detail = tenantState.detail;
          final stay = detail.stay;

          electricityBill = detail.electricityBillShare ??
              detail.electricityBill ??
              stay?.electricityBillShare ??
              stay?.electricityBill ??
              0;

          electricityBillStatus = detail.electricityBillStatus ?? stay?.electricityBillStatus;

          if (detail.payments.isNotEmpty) {
            final firstPayment = detail.payments.first;
            if (firstPayment.rent != null && firstPayment.rent! > 0) {
              rent = firstPayment.rent!;
            } else if (stay != null && stay.rent > 0) {
              rent = stay.rent;
            }

            if (firstPayment.maintenance != null) {
              maintenance = firstPayment.maintenance!;
            }

            if (firstPayment.deposit != null && firstPayment.deposit! > 0) {
              deposit = firstPayment.deposit!;
            } else if (stay != null && stay.deposit > 0) {
              deposit = stay.deposit;
            }
          } else if (stay != null) {
            rent = stay.rent;
            deposit = stay.deposit;
          }

          if (stay != null) {
            if (stay.acType != null && stay.acType!.isNotEmpty) {
              roomType = stay.acType!;
            }
            if (stay.sharingType != null && stay.sharingType!.isNotEmpty) {
              sharingType = stay.sharingType;
            }
          }
        }

        final isAc = roomType.toUpperCase().contains('AC') &&
            !roomType.toUpperCase().contains('NON');

        final String elecBillStr = electricityBill == 0
            ? '₹0'
            : (electricityBill % 1 == 0
                ? '₹${electricityBill.toInt()}'
                : '₹${electricityBill.toStringAsFixed(2)}');

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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sharingType != null && sharingType.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFFFEDD5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_rounded,
                                size: 13.sp,
                                color: const Color(0xFFEA580C),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                StringUtils.formatSharingType(sharingType, context).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFC2410C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
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
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailGridItem(
                      Icons.payments_rounded,
                      'Monthly Rent',
                      '₹${rent.toInt()}',
                      const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildDetailGridItem(
                      Icons.build_circle_rounded,
                      'Maintenance',
                      '₹${maintenance.toInt()}',
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
                      '₹${deposit.toInt()}',
                      const Color(0xFF475569),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: isOccupied
                        ? _buildDetailGridItem(
                            Icons.bolt_rounded,
                            'Electricity Bill',
                            elecBillStr,
                            const Color(0xFF475569),
                            status: electricityBillStatus,
                          )
                        : _buildDetailGridItem(
                            Icons.today_rounded,
                            'Daily Rent',
                            '₹${dailyRent.toInt()}',
                            const Color(0xFF475569),
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailGridItem(
    IconData icon,
    String label,
    String value,
    Color valueColor, {
    String? status,
  }) {

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 14.sp, color: const Color(0xFF94A3B8)),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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

    return BlocConsumer<TenantDetailCubit, TenantDetailState>(
      listener: (context, tenantState) {
        if (tenantState is TenantDetailLoaded) {
          final detail = tenantState.detail;
          if (_electricityBillAmount == null) {
            final bill = detail.electricityBillShare ??
                detail.electricityBill ??
                detail.stay?.electricityBillShare ??
                detail.stay?.electricityBill;
            if (bill != null && bill > 0) {
              _electricityBillAmount = bill;
              _electricityController.text = bill % 1 == 0
                  ? bill.toInt().toString()
                  : bill.toStringAsFixed(2);
            }
          }
          if (_parkingBillAmount == null && detail.stay?.parkingBill != null) {
            _parkingBillAmount = detail.stay!.parkingBill;
            if (_parkingBillAmount! > 0) {
              _parkingController.text = _parkingBillAmount!.toStringAsFixed(0);
            }
          }
        }
      },
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
    const Color navy = Color(0xFF1B2838);
    const Color orange = Color(0xFFE8722A);
    final isBooked = _currentStatus == BedStatus.booked;

    return Column(
      children: [
        // _LiveTimeDateWidget(),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () => _showActiveActionsBottomSheet(context, detail),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBooked ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9),
                    foregroundColor: isBooked ? const Color(0xFF1976D2) : const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      side: BorderSide(
                        color: (isBooked ? const Color(0xFF2196F3) : const Color(0xFF4CAF50)).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  icon: Icon(isBooked ? Icons.add_task_rounded : Icons.login_rounded, size: 18.sp),
                  label: Text(
                    isBooked ? 'ASSIGN ROOM' : 'ROOM CHANGE',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isBooked) {
                      _showCancelConfirmation(context, detail);
                    } else {
                      _confirmCheckout(context, detail);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBE9E7),
                    foregroundColor: const Color(0xFFC62828),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      side: BorderSide(color: const Color(0xFFEF5350).withValues(alpha: 0.3)),
                    ),
                  ),
                  icon: Icon(isBooked ? Icons.close_rounded : Icons.logout_rounded, size: 18.sp),
                  label: Text(
                    isBooked ? 'REJECT' : 'CHECK OUT',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Row(
        //   children: [
        //     Expanded(
        //       child: _buildDarkBillCard(
        //         icon: Icons.bolt_rounded,
        //         iconColor: const Color(0xFFFFD54F),
        //         label: 'ELECTRICITY',
        //         controller: _electricityController,
        //         currentBillValue: _electricityBillAmount,
        //         onSend: () {
        //           final double? amt = double.tryParse(_electricityController.text);
        //           if (amt == null || amt <= 0) {
        //             ScaffoldMessenger.of(context).showSnackBar(
        //               const SnackBar(
        //                 content: Text('Please enter a valid amount greater than 0.'),
        //                 behavior: SnackBarBehavior.floating,
        //               ),
        //             );
        //             return;
        //           }
        //           _showConfirmSendBillDialog(context, 'ELECTRICITY', amt);
        //         },
        //       ),
        //     ),
        //     SizedBox(width: 12.w),
        //     Expanded(
        //       child: _buildDarkBillCard(
        //         icon: Icons.two_wheeler_rounded,
        //         iconColor: orange,
        //         label: 'PARKING',
        //         controller: _parkingController,
        //         currentBillValue: _parkingBillAmount,
        //         onSend: () {
        //           final double? amt = double.tryParse(_parkingController.text);
        //           if (amt == null || amt <= 0) {
        //             ScaffoldMessenger.of(context).showSnackBar(
        //               const SnackBar(
        //                 content: Text('Please enter a valid amount greater than 0.'),
        //                 behavior: SnackBarBehavior.floating,
        //               ),
        //             );
        //             return;
        //           }
        //           _showConfirmSendBillDialog(context, 'PARKING', amt);
        //         },
        //       ),
        //     ),
        //   ],
        // ),

        SizedBox(height: 16.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
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
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe9f5fe),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: const Color(0xFFeaeff3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFdfe9fd),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 1,
                          ),
                        ),
                        child:Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Icon(
                            Icons.people_alt_rounded,
                            size: 20.sp,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Tenant Overview',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF212e38),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
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
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final imageUrl = ApiConstants.getImageUrl(avatar);
                            if (imageUrl != null && imageUrl.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    backgroundColor: Colors.black,
                                    appBar: AppBar(
                                      backgroundColor: Colors.black,
                                      iconTheme: const IconThemeData(color: Colors.white),
                                    ),
                                    body: Center(
                                      child: InteractiveViewer(
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.contain,
                                          placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                                          errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          child: CustomAvatar(
                            imageUrl: ApiConstants.getImageUrl(avatar),
                            name: name,
                            size: 44.r,
                            isCircle: true,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w900,
                                  color: navy,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (mobile.isNotEmpty)
                                Text(
                                  mobile,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: const Color(0xFF94A3B8), size: 22.sp),
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
                        () {
                          String cleanPhone = mobile.replaceAll(RegExp(r'\D'), '');
                          if (cleanPhone.length == 10) {
                            cleanPhone = '91$cleanPhone';
                          }
                          _launchUrl('https://wa.me/$cleanPhone');
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required String label,
    String? value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
                color: const Color(0xFF1B2838),
              ),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkBillCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
    required VoidCallback onSend,
    required double? currentBillValue,
  }) {
    const Color navy = Color(0xFF1B2838);
    const Color orange = Color(0xFFE8722A);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: orange.withValues(alpha: 0.4), width: 1.5),
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
                child: Icon(icon, size: 16.sp, color: iconColor),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
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
            children: [
              Expanded(
                child: SizedBox(
                  height: 44.h,
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade400,
                      ),
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(color: orange),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onSend,
                child: Container(
                  height: 44.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: orange,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (currentBillValue != null && currentBillValue > 0) ...[
            SizedBox(height: 6.h),
            Text(
              'Sent: ₹${currentBillValue.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ] else ...[
            SizedBox(height: 6.h),
            Text(
              'Not Sent Yet',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
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

  void _showConfirmSendBillDialog(
    BuildContext context,
    String billType,
    double amount,
  ) {
    final typeStr = billType.toUpperCase() == 'PARKING' ? 'Parking' : 'Electricity';
    final icon = billType.toUpperCase() == 'PARKING' ? Icons.two_wheeler_rounded : Icons.bolt_rounded;
    final iconColor = billType.toUpperCase() == 'PARKING' ? const Color(0xFFE8722A) : const Color(0xFFFFD54F);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2838),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: const BorderSide(color: Color(0xFFE8722A), width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Confirm Bill',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to send a $typeStr bill of ₹${amount.toStringAsFixed(0)} to the tenant?',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsPadding: EdgeInsets.only(bottom: 16.h, right: 16.w, left: 16.w),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _sendBill(context, billType, amount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8722A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Send',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
        '${ApiConstants.baseUrl}/notifications/send-bill',
        data: {
          'tenantId': tId,
          'billType': billType.toUpperCase(),
          'amount': amount,
        },
      );

      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        if (context.mounted) {
          setState(() {
            if (billType.toUpperCase() == 'PARKING') {
              _parkingBillAmount = amount;
              _parkingController.clear();
            } else {
              _electricityBillAmount = amount;
              _electricityController.clear();
            }
          });
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${billType.toUpperCase() == 'PARKING' ? 'Parking' : 'Electricity'} bill of ₹${amount.toStringAsFixed(0)} sent successfully!',
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
    final bookingId = detail?.stay?.bookingId ?? widget.state.tenantId ?? '';
    CheckoutSettlementModal.show(
      context,
      tenantName: detail?.name ?? widget.state.tenantName ?? 'Tenant',
      tenantId: detail?.id ?? widget.state.tenantId ?? '',
      hostelId: widget.state.hostelId ?? '',
      bookingId: bookingId,
      securityDeposit: detail?.stay?.deposit ?? widget.state.deposit ?? 0.0,
      onCheckoutConfirmed: ({
        required double securityDeposit,
        required double pendingRent,
        required double utilityDue,
        required double finalSettlement,
      }) {
        context.read<BookingsCubit>().checkoutBooking(
          bookingId,
          securityDeposit: securityDeposit,
          pendingRent: pendingRent,
          utilityDue: utilityDue,
          finalSettlement: finalSettlement,
        );
      },
    );
  }

  void _showCancelConfirmation(BuildContext context, TenantDetailEntity? detail) {
    final name = detail?.name ?? widget.state.tenantName ?? 'Tenant';
    final bookingId = widget.state.tenantId ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(StringUtils.translate('reject_booking_title', context: context)),
        content: Text(
          StringUtils.translate(
            'reject_booking_confirm',
            context: context,
            namedArgs: {'name': name},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(StringUtils.translate('cancel', context: context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingsCubit>().cancelBooking(bookingId);
            },
            child: Text(
              StringUtils.translate('reject', context: context),
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRoomSelection(BuildContext context, TenantDetailEntity? detail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BookingsCubit>(),
          child: RoomSelectionPage(
            bookingId: detail?.stay?.bookingId ?? widget.state.tenantId ?? '',
            hostelId: widget.state.hostelId ?? '',
            tenantName: detail?.name ?? widget.state.tenantName ?? 'Tenant',
            bookedSharingType: detail?.stay?.sharingType ?? widget.state.sharingType,
            bookedRoomType: detail?.stay?.acType ?? widget.state.roomType,
          ),
        ),
      ),
    );
  }

  void _showActiveActionsBottomSheet(BuildContext context, TenantDetailEntity? detail) {
    final avatarUrl = ApiConstants.getImageUrl(detail?.avatar ?? widget.state.profileImage);
    final name = detail?.name ?? widget.state.tenantName ?? 'Tenant';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'T';
    final isBooked = _currentStatus == BedStatus.booked;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 26.r,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.05),
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? Text(
                              initials,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryBlue,
                              ),
                            )
                          : null,
                    ),
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
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          isBooked
                              ? '${detail?.mobile ?? widget.state.tenantName ?? ""}  •  Booking Request'
                              : '${detail?.mobile ?? ""}  •  ${detail?.stay?.roomTypename ?? widget.state.roomNumber ?? "Active Resident"}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              const Divider(height: 1),
              SizedBox(height: 12.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isBooked ? Colors.green.shade50 : AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    isBooked ? Icons.add_task_rounded : Icons.bed_outlined,
                    color: isBooked ? Colors.green.shade700 : AppColors.primaryBlue,
                  ),
                ),
                title: Text(
                  StringUtils.translate(isBooked ? 'assign_room' : 'change_room', context: context),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isBooked ? Colors.green.shade700 : AppColors.darkText,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (isBooked) {
                    _openCheckInDialog(context);
                  } else {
                    _navigateToRoomSelection(context, detail);
                  }
                },
              ),
              SizedBox(height: 8.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isBooked ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: isBooked ? AppColors.primaryBlue : Colors.green.shade700,
                  ),
                ),
                title: const Text(
                  'View Guest Profile',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  TenantDetailsSheet.show(
                    context,
                    name: name,
                    imageUrl: ApiConstants.getImageUrl(detail?.avatar ?? widget.state.profileImage),
                    room: detail?.stay?.roomTypename ?? widget.state.roomNumber ?? 'N/A',
                    tenantId: detail?.id ?? widget.state.tenantId ?? '',
                    hostelId: widget.state.hostelId ?? '',
                  );
                },
              ),
              SizedBox(height: 8.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    isBooked ? Icons.close_rounded : Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                ),
                title: Text(
                  StringUtils.translate(isBooked ? 'reject' : 'checkout', context: context),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.redAccent),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (isBooked) {
                    _showCancelConfirmation(context, detail);
                  } else {
                    _confirmCheckout(context, detail);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openCheckInDialog(BuildContext context) {
    // We need a Booking object to use QrCheckInDialog.
    // However, BedDetailsSheet doesn't have one.
    // If it's a booked bed, we can try to search for the booking in the cubit's state or just open the scanner.
    // For now, let's just open the scanner as it's the primary check-in method in this sheet.
    _openScanner(context);
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

class _LiveTimeDateWidget extends StatefulWidget {
  @override
  State<_LiveTimeDateWidget> createState() => _LiveTimeDateWidgetState();
}

class _LiveTimeDateWidgetState extends State<_LiveTimeDateWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = _now.hour > 12 ? _now.hour - 12 : (_now.hour == 0 ? 12 : _now.hour);
    final amPm = _now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '${hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')} $amPm';
    final months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    final dateStr = '${_now.day.toString().padLeft(2, '0')} ${months[_now.month - 1]}';

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
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1B2838),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Container(width: 1, height: 36.h, color: const Color(0xFFE2E8F0)),
        SizedBox(width: 20.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'DATE',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16.sp, color: const Color(0xFF1B2838)),
                SizedBox(width: 6.w),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B2838),
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
