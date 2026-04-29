import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../cubit/document_cubit.dart';
import '../cubit/document_state.dart';
import '../widgets/auth_widgets.dart';

class RegistrationDocumentsPage extends StatefulWidget {
  final bool isFromProfile;
  final String? hostelId;
  
  const RegistrationDocumentsPage({
    super.key,
    this.isFromProfile = false,
    this.hostelId,
  });

  @override
  State<RegistrationDocumentsPage> createState() => _RegistrationDocumentsPageState();
}

class _RegistrationDocumentsPageState extends State<RegistrationDocumentsPage> with SingleTickerProviderStateMixin {
  final _licenseNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  String? _selectedLicenseType;
  String? _filePath;
  String? _fileName;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<HostelCubit>().getHostels();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _expiryDateController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  void _onComplete() {
    final hostelState = context.read<HostelCubit>().state;
    final String? finalHostelId = widget.hostelId ??
        (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty
            ? hostelState.hostels.first.id
            : null);

    if (finalHostelId == null) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hostel found. Please create a hostel first.', style: GoogleFonts.outfit()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedLicenseType == null || _filePath == null || _licenseNumberController.text.isEmpty) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields and upload the document', style: GoogleFonts.outfit()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<DocumentCubit>().uploadDocument(
          hostelId: finalHostelId,
          licenseType: _selectedLicenseType!,
          licenseNumber: _licenseNumberController.text,
          expiryDate: _expiryDateController.text.isNotEmpty ? _expiryDateController.text : null,
          filePath: _filePath!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DocumentCubit, DocumentState>(
            listener: (context, state) {
              if (state is DocumentOperationSuccess) {
                HapticFeedback.vibrate();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.isFromProfile ? 'Document uploaded successfully' : 'Verification submitted successfully!',
                      style: GoogleFonts.outfit(),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                );
                if (widget.isFromProfile) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigationPage()),
                    (route) => false,
                  );
                }
              } else if (state is DocumentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: GoogleFonts.outfit()),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                );
              }
            },
          ),
        ],
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!widget.isFromProfile)
                          const AuthStepProgress(
                            currentStep: 3,
                            totalSteps: 3,
                            stepLabels: ['Personal', 'Property', 'Verification'],
                          ),
                        SizedBox(height: 48.h),
                        _buildHeader(),
                        SizedBox(height: 48.h),
                        _buildFormSection(),
                        SizedBox(height: 32.h),
                        _buildUploadSection(),
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyButton(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      leading: BouncingWrapper(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 16),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_rounded, size: 14.sp, color: Colors.green.shade700),
              SizedBox(width: 6.w),
              Text(
                'Secure Verification',
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Verify your property',
          style: GoogleFonts.outfit(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'This helps us ensure safety and compliance for all tenants.',
          style: GoogleFonts.outfit(
            fontSize: 15.sp,
            color: AppColors.greyText.withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        AuthDropdown<String?>(
          label: 'License Type *',
          value: _selectedLicenseType,
          items: const [
            DropdownMenuItem(value: 'fssai', child: Text('FSSAI License')),
            DropdownMenuItem(value: 'trade_license', child: Text('Trade License')),
            DropdownMenuItem(value: 'fire_safety', child: Text('Fire Safety Certificate')),
            DropdownMenuItem(value: 'police_noc', child: Text('Police NOC')),
          ],
          onChanged: (val) => setState(() => _selectedLicenseType = val),
        ),
        SizedBox(height: 24.h),
        AuthTextField(
          label: 'License Number *',
          controller: _licenseNumberController,
          hintText: 'e.g. TL-2024-BLR-00',
        ),
        SizedBox(height: 24.h),
        AuthDatePicker(
          label: 'Expiry Date *',
          controller: _expiryDateController,
          hintText: 'Select Date',
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 365)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2035),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primaryBlue,
                      onPrimary: Colors.white,
                      onSurface: AppColors.darkText,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              final month = pickedDate.month.toString().padLeft(2, '0');
              final day = pickedDate.day.toString().padLeft(2, '0');
              setState(() {
                _expiryDateController.text = "${pickedDate.year}-$month-$day";
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    final hasFile = _fileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Document *',
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: 12.h),
        BouncingWrapper(
          onTap: _pickDocument,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
            decoration: BoxDecoration(
              color: hasFile ? AppColors.primaryBlue.withValues(alpha: 0.02) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: hasFile ? AppColors.primaryBlue : Colors.grey.shade300,
                width: 1.5,
                style: hasFile ? BorderStyle.solid : BorderStyle.solid, 
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: hasFile ? AppColors.primaryBlue : AppColors.primaryBlue.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasFile ? Icons.check_circle_outline_rounded : Icons.cloud_upload_outlined,
                    color: hasFile ? Colors.white : AppColors.primaryBlue,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  hasFile ? _fileName! : 'Select your document',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  hasFile ? 'Tap to change file' : 'PDF, JPG or PNG (Max 5MB)',
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: AppColors.greyText.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 14.sp, color: AppColors.greyText),
            SizedBox(width: 6.w),
            Text(
              'Your documents are securely encrypted',
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                color: AppColors.greyText.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStickyButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: BlocBuilder<DocumentCubit, DocumentState>(
        builder: (context, state) {
          final isLoading = state is DocumentLoading;
          return AuthPrimaryButton(
            label: widget.isFromProfile ? 'Upload Document' : 'Submit for Verification',
            isLoading: isLoading,
            onPressed: _onComplete,
          );
        },
      ),
    );
  }
}
