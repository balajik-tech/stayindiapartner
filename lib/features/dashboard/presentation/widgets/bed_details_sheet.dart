import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stayindia_owner/features/bookings/widgets/qr_scanner_screen.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/injection_container.dart' as di;

enum BedStatus { free, occupied, notice, away }

class BedState {
  final BedStatus status;
  final String bedNumber;
  final String? tenantName;
  final String? profileImage;
  final String? joiningDate;
  final String? vacatingDate;
  final String? tenantId;
  final String? hostelId;
  final String? roomId;
  final String? roomNumber;
  final double? rent;
  final double? dailyRent;
  final double? maintenance;
  final List<String>? amenities;
  final String? hostelName;
  final String? hostelAddress;

  BedState({
    required this.status,
    required this.bedNumber,
    this.tenantName,
    this.profileImage,
    this.joiningDate,
    this.vacatingDate,
    this.tenantId,
    this.hostelId,
    this.roomId,
    this.roomNumber,
    this.rent,
    this.dailyRent,
    this.maintenance,
    this.amenities,
    this.hostelName,
    this.hostelAddress,
  });
}

class BedDetailsSheet extends StatelessWidget {
  final BedState state;

  const BedDetailsSheet({super.key, required this.state});

  static void show(BuildContext context, BedState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BedDetailsSheet(state: state),
    );
  }

  void _openScanner(BuildContext context) async {
    final String? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      _showConfirmationDialog(context, result);
    }
  }

  void _showConfirmationDialog(BuildContext context, String tenantData) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "Confirm Assignment",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Assign this bed to the scanned user?", style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 16.h),
            _infoRow(Icons.bed_rounded, "Bed ${state.bedNumber}"),
            _infoRow(Icons.meeting_room_rounded, "Room ${state.roomNumber ?? 'N/A'}"),
            _infoRow(Icons.qr_code_2_rounded, "ID/Phone: $tenantData"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _assignBed(context, tenantData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text("CONFIRM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey),
          SizedBox(width: 8.w),
          Text(text, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _assignBed(BuildContext context, String tenantPhone) async {
    if (state.hostelId == null || state.roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Missing property data"), backgroundColor: Colors.red),
      );
      return;
    }

    final addTenantCubit = di.sl<AddTenantCubit>();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Assigning bed..."), duration: Duration(seconds: 1)),
    );

    try {
      await addTenantCubit.submit(
        hostel: Hostel(
          id: state.hostelId!,
          name: state.hostelName ?? "",
          address: state.hostelAddress ?? "",
          floors: 0,
          hostelType: "Co-Living",
        ),
        room: RoomDetail(
          id: state.roomId!,
          hostelId: state.hostelId!,
          roomTypename: state.roomNumber ?? "",
          floor: 0,
          sharingType: "0",
          roomType: "0",
          rent: state.rent ?? 0,
          deposit: 0,
          maintenance: 0,
          isActive: true,
          isMaster: false,
          capacity: 1,
        ),
        bed: state.bedNumber,
        phone: tenantPhone,
        rent: state.rent ?? 0,
        startDate: DateTime.now(),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bed assigned successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Close the sheet
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to assign: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
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
            _buildBrandingSection(),
            _buildQRSection(context),
            SizedBox(height: 32.h),
            _buildActionRow(context),
            SizedBox(height: 32.h),
            _buildDoneButton(context),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPassHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.apartment_rounded, color: const Color(0xFFF97316), size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BED ${state.bedNumber}".toUpperCase(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  state.tenantName ?? "AVAILABLE",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              "ACCESS PASS",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          Text(
            (state.hostelName ?? "STAY INDIA").toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded, color: const Color(0xFFCBD5E1), size: 14.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  state.hostelAddress ?? "BANGALORE, INDIA",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
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
    Color statusColor;
    bool isFree = state.status == BedStatus.free;

    switch (state.status) {
      case BedStatus.free:
        statusColor = const Color(0xFF22C55E);
        break;
      case BedStatus.occupied:
        statusColor = const Color(0xFFF97316);
        break;
      case BedStatus.notice:
        statusColor = const Color(0xFFEAB308);
        break;
      case BedStatus.away:
        statusColor = const Color(0xFFF59E0B);
        break;
    }

    return GestureDetector(
      onTap: isFree ? () => _openScanner(context) : null,
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32.r),
            border: Border.all(color: statusColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
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
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: const Color(0xFF22C55E),
                          size: 75.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      "SCAN TO CHECK-IN",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF22C55E),
                        letterSpacing: 1.2,
                      ),
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
                    SizedBox(height: 8.h),
                  ],
                ),
              // Subtle corner accents
              ..._buildCornerAccents(statusColor),
            ],
          ),
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
    bool isFree = state.status == BedStatus.free;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionPillItem(
          "RENT",
          "₹${state.rent?.toInt() ?? 0}",
          const Color(0xFF16A34A),
          const Color(0xFFF0FDF4),
        ),
        GestureDetector(
          onTap: isFree ? () => _openScanner(context) : null,
          child: _buildActionPillIcon(Icons.qr_code_scanner_rounded, "SCAN", iconColor: const Color(0xFFF97316)),
        ),
        _buildActionPillIcon(Icons.qr_code_rounded, "QR", iconColor: const Color(0xFF2563EB)),
      ],
    );
  }

  Widget _buildActionPillItem(String label, String value, Color color, Color bgColor) {
    return Container(
      width: 80.w,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPillIcon(IconData icon, String label, {Color? iconColor}) {
    return Container(
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
          Text(
            label,
            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFF475569)),
          ),
        ],
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
            Icon(Icons.check_circle_outline_rounded, color: const Color(0xFFF97316), size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              "DONE",
              style: TextStyle(
                fontSize: 16.sp,
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
