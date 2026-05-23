import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';

class SocialPostCard extends StatefulWidget {
  final SocialPostEntity post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final Function(int optionIndex) onVote;
  final String currentUserId;
  final VoidCallback? onDelete;
  final Function({
    required String content,
    String? imagePath,
    bool? removeImage,
    List<String>? pollOptions,
    bool? removePoll,
  })? onEdit;
  final VoidCallback? onShare;
  final VoidCallback? onRepost;

  const SocialPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onVote,
    this.onDelete,
    this.onEdit,
    this.onShare,
    this.onRepost,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard> {
  bool _isEditing = false;
  late TextEditingController _contentController;
  String? _selectedImagePath;
  bool _removeImage = false;
  final List<TextEditingController> _pollOptionControllers = [];
  bool _removePoll = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _initPollControllers();
  }

  void _initPollControllers() {
    _pollOptionControllers.clear();
    final poll = widget.post.poll;
    if (poll != null) {
      final options = poll['options'] as List? ?? [];
      for (var opt in options) {
        _pollOptionControllers.add(
          TextEditingController(text: opt['text']?.toString() ?? ''),
        );
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    for (var c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedImagePath = file.path;
        _removeImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return _buildInlineEditor(context);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildContent(),
          if (widget.post.imageUrl != null) _buildImage(),
          if (widget.post.poll != null) _buildPoll(),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildInlineEditor(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Edit Post',
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const Spacer(),
              if (widget.post.poll != null && !_removePoll)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _removePoll = true;
                    });
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16),
                  label: const Text(
                    'Remove Poll',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              if (_removePoll)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _removePoll = false;
                    });
                  },
                  icon: const Icon(Icons.restore_rounded, color: AppColors.primaryBlue, size: 16),
                  label: const Text(
                    'Restore Poll',
                    style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _contentController,
              maxLines: 4,
              maxLength: 200,
              style: GoogleFonts.dmSans(
                fontSize: 15.sp,
                color: AppColors.darkText,
              ),
              decoration: const InputDecoration(
                hintText: 'Edit your thoughts...',
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Image Edit section
          if (widget.post.imageUrl != null && !_removeImage && _selectedImagePath == null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: ApiConstants.getImageUrl(widget.post.imageUrl!) ?? '',
                    width: double.infinity,
                    height: 150.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _removeImage = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),

          if (_selectedImagePath != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(_selectedImagePath!),
                    width: double.infinity,
                    height: 150.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedImagePath = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),

          if ((widget.post.imageUrl == null || _removeImage) && _selectedImagePath == null)
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
              label: const Text('Add Image'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

          // Poll Edit section
          if (widget.post.poll != null && !_removePoll) ...[
            SizedBox(height: 16.h),
            Text(
              'Poll Options',
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            ...List.generate(_pollOptionControllers.length, (index) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                height: 42.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _pollOptionControllers[index],
                  style: GoogleFonts.dmSans(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Option ${index + 1}',
                    border: InputBorder.none,
                  ),
                ),
              );
            }),
          ],

          if (_removePoll) ...[
            SizedBox(height: 8.h),
            Text(
              'Poll will be removed on save',
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _contentController.text = widget.post.content;
                    _selectedImagePath = null;
                    _removeImage = false;
                    _removePoll = false;
                    _initPollControllers();
                  });
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () {
                  final newContent = _contentController.text.trim();
                  if (newContent.isEmpty &&
                      _selectedImagePath == null &&
                      (widget.post.imageUrl == null || _removeImage) &&
                      (widget.post.poll == null || _removePoll)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post content cannot be completely empty'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  if (widget.onEdit != null) {
                    final validPollOptions = _pollOptionControllers
                        .map((c) => c.text.trim())
                        .where((t) => t.isNotEmpty)
                        .toList();

                    widget.onEdit!(
                      content: newContent,
                      imagePath: _selectedImagePath,
                      removeImage: _removeImage,
                      pollOptions: _removePoll ? null : validPollOptions,
                      removePoll: _removePoll,
                    );
                  }

                  setState(() {
                    _isEditing = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saving post changes...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      leading: CircleAvatar(
        radius: 20.r,
        backgroundImage: widget.post.userAvatar != null
            ? CachedNetworkImageProvider(
                ApiConstants.getImageUrl(widget.post.userAvatar!)!,
              )
            : null,
        child: widget.post.userAvatar == null
            ? Icon(Icons.person, size: 24.sp, color: Colors.grey[400])
            : null,
      ),
      title: Row(
        children: [
          Text(
            widget.post.userName,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(width: 4.w),
          if (widget.post.type == 'UPDATE')
            Icon(
              Icons.verified_rounded,
              size: 14.sp,
              color: AppColors.primaryBlue,
            ),
        ],
      ),
      subtitle: Text(
        _formatDateTime(widget.post.createdAt),
        style: GoogleFonts.dmSans(
          fontSize: 12.sp,
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: (widget.post.userId == widget.currentUserId && (widget.onEdit != null || widget.onDelete != null))
          ? PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz_rounded, color: Colors.grey[400]),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onSelected: (value) {
                if (value == 'edit' && widget.onEdit != null) {
                  setState(() {
                    _isEditing = true;
                    _selectedImagePath = null;
                    _removeImage = false;
                    _removePoll = false;
                    _initPollControllers();
                  });
                } else if (value == 'delete' && widget.onDelete != null) {
                  _showDeleteConfirmDialog(context, widget.onDelete!);
                }
              },
              itemBuilder: (context) => [
                if (widget.onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 18.sp, color: AppColors.darkText),
                        SizedBox(width: 8.w),
                        Text('Edit', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                if (widget.onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 18.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        Text('Delete', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            )
          : null,
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        widget.post.content,
        style: GoogleFonts.dmSans(
          fontSize: 15.sp,
          color: AppColors.darkText,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: ApiConstants.getImageUrl(widget.post.imageUrl!) ?? '',
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200.h,
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildPoll() {
    final options = widget.post.poll?['options'] as List? ?? [];
    final int totalVotes = options.fold(
      0,
      (sum, opt) => sum + (opt['votes'] as int? ?? 0),
    );
    final bool hasVoted = widget.post.userVote != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: List.generate(options.length, (index) {
          final opt = options[index];
          final String optionText = opt['text'] ?? '';
          final int votes = opt['votes'] as int? ?? 0;
          final double percentage = totalVotes > 0 ? (votes / totalVotes) : 0.0;
          final bool isSelected = widget.post.userVote == index;

          return GestureDetector(
            onTap: () => widget.onVote(index),
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.grey.shade200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Stack(
                children: [
                  if (hasVoted)
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              (isSelected
                                      ? AppColors.primaryBlue
                                      : Colors.grey.shade100)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            optionText,
                            style: GoogleFonts.dmSans(
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.darkText,
                            ),
                          ),
                        ),
                        if (hasVoted)
                          Text(
                            '${(percentage * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.dmSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionBarItem(
            icon: widget.post.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            label: _formatCount(widget.post.likesCount),
            isActive: widget.post.isLiked,
            activeColor: Colors.redAccent,
            onTap: widget.onLike,
          ),
          _ActionBarItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: _formatCount(widget.post.commentsCount),
            onTap: widget.onComment,
          ),
          _ActionBarItem(
            icon: Icons.repeat_rounded,
            label: 'Repost',
            onTap: widget.onRepost ?? () {},
          ),
          _ActionBarItem(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: widget.onShare ?? () {},
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return widget.post.likesCount.toString();
  }

  void _showDeleteConfirmDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Delete Post?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            color: AppColors.greyText,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.greyText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ActionBarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? AppColors.primaryBlue)
        : Colors.grey[600];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
