import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';


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

  // Matches summary card solid colors exactly
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

  // Matches textColor from BedCard for perfect contrast over _statusBgColor
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

    return Container(
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
      ),
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
                  "BED ${state.bedNumber}".toUpperCase(),
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: -0.5),
                ),
                Text(
                  state.tenantName ?? "AVAILABLE",
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
              "ACCESS PASS",
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
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
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 1.5),
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
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
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
                    "SCAN TO CHECK-IN",
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: statusTextColor, letterSpacing: 1.2),
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
                  _buildGenerateNewBtn(),
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

  Widget _buildGenerateNewBtn() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.refresh_rounded, size: 14.sp, color: const Color(0xFF94A3B8)),
          SizedBox(width: 6.w),
          Text("GENERATE NEW", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionPillItem("RENT", "₹${state.rent?.toInt() ?? 0}", _statusTextColor, _statusBgColor),
        _buildActionPillIcon(Icons.qr_code_scanner_rounded, "SCAN", iconColor: const Color(0xFFFF8600), onTap: () => _openScanner(context)),
        _buildActionPillIcon(Icons.qr_code_rounded, "QR", iconColor: const Color(0xFF2563EB)),
      ],
    );
  }

  void _openScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ScannerSheet(),
    );
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
            Text("DONE", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }
}

// ── Scanner Sheet ────────────────────────────────────────────────────────────

class _ScannerSheet extends StatefulWidget {
  const _ScannerSheet();
  @override
  State<_ScannerSheet> createState() => _ScannerSheetState();
}

class _ScannerSheetState extends State<_ScannerSheet> {
  final MobileScannerController _controller = MobileScannerController();
  String? _scannedValue;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 50.w, height: 4.h,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(height: 20.h),
          Text('SCAN QR CODE',
              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          SizedBox(height: 20.h),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: _scannedValue != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: const Color(0xFF87CEEB), size: 64.sp),
                          SizedBox(height: 16.h),
                          Text('Scanned!', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Text(_scannedValue!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
                          ),
                        ],
                      ),
                    )
                  : MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        final barcode = capture.barcodes.firstOrNull;
                        if (barcode?.rawValue != null && mounted) {
                          setState(() => _scannedValue = barcode!.rawValue);
                        }
                      },
                    ),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _scannedValue),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87CEEB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text(
                  _scannedValue != null ? 'CONFIRM' : 'CANCEL',
                  style: TextStyle(color: const Color(0xFF0F172A), fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
