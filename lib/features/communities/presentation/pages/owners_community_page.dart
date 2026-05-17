import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/social_feed_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/tenants_chat_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/explore_communities_page.dart';
import 'package:stayindia_owner/features/communities/presentation/widgets/comments_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';

class OwnersCommunityPage extends StatefulWidget {

  const OwnersCommunityPage({super.key});

  @override
  State<OwnersCommunityPage> createState() => _OwnersCommunityPageState();
}

class _OwnersCommunityPageState extends State<OwnersCommunityPage> {
  final TextEditingController _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedImagePath;
  bool _isPoll = false;
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  Set<String> _readPostIds = {};

  Future<void> _loadReadPostIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList('owner_community_read_post_ids');
      if (stored != null) {
        setState(() {
          _readPostIds = stored.toSet();
        });
      }
    } catch (e) {
      AppLogger.error('Error loading read posts: $e');
    }
  }

  void _markPostAsRead(String postId) async {
    if (!_readPostIds.contains(postId)) {
      setState(() {
        _readPostIds.add(postId);
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('owner_community_read_post_ids', _readPostIds.toList());
      } catch (e) {
        AppLogger.error('Error saving read posts: $e');
      }
    }
  }

  void _markAllPostsAsRead(List<SocialPostEntity> posts) async {
    final allPostIds = posts.map((p) => p.id).toList();
    setState(() {
      _readPostIds.addAll(allPostIds);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('owner_community_read_post_ids', _readPostIds.toList());
    } catch (e) {
      AppLogger.error('Error saving read posts: $e');
    }
  }

  int _getUnreadPostsCount(List<SocialPostEntity> posts) {
    return posts.where((post) => !_readPostIds.contains(post.id)).length;
  }

  @override
  void initState() {
    super.initState();
    _loadReadPostIds();
    context.read<OwnerCommunityCubit>().loadCommunities();
    context.read<SocialFeedCubit>().loadFeed();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<SocialFeedCubit>().loadMoreFeed();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postController.dispose();
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
        _isPoll = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<OwnerCommunityCubit>().loadCommunities();
            await context.read<SocialFeedCubit>().loadFeed(isRefresh: true);
          },
          color: AppColors.primaryBlue,
          child: BlocBuilder<SocialFeedCubit, SocialFeedState>(
            builder: (context, state) {
              return CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildExploreSection(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildCreatePostBox(),
                  ),
                  ..._buildFeedSlivers(state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'app_name'.tr(),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkText,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'pg_owners_community'.tr(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.greyText.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Row(
            children: [
              _buildNotificationAction(),
              SizedBox(width: 12.w),
              BouncingWrapper(
                onTap: () {
                  String hostelId = '';
                  final hostelState = context.read<HostelCubit>().state;
                  if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
                    hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TenantsChatPage(
                        hostelId: hostelId,
                        communityName: 'Tenants Community',
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people_rounded, color: AppColors.primaryBlue, size: 28.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
        builder: (context, state) {
          final communities = state is OwnerCommunityLoaded ? state.joinedCommunities : <CommunityDetailsEntity>[];

          return SizedBox(
            height: 95.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExploreCommunitiesPage()),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryBlue, width: 2),
                          color: Colors.white,
                        ),
                        child: Icon(Icons.add, color: AppColors.primaryBlue, size: 30.sp),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'explore'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
                ...communities.map((c) {
                  return Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TenantsChatPage(
                              hostelId: c.id,
                              communityName: c.name,
                              communityIcon: c.image,
                              isOwnerChat: true,
                              status: c.status,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 28.w,
                              backgroundImage: c.image != null ? CachedNetworkImageProvider(c.image!) : null,
                              backgroundColor: AppColors.accentOrange.withValues(alpha: 0.1),
                              child: c.image == null ? Icon(Icons.groups, color: AppColors.accentOrange, size: 28.sp) : null,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: 65.w,
                            child: Text(
                              c.name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatePostBox() {
    final validPollOptions = _pollOptionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final owner = authState is AuthAuthenticated ? authState.owner : null;
                  return CircleAvatar(
                    radius: 22.r,
                    backgroundImage: (owner?.avatar != null && owner!.avatar!.isNotEmpty) 
                        ? CachedNetworkImageProvider(ApiConstants.getImageUrl(owner.avatar)!) 
                        : null,
                    backgroundColor: Colors.grey.shade100,
                    child: (owner?.avatar == null || owner!.avatar!.isEmpty)
                        ? Icon(Icons.person, color: Colors.grey.shade400, size: 28.sp)
                        : null,
                  );
                },
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: TextField(
                  controller: _postController,
                  maxLength: 200,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: _isPoll ? 'ask_question'.tr() : 'share_your_thoughts'.tr(),
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16.sp, fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (val) => setState(() {}),
                ),
              ),
            ],
          ),
          if (_selectedImagePath != null) ...[
            SizedBox(height: 12.h),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.file(
                    File(_selectedImagePath!),
                    width: double.infinity,
                    height: 180.h,
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
                      onPressed: () {
                        setState(() {
                          _selectedImagePath = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_isPoll) ...[
            SizedBox(height: 12.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('poll_options'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.darkText)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isPoll = false;
                        });
                      },
                      child: Text('cancel_poll'.tr(), style: TextStyle(fontSize: 12.sp, color: Colors.red)),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ...List.generate(_pollOptionControllers.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: _pollOptionControllers[index],
                              decoration: InputDecoration(
                                hintText: 'option_n'.tr(namedArgs: {'n': '${index + 1}'}),
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                                border: InputBorder.none,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                        if (_pollOptionControllers.length > 2) ...[
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: Icon(Icons.close, size: 20.sp, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _pollOptionControllers[index].dispose();
                                _pollOptionControllers.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                if (_pollOptionControllers.length < 4)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _pollOptionControllers.add(TextEditingController());
                      });
                    },
                    icon: Icon(Icons.add, size: 18.sp, color: AppColors.primaryBlue),
                    label: Text('add_option'.tr(), style: TextStyle(fontSize: 13.sp, color: AppColors.primaryBlue, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _isPoll ? null : _pickImage,
                    icon: Icon(Icons.image_outlined, color: _isPoll ? Colors.grey.shade300 : AppColors.primaryBlue, size: 24.sp),
                  ),
                  IconButton(
                    onPressed: _selectedImagePath != null ? null : () {
                      setState(() {
                        _isPoll = true;
                      });
                    },
                    icon: Icon(Icons.poll_outlined, color: _selectedImagePath != null ? Colors.grey.shade300 : AppColors.primaryBlue, size: 24.sp),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${_postController.text.length}/200',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 16.w),
                  BlocBuilder<SocialFeedCubit, SocialFeedState>(
                    builder: (context, state) {
                      final isCreating = state is SocialFeedLoaded && state.isCreatingPost;
                      final canPost = _postController.text.trim().isNotEmpty &&
                          (!_isPoll || validPollOptions.length >= 2);

                      return ElevatedButton(
                        onPressed: (!canPost || isCreating) ? null : () {
                          context.read<SocialFeedCubit>().createPost(
                            content: _postController.text.trim(),
                            imagePath: _selectedImagePath,
                            type: _isPoll ? 'POLL' : 'POST',
                            pollOptions: _isPoll ? validPollOptions : null,
                          );
                          _postController.clear();
                          _selectedImagePath = null;
                          _isPoll = false;
                          for (var c in _pollOptionControllers) {
                            c.clear();
                          }
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                          elevation: 0,
                        ),
                        child: isCreating
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'post_btn'.tr(),
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.sp),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeedSlivers(SocialFeedState state) {
    if (state is SocialFeedLoading) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }
    if (state is SocialFeedLoaded) {
      if (state.posts.isEmpty) {
        return [
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 32.w),
                child: Column(
                  children: [
                    Icon(Icons.feed_outlined, size: 64.sp, color: Colors.grey.shade300),
                    SizedBox(height: 16.h),
                    Text(
                      'no_posts_yet'.tr(),
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'be_first_share'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      }
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = state.posts[index];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _markPostAsRead(post.id);
                  }
                });
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _PostCard(post: post),
                );
              },
              childCount: state.posts.length,
            ),
          ),
        ),
        if (state.isFetchingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ];
    }
    if (state is SocialFeedError) {
      return [
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text('something_wrong'.tr()),
                ],
              ),
            ),
          ),
        ),
      ];
    }
    return [const SliverToBoxAdapter(child: SizedBox.shrink())];
  }

  Widget _buildNotificationAction() {
    return BlocBuilder<SocialFeedCubit, SocialFeedState>(
      builder: (context, state) {
        final posts = state is SocialFeedLoaded ? state.posts : <SocialPostEntity>[];
        final unreadCount = _getUnreadPostsCount(posts);

        return BouncingWrapper(
          onTap: () => _showNotificationCenterSheet(posts),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  color: AppColors.primaryBlue,
                  size: 28.sp,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -2.h,
                  right: -2.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20.r,
                      minHeight: 20.r,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationCenterSheet(List<SocialPostEntity> posts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final unreadCount = _getUnreadPostsCount(posts);
            return Container(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'feed_updates'.tr(),
                        style: GoogleFonts.dmSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: () {
                            _markAllPostsAsRead(posts);
                            setModalState(() {});
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('all_read_success'.tr()),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Text(
                            'mark_all_read'.tr(),
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          unreadCount > 0 
                              ? Icons.mark_chat_unread_rounded
                              : Icons.mark_chat_read_rounded,
                          color: unreadCount > 0 ? AppColors.accentOrange : Colors.green,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unreadCount > 0 
                                    ? 'You have $unreadCount new posts'
                                    : 'You are all caught up!',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                unreadCount > 0
                                    ? 'Scroll through the community feed to read new updates instantly.'
                                    : 'No new unread community announcements at this time.',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final SocialPostEntity post;

  const _PostCard({required this.post});

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}m ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final pollOptionsList = post.poll?['options'] as List<dynamic>? ?? [];
    int totalVotes = 0;
    for (var opt in pollOptionsList) {
      if (opt is Map) {
        totalVotes += ((opt['votesCount'] ?? opt['votes'] ?? 0) as num).toInt();
      }
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: (post.userAvatar != null && post.userAvatar!.isNotEmpty) 
                    ? CachedNetworkImageProvider(ApiConstants.getImageUrl(post.userAvatar!)!) : null,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                child: (post.userAvatar == null || post.userAvatar!.isEmpty)
                    ? Icon(Icons.person, color: AppColors.primaryBlue, size: 24.sp)
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.userName.isNotEmpty ? post.userName : 'Unknown User',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('·', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w800)),
                        SizedBox(width: 8.w),
                        Text(
                          post.visibility != null && post.visibility!.toUpperCase() == 'GLOBAL'
                              ? 'Global'
                              : 'Community',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatTimeAgo(post.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.darkText,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: ApiConstants.getImageUrl(post.imageUrl!) ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180.h,
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180.h,
                  color: Colors.grey.shade100,
                  child: Icon(Icons.broken_image_rounded, size: 32.sp, color: Colors.grey.shade400),
                ),
              ),
            ),
          ],
          if (pollOptionsList.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ...List.generate(pollOptionsList.length, (i) {
              final opt = pollOptionsList[i];
              if (opt is Map) {
                final text = opt['text']?.toString() ?? '';
                final count = ((opt['votesCount'] ?? opt['votes'] ?? 0) as num).toInt();
                final pct = totalVotes > 0 ? (count / totalVotes) : 0.0;
                final isMyVote = post.userVote == i;

                return BouncingWrapper(
                  onTap: post.userVote != null
                      ? null
                      : () {
                          context.read<SocialFeedCubit>().votePoll(post.id, i);
                        },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: isMyVote ? AppColors.primaryBlue.withValues(alpha: 0.08) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isMyVote ? AppColors.primaryBlue : Colors.grey.shade200,
                        width: isMyVote ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              width: constraints.maxWidth * pct,
                              decoration: BoxDecoration(
                                color: isMyVote ? AppColors.primaryBlue.withValues(alpha: 0.15) : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (isMyVote) ...[
                                        Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 18.sp),
                                        SizedBox(width: 8.w),
                                      ],
                                      Expanded(
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: isMyVote ? FontWeight.w800 : FontWeight.w600,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${(pct * 100).round()}% ($count)',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade100, height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BouncingWrapper(
                onTap: () {
                  context.read<SocialFeedCubit>().toggleLike(post.id);
                },
                child: Row(
                  children: [
                    Icon(
                      post.isLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_off_alt_rounded,
                      color: post.isLiked ? AppColors.primaryBlue : Colors.grey.shade400,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: post.isLiked ? FontWeight.w800 : FontWeight.w600,
                        color: post.isLiked ? AppColors.primaryBlue : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              BouncingWrapper(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CommentsSheet(post: post),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.grey.shade400,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${post.commentsCount} Replies',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
