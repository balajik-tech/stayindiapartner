import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/social_feed_cubit.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/register_association_bottom_sheet.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/tenants_chat_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/explore_communities_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/community_detail_page.dart';
import 'package:stayindia_owner/features/communities/presentation/widgets/comments_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/owners_list_page.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:stayindia_owner/features/communities/domain/entities/association_portal_entity.dart';
import 'package:stayindia_owner/injection_container.dart';

import '../widgets/dotted_circle_painter.dart';
import 'community_home_page.dart';

class OwnersCommunityPage extends StatefulWidget {
  const OwnersCommunityPage({super.key});

  @override
  State<OwnersCommunityPage> createState() => _OwnersCommunityPageState();
}

class _OwnersCommunityPageState extends State<OwnersCommunityPage> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedImagePath;
  bool _isPoll = false;
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  String _activeFeedType = 'OFFICIAL';

  Set<String> _readPostIds = {};
  Map<String, int> _unreadMessageCounts = {};
  String? _activeChatRoomId;
  StreamSubscription? _socketSubscription;
  Timer? _debounceTimer;

  Future<void> _loadUnreadMessageCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('owner_community_unread_counts');
      if (jsonStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        setState(() {
          _unreadMessageCounts = decoded.map(
            (key, value) => MapEntry(key, value as int),
          );
        });
      }
    } catch (e) {
      AppLogger.error('Error loading unread counts: $e');
    }
  }

  Future<void> _saveUnreadMessageCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'owner_community_unread_counts',
        jsonEncode(_unreadMessageCounts),
      );
    } catch (e) {
      AppLogger.error('Error saving unread counts: $e');
    }
  }

  Future<void> _loadReadPostIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList(
        'owner_community_read_post_ids',
      );
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
      _readPostIds.add(postId);
      setState(() {});
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          'owner_community_read_post_ids',
          _readPostIds.toList(),
        );
      } catch (e) {
        AppLogger.error('Error saving read posts: $e');
      }
    }
  }

  void _debouncedSetState(VoidCallback fn) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(fn);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadReadPostIds();
    _loadUnreadMessageCounts();
    context.read<OwnerCommunityCubit>().loadCommunities();
    context.read<SocialFeedCubit>().loadFeed();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<SocialFeedCubit>().loadMoreFeed();
      }
    });

    _socketSubscription = sl<SocketService>().messageStream.listen((data) {
      final roomId = data['roomId']?.toString();
      if (roomId != null && roomId != _activeChatRoomId) {
        _unreadMessageCounts[roomId] = (_unreadMessageCounts[roomId] ?? 0) + 1;
        _debouncedSetState(() {});
        _saveUnreadMessageCounts();
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _postController.dispose();
    _searchController.dispose();
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

  Widget _buildFeedSwitcher({int unreadOfficial = 0, int unreadForum = 0}) {
    final isOfficial = _activeFeedType == 'OFFICIAL';
    const activeColor = Color(0xFF1650A2);
    const inactiveColor = Colors.transparent;
    const bgColor = Color(0xFFF3F0EA);

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: BouncingWrapper(
              onTap: () {
                setState(() {
                  _activeFeedType = 'OFFICIAL';
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: isOfficial ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isOfficial)
                      Icon(Icons.lock_outline_rounded,
                          size: 14.sp, color: Colors.grey.shade600),
                    if (!isOfficial) SizedBox(width: 4.w),
                    Text(
                      'Official feed',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isOfficial ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    if (unreadOfficial > 0) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isOfficial ? Colors.white : const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '$unreadOfficial',
                          style: TextStyle(
                            color: isOfficial ? activeColor : Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: BouncingWrapper(
              onTap: () {
                setState(() {
                  _activeFeedType = 'GLOBAL';
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: !isOfficial ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PG owners forum',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: !isOfficial ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    if (unreadForum > 0) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: !isOfficial ? Colors.white : const Color(0xFFEA580C),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '$unreadForum',
                          style: TextStyle(
                            color: !isOfficial ? activeColor : Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfcf7f3),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<OwnerCommunityCubit>().loadCommunities();
            await context.read<SocialFeedCubit>().loadFeed(isRefresh: true);
          },
          color: AppColors.primaryBlue,
          child: BlocBuilder<SocialFeedCubit, SocialFeedState>(
            builder: (context, state) {
              final posts = state is SocialFeedLoaded
                  ? state.posts
                  : <SocialPostEntity>[];
              final officialPosts = posts
                  .where((p) => p.visibility?.toUpperCase() != 'GLOBAL')
                  .toList();
              final unreadOfficial = officialPosts
                  .where((p) => !_readPostIds.contains(p.id))
                  .length;

              final globalPosts = posts
                  .where((p) => p.visibility?.toUpperCase() == 'GLOBAL')
                  .toList();
              final unreadForum = globalPosts
                  .where((p) => !_readPostIds.contains(p.id))
                  .length;

              return CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverToBoxAdapter(child: _buildExploreSection()),
                  SliverToBoxAdapter(
                    child: _buildFeedSwitcher(
                      unreadOfficial: unreadOfficial,
                      unreadForum: unreadForum,
                    ),
                  ),
                  if (_activeFeedType == 'GLOBAL')
                    SliverToBoxAdapter(child: _buildCreatePostBox()),
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
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: const Color(0xFF1650A2),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay India',
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'PG owners community',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          BouncingWrapper(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OwnersListPage(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryBlue,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search associations',
            hintStyle: GoogleFonts.inter(
              color: AppColors.greyText,
              fontSize: 15.sp,
            ),
            prefixIcon: Icon(Icons.search_rounded,
                color:  AppColors.greyText, size: 22.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildExploreSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
        builder: (context, state) {
          final communities = state is OwnerCommunityLoaded
              ? state.joinedCommunities
              : <CommunityDetailsEntity>[];
          final associations = state is OwnerCommunityLoaded
              ? state.associations.where((a) {
                  final query = _searchController.text.toLowerCase();
                  return a.name.toLowerCase().contains(query);
                }).toList()
              : <AssociationPortalEntity>[];

          return SizedBox(
            height: 90.h,
            child:ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                overscroll: false,
              ),child:  Center(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      showRegisterAssociationBottomSheet(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: CustomPaint(
                            painter: DashedLineCirclePainter(
                              color: AppColors.greyText,
                              strokeWidth: 1.5,
                              dashLength: 6,
                              gapLength: 8,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                color: const Color(0xFFF48126),
                                size: 28.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Create new',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                  ...associations.map((a) {
                    return Padding(
                      padding: EdgeInsets.only(right: 20.w),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AssociateHomePage(associationId: a.id),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56.w,
                              height: 56.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade100,
                                border: Border.all(
                                  color: AppColors.greyText,
                                  width: 0.8,
                                ),
                              ),
                              child: ClipOval(
                                child: (a.logo.isNotEmpty &&
                                        ApiConstants.getImageUrl(a.logo) != null)
                                    ? CachedNetworkImage(
                                        imageUrl: ApiConstants.getImageUrl(a.logo)!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.business_rounded,
                                        color: Colors.grey.shade400,
                                        size: 28.sp,
                                      ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              width: 70.w,
                              child: Text(
                                a.name,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color:  AppColors.grayColor3,
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
              ),)
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatePostBox() {
    final authCubit = context.read<AuthCubit>();
    final owner = authCubit.currentOwner;
    final isOfficial = _activeFeedType == 'OFFICIAL';

    if (isOfficial) {
      final role = owner?.role.toLowerCase() ?? 'owner';
      final canPost = role != 'owner';
      if (!canPost) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFF2563EB),
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'official_read_only_banner'.tr(),
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF1E3A8A),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    final validPollOptions = _pollOptionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0EA).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final owner = authState is AuthAuthenticated
                      ? authState.owner
                      : null;
                  return CircleAvatar(
                    radius: 22.r,
                    backgroundImage:
                        (owner?.avatar != null && owner!.avatar!.isNotEmpty)
                        ? CachedNetworkImageProvider(
                            ApiConstants.getImageUrl(owner.avatar)!,
                          )
                        : null,
                    backgroundColor: Colors.grey.shade100,
                    child: (owner?.avatar == null || owner!.avatar!.isEmpty)
                        ? Icon(
                            Icons.person,
                            color: Colors.grey.shade400,
                            size: 28.sp,
                          )
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
                    hintText: _isPoll
                        ? 'ask_question'.tr()
                        : 'share_your_thoughts'.tr(),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
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
                    Text(
                      'poll_options'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isPoll = false;
                        });
                      },
                      child: Text(
                        'cancel_poll'.tr(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.red),
                      ),
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
                                hintText: 'option_n'.tr(
                                  namedArgs: {'n': '${index + 1}'},
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14.sp,
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                        if (_pollOptionControllers.length > 2) ...[
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 20.sp,
                              color: Colors.grey,
                            ),
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
                    icon: Icon(
                      Icons.add,
                      size: 18.sp,
                      color: AppColors.primaryBlue,
                    ),
                    label: Text(
                      'add_option'.tr(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                    icon: Icon(
                      Icons.image_outlined,
                      color: _isPoll
                          ? Colors.grey.shade300
                          : AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: _selectedImagePath != null
                        ? null
                        : () {
                            setState(() {
                              _isPoll = true;
                            });
                          },
                    icon: Icon(
                      Icons.poll_outlined,
                      color: _selectedImagePath != null
                          ? Colors.grey.shade300
                          : AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${_postController.text.length}/200',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  BlocBuilder<SocialFeedCubit, SocialFeedState>(
                    builder: (context, state) {
                      final isCreating =
                          state is SocialFeedLoaded && state.isCreatingPost;
                      final canPost =
                          _postController.text.trim().isNotEmpty &&
                          (!_isPoll || validPollOptions.length >= 2);

                      return ElevatedButton(
                        onPressed: (!canPost || isCreating)
                            ? null
                            : () {
                                context.read<SocialFeedCubit>().createPost(
                                  content: _postController.text.trim(),
                                  imagePath: _selectedImagePath,
                                  type: _isPoll ? 'POLL' : 'POST',
                                  pollOptions: _isPoll
                                      ? validPollOptions
                                      : null,
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
                          disabledBackgroundColor: AppColors.primaryBlue
                              .withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 28.w,
                            vertical: 12.h,
                          ),
                          elevation: 0,
                        ),
                        child: isCreating
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'post_btn'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.sp,
                                ),
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

    final isOfficial = _activeFeedType == 'OFFICIAL';

    if (isOfficial) {
      final posts = state is SocialFeedLoaded ? state.posts : <SocialPostEntity>[];
      final officialPosts = posts
          .where((p) => p.visibility?.toUpperCase() != 'GLOBAL')
          .toList();

      if (officialPosts.isNotEmpty) {
        return [
          SliverPadding(
            padding: EdgeInsets.zero,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final post = officialPosts[index];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _markPostAsRead(post.id);
                });
                return _PostCard(post: post);
              }, childCount: officialPosts.length),
            ),
          ),
          if (state is SocialFeedLoaded && state.isFetchingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ];
      }

      return [
        SliverToBoxAdapter(child: _buildOfficialLockedState()),
        SliverToBoxAdapter(child: _buildSuggestedNearYou()),
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ];
    }

    if (state is SocialFeedLoaded) {
      final filteredPosts = state.posts.where((post) {
        return post.visibility?.toUpperCase() == 'GLOBAL';
      }).toList();

      if (filteredPosts.isEmpty) {
        return [
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 32.w),
                child: Column(
                  children: [
                    Icon(
                      Icons.feed_outlined,
                      size: 64.sp,
                      color: Colors.grey.shade300,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No forum posts',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Forum posts appear here',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: AppColors.greyText,
                      ),
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
          padding: EdgeInsets.zero,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = filteredPosts[index];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _markPostAsRead(post.id);
              });
              return _PostCard(post: post);
            }, childCount: filteredPosts.length),
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

  Widget _buildOfficialLockedState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: Color(0xFFf3ede7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: Colors.grey.shade400,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Join to see official notices',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              'Circulars, licence updates and meeting notices from your association.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.grayColor3,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => const ExploreCommunitiesPage(),
              //   ),
              // );
              // _searchFocusNode.requestFocus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1650A2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Browse associations',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'The forum stays open to everyone.',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.grayColor3,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 24.h),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildSuggestedNearYou() {
    return BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
      builder: (context, state) {
        if (state is! OwnerCommunityLoaded) return const SizedBox.shrink();

        final suggested = state.associations.take(2).toList();
        if (suggested.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 12.h),
              child: Text(
                'Suggested near you',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grayColor3,
                ),
              ),
            ),
            ...suggested.map((a) => _buildSuggestedItem(a)),
          ],
        );
      },
    );
  }

  Widget _buildSuggestedItem(AssociationPortalEntity a) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Color(0xFFf3ede7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.business_rounded,
                color: Colors.grey.shade400,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.name,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  'City · 1,240 members', // Placeholder as per screenshot
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.grayColor3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssociateHomePage(associationId: a.id),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
            ),
            child: Text(
              'Join',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final SocialPostEntity post;

  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
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
    if (_isEditing) {
      return _buildInlineEditor(context);
    }

    final pollOptionsList =
        widget.post.poll?['options'] as List<dynamic>? ?? [];
    int totalVotes = 0;
    for (var opt in pollOptionsList) {
      if (opt is Map) {
        totalVotes += ((opt['votesCount'] ?? opt['votes'] ?? 0) as num).toInt();
      }
    }

    final isOfficialPost = widget.post.visibility?.toUpperCase() != 'GLOBAL';
    final accentColor = isOfficialPost
        ? const Color(0xFF2563EB)
        : const Color(0xFFEA580C);
    final indicatorIcon = isOfficialPost ? '🔹' : '🔸';

    String displayRole;
    if (isOfficialPost) {
      displayRole =
          (widget.post.userRole != null && widget.post.userRole!.isNotEmpty)
          ? widget.post.userRole!
          : 'president_admin_role'.tr();
    } else {
      final city = widget.post.userCity;
      final state = widget.post.userState;
      if (city != null &&
          city.isNotEmpty &&
          state != null &&
          state.isNotEmpty) {
        displayRole = '$city, $state';
      } else if (city != null && city.isNotEmpty) {
        displayRole = city;
      } else if (state != null && state.isNotEmpty) {
        displayRole = state;
      } else {
        displayRole = 'pg_owner_role'.tr();
      }
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: (widget.post.userAvatar != null &&
                        widget.post.userAvatar!.isNotEmpty)
                        ? CachedNetworkImageProvider(
                      ApiConstants.getImageUrl(widget.post.userAvatar!)!,
                    )
                        : null,
                    child: (widget.post.userAvatar == null ||
                        widget.post.userAvatar!.isEmpty)
                        ? Text(
                      widget.post.userName.isNotEmpty
                          ? widget.post.userName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    )
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
                              widget.post.userName.isNotEmpty
                                  ? widget.post.userName
                                  : 'Unknown User',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkText,
                              ),
                            ),
                            const Spacer(),
                            if (widget.post.userRole?.toLowerCase() == 'member' || isOfficialPost)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  'Member',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1650A2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '$displayRole · ${_formatTimeAgo(widget.post.createdAt)}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                widget.post.content,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.grayColor3,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.post.imageUrl != null &&
                  widget.post.imageUrl!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl:
                    ApiConstants.getImageUrl(widget.post.imageUrl!) ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              if (pollOptionsList.isNotEmpty) ...[
                SizedBox(height: 12.h),
                ...List.generate(pollOptionsList.length, (i) {
                  final opt = pollOptionsList[i];
                  if (opt is Map) {
                    final text = opt['text']?.toString() ?? '';
                    final count =
                    ((opt['votesCount'] ?? opt['votes'] ?? 0) as num)
                        .toInt();
                    final pct = totalVotes > 0 ? (count / totalVotes) : 0.0;
                    final isMyVote = widget.post.userVote == i;

                    return BouncingWrapper(
                      onTap: widget.post.userVote != null
                          ? null
                          : () {
                        context.read<SocialFeedCubit>().votePoll(
                          widget.post.id,
                          i,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: isMyVote
                              ? const Color(0xFFEFF6FF)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isMyVote
                                ? const Color(0xFF1650A2)
                                : Colors.grey.shade200,
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
                                    color: isMyVote
                                        ? const Color(0xFF1650A2)
                                        .withValues(alpha: 0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                text,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: isMyVote
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: AppColors.darkText,
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
              Row(
                children: [
                  BouncingWrapper(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CommentsSheet(post: widget.post),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: AppColors.grayColor3,
                          size: 18.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '${widget.post.commentsCount} replies',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grayColor3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),
                  BouncingWrapper(
                    onTap: () {
                      // Share logic placeholder
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: AppColors.grayColor3,
                          size: 18.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Share',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grayColor3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInlineEditor(BuildContext context) {
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
              Text(
                'Edit Post',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
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
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
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
                  icon: const Icon(
                    Icons.restore_rounded,
                    color: AppColors.primaryBlue,
                    size: 16,
                  ),
                  label: const Text(
                    'Restore Poll',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
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
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Edit your thoughts...',
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          SizedBox(height: 16.h),

          if (widget.post.imageUrl != null &&
              !_removeImage &&
              _selectedImagePath == null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl:
                        ApiConstants.getImageUrl(widget.post.imageUrl!) ?? '',
                    width: double.infinity,
                    height: 180.h,
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
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          if (_selectedImagePath != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.file(
                    File(_selectedImagePath!),
                    width: double.infinity,
                    height: 180.h,
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
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          if ((widget.post.imageUrl == null || _removeImage) &&
              _selectedImagePath == null)
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

          if (widget.post.poll != null && !_removePoll) ...[
            SizedBox(height: 16.h),
            Text(
              'Poll Options',
              style: TextStyle(
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
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
              style: TextStyle(
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              ElevatedButton(
                onPressed: () {
                  final newContent = _contentController.text.trim();
                  if (newContent.isEmpty &&
                      _selectedImagePath == null &&
                      (widget.post.imageUrl == null || _removeImage) &&
                      (widget.post.poll == null || _removePoll)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Post content cannot be completely empty',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final validPollOptions = _pollOptionControllers
                      .map((c) => c.text.trim())
                      .where((t) => t.isNotEmpty)
                      .toList();

                  context.read<SocialFeedCubit>().updatePost(
                    postId: widget.post.id,
                    content: newContent,
                    imagePath: _selectedImagePath,
                    removeImage: _removeImage,
                    pollOptions: _removePoll ? null : validPollOptions,
                    removePoll: _removePoll,
                  );

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
                child: const Text(
                  'Save',
                  style: TextStyle(
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

  void _showDeleteConfirmDialog(BuildContext context, SocialPostEntity post) {
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
          style: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
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
              context.read<SocialFeedCubit>().deletePost(post.id);
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
