import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

class JoinAssociationSheet extends StatefulWidget {
  final CommunityThemeEntity theme;

  const JoinAssociationSheet({super.key, required this.theme});

  @override
  State<JoinAssociationSheet> createState() => _JoinAssociationSheetState();
}

class _JoinAssociationSheetState extends State<JoinAssociationSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hostelController = TextEditingController();
  String? _selectedZone = 'Chennai';

  final List<String> _zones = [
    'Chennai',
    'Coimbatore',
    'Madurai',
    'Trichy',
    'Salem',
    'Tirunelveli',
    'Erode',
    'Vellore',
    'Thanjavur'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _hostelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.primaryColor.toColor();
    final accent = widget.theme.accentColor.toColor();
    final textSecondary = widget.theme.textSecondary.toColor();

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.home_outlined, color: accent, size: 26.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Join the association',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: primary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 18.sp, color: primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE2E8F0), thickness: 1),
            SizedBox(height: 24.h),
            _buildLabel('FULL NAME', textSecondary),
            _buildTextField(_nameController, 'Your name', accent, autofocus: true),
            SizedBox(height: 20.h),
            _buildLabel('MOBILE NUMBER', textSecondary),
            _buildTextField(_phoneController, '10-digit mobile', accent, keyboardType: TextInputType.phone),
            SizedBox(height: 20.h),
            _buildLabel('HOSTEL / PG NAME', textSecondary),
            _buildTextField(_hostelController, 'Your hostel or PG name', accent),
            SizedBox(height: 20.h),
            _buildLabel('DISTRICT / ZONE', textSecondary),
            _buildDropdown(accent),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle membership creation
                  Navigator.pop(context);
                },
                icon: Icon(Icons.check, color: primary, size: 20.sp),
                label: Text(
                  'Create membership',
                  style: GoogleFonts.inter(
                    color: primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 4,
                  shadowColor: accent.withValues(alpha: 0.3),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                'Your details are used only to register your membership with the association.',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: textSecondary.withValues(alpha: 0.5),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: color.withValues(alpha: 0.5),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color accent, {TextInputType keyboardType = TextInputType.text, bool autofocus = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofocus: autofocus,
      style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 15.sp, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(Color accent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedZone,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
          style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
          items: _zones.map((String zone) {
            return DropdownMenuItem<String>(
              value: zone,
              child: Text(zone),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedZone = newValue;
            });
          },
        ),
      ),
    );
  }
}
