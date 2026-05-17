import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

class SocialPostComposer extends StatefulWidget {
  final String userAvatar;
  final Function(String content) onPost;
  final VoidCallback onPickImage;
  final VoidCallback onCreatePoll;
  final VoidCallback? onAddLocation;
  final File? selectedImage;
  final List<String> pollOptions;
  final VoidCallback onRemoveImage;
  final Function(int index) onRemovePollOption;
  final Function(int index, String value) onPollOptionChanged;
  final VoidCallback onAddPollOption;
  final Map<String, dynamic>? selectedLocation;
  final VoidCallback? onRemoveLocation;

  const SocialPostComposer({
    super.key,
    required this.userAvatar,
    required this.onPost,
    required this.onPickImage,
    required this.onCreatePoll,
    this.onAddLocation,
    this.selectedImage,
    required this.pollOptions,
    required this.onRemoveImage,
    required this.onRemovePollOption,
    required this.onPollOptionChanged,
    required this.onAddPollOption,
    this.selectedLocation,
    this.onRemoveLocation,
  });

  @override
  State<SocialPostComposer> createState() => _SocialPostComposerState();
}

class _SocialPostComposerState extends State<SocialPostComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canPost =>
      _controller.text.trim().isNotEmpty || 
      widget.selectedImage != null || 
      widget.pollOptions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ApiConstants.getImageUrl(widget.userAvatar);

    return Container(
      margin: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Icon(Icons.person, size: 24.sp, color: Colors.grey[400])
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    maxLength: 200,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      color: AppColors.darkText,
                    ),
                    decoration: InputDecoration(
                      hintText: "Share your thoughts...",
                      hintStyle: GoogleFonts.dmSans(
                        color: Colors.grey[400],
                        fontSize: 15.sp,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
                      ),
                      counterStyle: GoogleFonts.dmSans(
                        fontSize: 11.sp,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.selectedImage != null) _buildImagePreview(),
          if (widget.pollOptions.isNotEmpty) _buildPollPreview(),
          if (widget.selectedLocation != null) _buildLocationPreview(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: Row(
              children: [
                _buildToolButton(Icons.image_outlined, widget.onPickImage),
                _buildToolButton(Icons.poll_outlined, widget.onCreatePoll),
                const Spacer(),
                _buildPostButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22.sp, color: AppColors.primaryBlue),
      constraints: const BoxConstraints(),
      padding: EdgeInsets.only(right: 16.w),
    );
  }

  Widget _buildPostButton() {
    return BouncingWrapper(
      onTap: _canPost ? () {
        widget.onPost(_controller.text);
        _controller.clear();
      } : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _canPost ? AppColors.primaryBlue : AppColors.primaryBlue.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'Post',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              widget.selectedImage!,
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.cover,
              cacheWidth: 600,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: widget.onRemoveImage,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 18.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollPreview() {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          ...List.generate(widget.pollOptions.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => widget.onPollOptionChanged(index, val),
                      decoration: InputDecoration(
                        hintText: 'Option ${index + 1}',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (widget.pollOptions.length > 2)
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red[300], size: 20.sp),
                      onPressed: () => widget.onRemovePollOption(index),
                    ),
                ],
              ),
            );
          }),
          if (widget.pollOptions.length < 4)
            TextButton.icon(
              onPressed: widget.onAddPollOption,
              icon: Icon(Icons.add_circle_outline_rounded, size: 18.sp),
              label: Text('Add Option', style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationPreview() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_rounded, size: 14.sp, color: AppColors.primaryBlue),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                widget.selectedLocation!['address'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(fontSize: 12.sp, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: widget.onRemoveLocation,
              child: Icon(Icons.close, size: 14.sp, color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}
