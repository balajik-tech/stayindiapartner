import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/communities/domain/repositories/community_repository.dart';
import 'package:stayindia_owner/features/communities/domain/usecases/community_usecases.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

class CommunityDetailPage extends StatefulWidget {
  final String communityId;

  const CommunityDetailPage({super.key, required this.communityId});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  Map<String, dynamic>? _info;
  bool _isLoading = true;
  bool _isJoiningAction = false;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    if (widget.communityId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final repo = sl<CommunityRepository>();
      final data = await repo.getCommunityInfo(widget.communityId);
      if (mounted) {
        setState(() {
          _info = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_info == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: _buildErrorState(),
      );
    }

    final currentUserId = context.read<AuthCubit>().currentOwner?.id;
    final members = _info?['members'] as List? ?? [];
    final pendingMembers = _info?['pendingMembers'] as List? ?? [];
    final isMember = members.any((m) => m['_id']?.toString() == currentUserId);
    final isPending = pendingMembers.any((id) => id.toString() == currentUserId);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.greyText,
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(text: "news_tab".tr()),
                    Tab(text: "about_tab".tr()),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildNewsTab(isMember),
              _buildAboutTab(isMember, isPending),
            ],
          ),
        ),
        floatingActionButton: isMember ? _buildRedAlertButton() : null,
        bottomNavigationBar: !isMember ? _buildJoinBottomBar(isPending) : null,
      ),
    );
  }

  Widget _buildJoinBottomBar(bool isPending) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        12.h,
        24.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: isPending || _isJoiningAction ? null : _handleJoinCommunity,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPending ? Colors.grey[300] : AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 0,
          ),
          child: _isJoiningAction
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isPending ? "join_requested".tr() : "join_community".tr(),
                  style: GoogleFonts.outfit(
                    color: isPending ? Colors.grey[600] : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleJoinCommunity() async {
    setState(() => _isJoiningAction = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sl<JoinOwnerCommunityUseCase>().call(widget.communityId);
      messenger.showSnackBar(
        SnackBar(
          content: Text("join_request_success".tr()),
          backgroundColor: Colors.green,
        ),
      );
      await _loadInfo();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("${"join_request_failed".tr()}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isJoiningAction = false);
      }
    }
  }

  Widget _buildRedAlertButton() {
    return FloatingActionButton.extended(
      onPressed: _showRedAlertForm,
      backgroundColor: AppColors.sosRed,
      elevation: 4,
      icon: const Icon(Icons.emergency_share_rounded, color: Colors.white),
      label: Text(
        "red_alert".tr(),
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showRedAlertForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RedAlertForm(
        communityId: widget.communityId,
        associationId: _info?['association']?.toString() ?? widget.communityId,
      ),
    );
  }

  Widget _buildMiniTag(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNewsTab(bool isMember) {
    if (!isMember) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.primaryBlue,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "news_locked_title".tr(),
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                "news_locked_desc".tr(),
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: AppColors.greyText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.roomCardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMiniTag("announcement_tag".tr(), AppColors.primaryBlue),
            SizedBox(height: 8.h),
            Text(
              "Monthly Association Meeting",
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "We will discuss the new government regulations for PGs.",
              style: GoogleFonts.outfit(color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePendingAction(String requesterId, String action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sl<HandleJoinRequestUseCase>().call(
        communityId: widget.communityId,
        requesterId: requesterId,
        action: action,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            action == "ACCEPT"
                ? "Join request accepted successfully"
                : "Join request rejected successfully",
          ),
          backgroundColor: action == "ACCEPT" ? Colors.green : Colors.red,
        ),
      );
      _loadInfo();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Failed to handle request: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPendingRequestItem(Map<String, dynamic> request) {
    final requesterId = request['_id']?.toString() ?? '';
    if (requesterId.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.roomCardBorder.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: request['profileImage'] != null
                ? CachedNetworkImageProvider(request['profileImage'])
                : null,
            child: request['profileImage'] == null
                ? const Icon(Icons.person, color: AppColors.greyText)
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['name'] ?? 'Owner Requester',
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                if (request['email'] != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    request['email'],
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
                onPressed: () => _handlePendingAction(requesterId, "REJECT"),
              ),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
                onPressed: () => _handlePendingAction(requesterId, "ACCEPT"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(bool isMember, bool isPending) {
    final members = _info?['members'] as List? ?? [];
    final pendingMembers = _info?['pendingMembers'] as List? ?? [];
    final description = _info?['description'] ?? 'No description provided.';
    final rules = _info?['rules'];
    final currentUserId = context.read<AuthCubit>().currentOwner?.id;
    final isAdmin =
        (_info?['admins'] as List?)?.any(
          (id) => id.toString() == currentUserId,
        ) ??
        false;

    return ListView(
      padding: EdgeInsets.all(24.w),
      children: [
        if (isAdmin && isMember && pendingMembers.isNotEmpty) ...[
          Text(
            "Pending Join Requests",
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          ...pendingMembers.map((request) => _buildPendingRequestItem(request as Map<String, dynamic>)),
          SizedBox(height: 24.h),
        ],
        Text(
          "about_community".tr(),
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          description,
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            color: AppColors.greyText,
            height: 1.5,
          ),
        ),
        if (rules != null && rules.isNotEmpty && isMember) ...[
          SizedBox(height: 24.h),
          Text(
            "community_rules".tr(),
            style: GoogleFonts.outfit(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              rules,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: Colors.orange.shade900,
                height: 1.5,
              ),
            ),
          ),
        ],
        SizedBox(height: 32.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "members_count".tr(
                namedArgs: {'count': members.length.toString()},
              ),
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            if (isAdmin && isMember)
              Text(
                "admin_view".tr(),
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        if (isMember) ...[
          ...members.map((m) => _buildMemberItem(m, isAdmin, currentUserId)),
        ] else ...[
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.roomCardBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people_alt_outlined,
                  color: Colors.grey.shade400,
                  size: 40.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  "locked_members_title".tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "locked_members_desc".tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMemberItem(
    Map<String, dynamic> member,
    bool isRequesterAdmin,
    String? currentUserId,
  ) {
    final isOwner = member['isOwner'] ?? false;
    final isAdmin = member['isAdmin'] ?? false;
    final isMe = member['_id']?.toString() == currentUserId;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.roomCardBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundImage: member['profileImage'] != null
                ? CachedNetworkImageProvider(member['profileImage'])
                : null,
            child: member['profileImage'] == null
                ? const Icon(Icons.person)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member['name'] ?? 'User',
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    if (isMe) ...[
                      SizedBox(width: 4.w),
                      Text(
                        "(You)",
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ],
                ),
                if (isOwner || isAdmin)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: _buildMiniTag(
                      isOwner ? "community_owner_tag".tr() : "admin_tag".tr(),
                      isOwner ? Colors.orange : AppColors.primaryBlue,
                    ),
                  ),
              ],
            ),
          ),
          if (isRequesterAdmin && !isOwner && !isMe)
            IconButton(
              icon: const Icon(
                Icons.person_remove_rounded,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () => _confirmRemoveMember(member),
            ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "remove_member_title".tr(),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "remove_member_confirm".tr(
            namedArgs: {'name': member['name'] ?? 'User'},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await sl<CommunityRepository>().removeMember(
                  communityId: widget.communityId,
                  memberId: member['_id'].toString(),
                );
                _loadInfo();
                messenger.showSnackBar(
                  SnackBar(content: Text("member_removed_success".tr())),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text("Failed to remove member: $e")),
                );
              }
            },
            child: Text(
              "remove".tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCommunityDialog() {
    final nameController = TextEditingController(text: _info?['name']);
    final descController = TextEditingController(text: _info?['description']);
    final rulesController = TextEditingController(text: _info?['rules']);
    String? localImagePath;
    String? localCoverPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.w,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                24.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "edit_community".tr(),
                style: GoogleFonts.outfit(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 24.h),
              _buildFieldLabel("community_name_label".tr()),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  fillColor: AppColors.backgroundGrey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _buildFieldLabel("description_label".tr()),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  fillColor: AppColors.backgroundGrey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _buildFieldLabel("community_rules_label".tr()),
              TextField(
                controller: rulesController,
                maxLines: 3,
                decoration: InputDecoration(
                  fillColor: AppColors.backgroundGrey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _buildImagePickerTile(
                      "profile_photo".tr(),
                      localImagePath ?? _info?['image'],
                      () async {
                        final file = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file != null) {
                          setModalState(() => localImagePath = file.path);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildImagePickerTile(
                      "cover_photo".tr(),
                      localCoverPath ?? _info?['coverImage'],
                      () async {
                        final file = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file != null) {
                          setModalState(() => localCoverPath = file.path);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await sl<UpdateOwnerCommunityUseCase>().call(
                        communityId: widget.communityId,
                        name: nameController.text,
                        description: descController.text,
                        rules: rulesController.text,
                        imagePath: localImagePath,
                        coverImagePath: localCoverPath,
                      );
                      _loadInfo();
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text("Update failed: $e")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    "save_changes".tr(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerTile(
    String label,
    dynamic image,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.greyText,
          ),
        ),
        SizedBox(height: 8.h),
        BouncingWrapper(
          onTap: onTap,
          child: Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(16.r),
              image: image != null
                  ? DecorationImage(
                      image: image is String && image.startsWith('/')
                          ? ResizeImage(
                              FileImage(File(image)),
                              width: 160,
                              height: 160,
                            )
                          : CachedNetworkImageProvider(image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: image == null
                ? const Center(
                    child: Icon(
                      Icons.add_a_photo_rounded,
                      color: AppColors.primaryBlue,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade300,
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'failed_load_community'.tr(),
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              color: AppColors.greyText,
            ),
          ),
          SizedBox(height: 24.h),
          BouncingWrapper(
            onTap: _loadInfo,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'retry'.tr(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: BouncingWrapper(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      actions: [
        if (_info != null)
          Builder(
            builder: (context) {
              final currentUserId = context.read<AuthCubit>().currentOwner?.id;
              final isOwner = _info!['owner']?.toString() == currentUserId;

              if (!isOwner) return const SizedBox.shrink();

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  onPressed: _showEditCommunityDialog,
                ),
              );
            },
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _info?['image'] != null
                ? CachedNetworkImage(
                    imageUrl: _info!['image'],
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white.withValues(alpha: 0.2),
                        size: 80.sp,
                      ),
                    ),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _info?['name'] ?? 'Association',
                    style: GoogleFonts.outfit(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _info?['status']?.toString().toUpperCase() == 'PENDING'
                        ? 'verification_pending'.tr()
                        : 'verified_network'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color:
                          _info?['status']?.toString().toUpperCase() ==
                              'PENDING'
                          ? Colors.orange.shade300
                          : Colors.white70,
                      fontWeight:
                          _info?['status']?.toString().toUpperCase() ==
                              'PENDING'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _RedAlertForm extends StatefulWidget {
  final String communityId;
  final String associationId;

  const _RedAlertForm({required this.communityId, required this.associationId});

  @override
  State<_RedAlertForm> createState() => _RedAlertFormState();
}

class _RedAlertFormState extends State<_RedAlertForm> {
  final TextEditingController _descController = TextEditingController();
  String _selectedType = "Safety";
  bool _isBroadcasting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.w,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.sosRed),
              SizedBox(width: 8.w),
              Text(
                "raise_red_alert".tr(),
                style: GoogleFonts.outfit(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.sosRed,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "red_alert_broadcast_msg".tr(),
            style: TextStyle(color: AppColors.greyText, fontSize: 12.sp),
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel("issue_type_label".tr()),
          _buildDropdownField([
            "Safety",
            "Legal",
            "Health",
            "Utility",
            "Other",
          ]),
          SizedBox(height: 16.h),
          _buildFieldLabel("description_label".tr()),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "emergency_hint".tr(),
              fillColor: AppColors.backgroundGrey,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
              onPressed: _isBroadcasting ? null : _broadcastSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sosRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                disabledBackgroundColor: AppColors.sosRed.withValues(
                  alpha: 0.5,
                ),
              ),
              child: _isBroadcasting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "broadcast_sos_now".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _broadcastSOS() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("provide_desc_err".tr())));
      return;
    }

    setState(() => _isBroadcasting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sl<CommunityRepository>().broadcastSOS(
        associationId: widget.associationId,
        issueType: _selectedType,
        description: _descController.text.trim(),
        severity: "CRITICAL",
      );
      if (mounted) {
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text("sos_broadcast_success".tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBroadcasting = false);
        messenger.showSnackBar(
          SnackBar(content: Text("Failed to broadcast SOS: $e")),
        );
      }
    }
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
      ),
    );
  }

  Widget _buildDropdownField(List<String> items) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedType,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedType = v);
          },
        ),
      ),
    );
  }
}
