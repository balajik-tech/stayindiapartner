import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import '../widgets/auth_widgets.dart';
import 'registration_documents_page.dart';
import '../cubit/document_cubit.dart';

class RegistrationHostelImagesPage extends StatefulWidget {
  final String hostelId;

  const RegistrationHostelImagesPage({super.key, required this.hostelId});

  @override
  State<RegistrationHostelImagesPage> createState() => _RegistrationHostelImagesPageState();
}

class _RegistrationHostelImagesPageState extends State<RegistrationHostelImagesPage> with SingleTickerProviderStateMixin {
  final List<File> _selectedImages = [];
  final int _maxImages = 10;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 images allowed')),
      );
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      HapticFeedback.mediumImpact();
      final newFiles = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      setState(() {
        int remaining = _maxImages - _selectedImages.length;
        _selectedImages.addAll(newFiles.take(remaining));
      });

      if (newFiles.length > (_maxImages - (_selectedImages.length - newFiles.length))) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Only $_maxImages images can be uploaded. Some were skipped.')),
          );
        }
      }
    }
  }

  void _removeImage(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _handleContinue() {
    if (_selectedImages.isEmpty) {
      _navigateToDocuments();
      return;
    }

    context.read<HostelCubit>().uploadHostelImages(
      id: widget.hostelId,
      filePaths: _selectedImages.map((f) => f.path).toList(),
    );
  }

  void _navigateToDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<DocumentCubit>(),
          child: RegistrationDocumentsPage(hostelId: widget.hostelId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HostelCubit, HostelState>(
      listener: (context, state) {
        if (state is HostelOperationSuccess && state.message.contains('Images uploaded successfully')) {
          _navigateToDocuments();
        } else if (state is HostelError) {
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(context),
        body: SafeArea(
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
                        const AuthStepProgress(
                          currentStep: 3,
                          totalSteps: 3,
                          stepLabels: ['Personal', 'Property', 'Setup'],
                        ),
                        SizedBox(height: 48.h),
                        _buildProgressHeader(),
                        SizedBox(height: 48.h),
                        _selectedImages.isEmpty ? _buildEmptyState() : _buildImageGrid(),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildStickyButton(),
      ),
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

  Widget _buildProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Photos',
          style: GoogleFonts.outfit(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Showcase your property with clear photos. High-quality images attract more tenants.',
          style: GoogleFonts.outfit(
            fontSize: 15.sp,
            color: AppColors.greyText.withValues(alpha: 0.8),
            height: 1.4,
          ),
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
      child: BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          final isLoading = state is HostelLoading;
          return AuthPrimaryButton(
            label: _selectedImages.isEmpty ? 'Skip for Now' : 'Upload & Continue',
            isLoading: isLoading,
            onPressed: _handleContinue,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return BouncingWrapper(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 48.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_a_photo_rounded, size: 40.sp, color: AppColors.primaryBlue),
            ),
            SizedBox(height: 24.h),
            Text(
              'Add Property Photos',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select up to 10 high-quality images',
              style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1,
          ),
          itemCount: _selectedImages.length + (_selectedImages.length < _maxImages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return _buildAddMoreButton();
              }

              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.file(
                          _selectedImages[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: BouncingWrapper(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, size: 14.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '${_selectedImages.length} / $_maxImages Selected',
            style: TextStyle(color: AppColors.darkText, fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return BouncingWrapper(
      onTap: _pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded, color: AppColors.primaryBlue, size: 28.sp),
            SizedBox(height: 4.h),
            Text('Add', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }
}
