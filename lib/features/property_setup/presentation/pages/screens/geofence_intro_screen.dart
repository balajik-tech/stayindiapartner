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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkText,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'geofencing_title'.tr(),
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.help_outline_rounded,
        //       color: AppColors.darkText,
        //       size: 22,
        //     ),
        //     onPressed: () => _showExplanationDialog(),
        //   ),
        // ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(
            height: 1,
            color: Colors.black.withValues(alpha: 0.05),
          ),
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
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2b2b2b),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Stay India Geofencing Automatically tracks tenant presence, '
                                  'automates in/out logs, and keeps ',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Color(0xFF2b2b2b),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: 'parents',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w800,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: ' informed in real-time when they cross the ',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Color(0xFF2b2b2b),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: '50',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w800,
                                height: 1.5,
                              ),
                            ),
                            TextSpan(
                              text: '-meter hostel Boundary',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Color(0xFF2b2b2b),
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
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
    // Map-style illustration matching the reference screenshot:
    // light beige map background, dashed green geofence boundary,
    // "YOUR HOSTEL" pin in the center, a walking figure with a
    // "50-M" distance badge, and a few surrounding POI pins.
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEFE7DC),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            // Faint map roads / park blocks
            Positioned.fill(child: CustomPaint(painter: MapGridPainter())),

            // Dashed geofence boundary circle with translucent fill
            Center(
              child: CustomPaint(
                size: Size(190.r, 190.r),
                painter: DashedCirclePainter(
                  color: const Color(0xFF2E7D32),
                  fillColor: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                ),
              ),
            ),

            // Connecting line from hostel pin to the walking figure
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - 44.r,
              top: 112.h,
              child: Container(width: 55.r, height: 1.5, color: const Color(0xFF2E7D32)),
            ),

            // "50-M" distance badge on the connecting line
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - 12.r,
              top: 104.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '50-M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // Walking figure (tenant crossing the boundary)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5 + 8.r,
              top: 96.h,
              child: const Icon(
                Icons.directions_walk_rounded,
                color: Color(0xFF1E1E2C),
                size: 22,
              ),
            ),

            // Hostel pin + "YOUR HOSTEL" label in the center
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.hotel_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'YOUR HOSTEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Surrounding POI pins for map realism
            Positioned(
              left: 22.w,
              top: 18.h,
              child: _buildPoiPin(
                icon: Icons.location_on_rounded,
                color: AppColors.accentOrange,
                label: 'Third Wave\nCoffee',
              ),
            ),
            Positioned(
              left: 16.w,
              bottom: 40.h,
              child: _buildPoiPin(
                icon: Icons.location_on_rounded,
                color: const Color(0xFF2F6FED),
                label: 'Axis Bank',
              ),
            ),
            Positioned(
              right: 20.w,
              top: 70.h,
              child: _buildPoiPin(
                icon: Icons.location_on_rounded,
                color: const Color(0xFF2F6FED),
                label: 'St. Francis\nHigh School',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoiPin({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(height: 2.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 7.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4B4B4B),
            height: 1.2,
          ),
        ),
      ],
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
                builder: (context) =>
                    MapPickerScreen(initialLocation: widget.initialLocation),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
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

/// Faint background roads + park-like blocks to sell the "map" feel
/// behind the geofence illustration.
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final roadPath = Path()
      ..moveTo(-10, size.height * 0.18)
      ..lineTo(size.width * 0.4, size.height * 0.18)
      ..lineTo(size.width * 0.55, size.height * 0.55)
      ..lineTo(size.width + 10, size.height * 0.55)
      ..moveTo(size.width * 0.15, -10)
      ..lineTo(size.width * 0.15, size.height * 0.4)
      ..lineTo(size.width * 0.05, size.height * 0.65)
      ..lineTo(size.width * 0.05, size.height + 10)
      ..moveTo(size.width * 0.85, -10)
      ..lineTo(size.width * 0.85, size.height * 0.35)
      ..lineTo(size.width + 10, size.height * 0.35);

    canvas.drawPath(roadPath, roadPaint);

    final roadThinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final roadThinPath = Path()
      ..moveTo(-10, size.height * 0.82)
      ..lineTo(size.width * 0.6, size.height * 0.82)
      ..lineTo(size.width * 0.75, size.height + 10)
      ..moveTo(size.width * 0.9, size.height * 0.6)
      ..lineTo(size.width + 10, size.height * 0.75);

    canvas.drawPath(roadThinPath, roadThinPaint);

    // Building / block outlines
    final blockPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final blocks = [
      Rect.fromLTWH(size.width * 0.02, size.height * 0.02, size.width * 0.08, size.height * 0.1),
      Rect.fromLTWH(size.width * 0.32, size.height * 0.03, size.width * 0.06, size.height * 0.08),
      Rect.fromLTWH(size.width * 0.6, size.height * 0.05, size.width * 0.08, size.height * 0.1),
      Rect.fromLTWH(size.width * 0.02, size.height * 0.55, size.width * 0.07, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.65, size.width * 0.09, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.25, size.height * 0.7, size.width * 0.07, size.height * 0.1),
    ];
    for (final rect in blocks) {
      canvas.drawRect(rect, blockPaint);
    }

    // Park-like green patch (bottom right, echoing the reference image)
    final parkPaint = Paint()
      ..color = const Color(0xFFCFE3C9).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final parkPath = Path()
      ..moveTo(size.width * 0.78, size.height * 0.72)
      ..lineTo(size.width + 10, size.height * 0.6)
      ..lineTo(size.width + 10, size.height + 10)
      ..lineTo(size.width * 0.7, size.height + 10)
      ..close();

    canvas.drawPath(parkPath, parkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dashed circle with a soft fill, used for the geofence boundary.
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final Color fillColor;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    required this.color,
    required this.fillColor,
    this.dashWidth = 6,
    this.dashSpace = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, Paint()..color = fillColor);

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final circumference = 2 * 3.141592653589793 * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final dashAngle = (dashWidth / radius);
    final spaceAngle = (dashSpace / radius);

    double currentAngle = -3.141592653589793 / 2;
    for (int i = 0; i < dashCount; i++) {
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          dashAngle,
        );
      canvas.drawPath(path, strokePaint);
      currentAngle += dashAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
