import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'map_picker_screen.dart';

class GeofenceIntroScreen extends StatefulWidget {
  final ll.LatLng? initialLocation;

  const GeofenceIntroScreen({super.key, this.initialLocation});

  @override
  State<GeofenceIntroScreen> createState() => _GeofenceIntroScreenState();
}

class _GeofenceIntroScreenState extends State<GeofenceIntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'geofencing_title'.tr(),
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.darkText, size: 22),
            onPressed: () => _showExplanationDialog(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 12.h),
                      _buildIllustrationCard(),
                      SizedBox(height: 36.h),
                      Text(
                        'geofence_welcome_title'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'geofence_welcome_subtitle'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustrationCard() {
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate premium card background
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: MapGridPainter(),
              ),
            ),
            // Geofence Radius visual (150m boundary)
            Center(
              child: Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Outer radar pulse
            Center(
              child: Container(
                width: 200.r,
                height: 200.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Central property location pin
            Center(
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ),
            ),
            // Walking tenant representing crossing the boundary
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - 75.r,
              top: 80.h,
              child: Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF), // Premium blue
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BouncingWrapper(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapPickerScreen(
                  initialLocation: widget.initialLocation,
                ),
              ),
            );
            if (!mounted) return;
            if (result != null) {
              Navigator.pop(context, result);
            }
          },
          child: Container(
            width: double.infinity,
            height: 54.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'enable_geofencing'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showExplanationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('geofence_help_title'.tr()),
        content: Text('geofence_help_content'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('btn_ok'.tr()),
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width, size.height * 0.6)
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width * 0.7, size.height)
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width, size.height * 0.2)
      ..moveTo(size.width * 0.15, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.85, size.height * 0.1);

    canvas.drawPath(path, paint);

    final polyPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;

    final polyPath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.15)
      ..lineTo(size.width * 0.22, size.height * 0.1)
      ..lineTo(size.width * 0.26, size.height * 0.24)
      ..lineTo(size.width * 0.12, size.height * 0.28)
      ..close();

    final polyPath2 = Path()
      ..moveTo(size.width * 0.72, size.height * 0.7)
      ..lineTo(size.width * 0.88, size.height * 0.65)
      ..lineTo(size.width * 0.92, size.height * 0.82)
      ..lineTo(size.width * 0.78, size.height * 0.87)
      ..close();

    canvas.drawPath(polyPath, polyPaint);
    canvas.drawPath(polyPath2, polyPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
