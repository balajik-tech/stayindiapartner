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

import 'community_home_page.dart';

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
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
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
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isOfficial
                      ? const Color(0xFF2563EB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isOfficial
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'official_feed'.tr(),
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: isOfficial
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                    if (unreadOfficial > 0) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isOfficial ? Colors.white : Colors.redAccent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.r,
                          minHeight: 16.r,
                        ),
                        child: Center(
                          child: Text(
                            '$unreadOfficial',
                            style: TextStyle(
                              color: isOfficial
                                  ? const Color(0xFF2563EB)
                                  : Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
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
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: !isOfficial
                      ? const Color(0xFFEA580C)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: !isOfficial
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFFEA580C,
                            ).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'owner_forum'.tr(),
                      style: GoogleFonts.dmSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: !isOfficial
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                    if (unreadForum > 0) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: !isOfficial ? Colors.white : Colors.redAccent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.r,
                          minHeight: 16.r,
                        ),
                        child: Center(
                          child: Text(
                            '$unreadForum',
                            style: TextStyle(
                              color: !isOfficial
                                  ? const Color(0xFFEA580C)
                                  : Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
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
                  SliverToBoxAdapter(child: _buildExploreSection()),
                  SliverToBoxAdapter(
                    child: _buildFeedSwitcher(
                      unreadOfficial: unreadOfficial,
                      unreadForum: unreadForum,
                    ),
                  ),
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
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
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
                      fontSize: 24.sp,
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
                      fontSize: 14.sp,
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
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  padding: EdgeInsets.all(8.w),
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
        ],
      ),
    );
  }

  Widget _buildExploreSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
        builder: (context, state) {
          final communities = state is OwnerCommunityLoaded
              ? state.joinedCommunities
              : <CommunityDetailsEntity>[];
          final associations = state is OwnerCommunityLoaded
              ? state.associations
              : <AssociationPortalEntity>[];

          return SizedBox(
            height: 80.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExploreCommunitiesPage(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.primaryBlue,
                          size: 24.sp,
                        ),
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
                ...associations.map((a) {
                  return Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssociateHomePage(associationId: a.id),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryBlue,
                                width: 2,
                              ),
                              color: Colors.white,
                            ),
                            child: (a.logo.isNotEmpty && ApiConstants.getImageUrl(a.logo) != null)
                                ? CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      ApiConstants.getImageUrl(a.logo)!,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: AppColors.primaryBlue,
                                    size: 28.sp,
                                  ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: 65.w,
                            child: Text(
                              a.name,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
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
                ...communities.map((c) {
                  final isPending = c.isPendingJoin;

                  if (!_unreadMessageCounts.containsKey(c.id)) {
                    _unreadMessageCounts[c.id] = c.name.hashCode % 3 + 1;
                    _saveUnreadMessageCounts();
                  }
                  final count = _unreadMessageCounts[c.id] ?? 0;

                  return Padding(
                    padding: EdgeInsets.only(right: 20.w),
                    child: GestureDetector(
                      onTap: () {
                        if (isPending) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CommunityDetailPage(communityId: c.id),
                            ),
                          ).then((_) {
                            if (context.mounted) {
                              context
                                  .read<OwnerCommunityCubit>()
                                  .loadCommunities();
                            }
                          });
                        } else {
                          setState(() {
                            _activeChatRoomId = c.id;
                            _unreadMessageCounts[c.id] = 0;
                          });
                          _saveUnreadMessageCounts();

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
                          ).then((_) {
                            setState(() {
                              _activeChatRoomId = null;
                            });
                            if (context.mounted) {
                              context
                                  .read<OwnerCommunityCubit>()
                                  .loadCommunities();
                            }
                          });
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isPending
                                        ? Colors.orange.shade300
                                        : Colors.grey.shade200,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 22.w,
                                  backgroundImage: c.image != null
                                      ? CachedNetworkImageProvider(c.image!)
                                      : null,
                                  backgroundColor: isPending
                                      ? Colors.orange.shade50
                                      : AppColors.accentOrange.withValues(
                                          alpha: 0.1,
                                        ),
                                  child: c.image == null
                                      ? Icon(
                                          Icons.groups,
                                          color: isPending
                                              ? Colors.orange
                                              : AppColors.accentOrange,
                                          size: 24.sp,
                                        )
                                      : null,
                                ),
                              ),
                              if (isPending)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(2.r),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.access_time_filled_rounded,
                                      color: Colors.white,
                                      size: 10.sp,
                                    ),
                                  ),
                                ),
                              if (count > 0 && !isPending)
                                Positioned(
                                  right: -4.w,
                                  top: -4.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 16.r,
                                      minHeight: 16.r,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$count',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: 65.w,
                            child: Text(
                              c.name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isPending
                                    ? Colors.orange.shade700
                                    : AppColors.darkText,
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
    if (state is SocialFeedLoaded) {
      final isOfficial = _activeFeedType == 'OFFICIAL';
      final filteredPosts = state.posts.where((post) {
        if (isOfficial) {
          return post.visibility?.toUpperCase() != 'GLOBAL';
        } else {
          return post.visibility?.toUpperCase() == 'GLOBAL';
        }
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
                      isOfficial
                          ? 'no_official_updates'.tr()
                          : 'no_forum_posts'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isOfficial
                          ? 'official_updates_appear_here'.tr()
                          : 'forum_posts_appear_here'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                if (mounted) {
                  _markPostAsRead(post.id);
                }
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundImage:
                        (widget.post.userAvatar != null &&
                            widget.post.userAvatar!.isNotEmpty)
                        ? CachedNetworkImageProvider(
                            ApiConstants.getImageUrl(widget.post.userAvatar!)!,
                          )
                        : null,
                    backgroundColor: accentColor.withValues(alpha: 0.08),
                    child:
                        (widget.post.userAvatar == null ||
                            widget.post.userAvatar!.isEmpty)
                        ? Icon(Icons.person, color: accentColor, size: 20.sp)
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            text:
                                '${widget.post.userName.isNotEmpty ? widget.post.userName : 'Unknown User'} ',
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                            children: [
                              TextSpan(
                                text: '$indicatorIcon [$displayRole]',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _formatTimeAgo(widget.post.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      final String? currentUserId = context
                          .read<AuthCubit>()
                          .currentOwner
                          ?.id;

                      if (currentUserId == null ||
                          currentUserId != widget.post.userId) {
                        return const SizedBox.shrink();
                      }

                      return PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.grey.shade400,
                          size: 20.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) {
                          if (value == 'edit') {
                            setState(() {
                              _isEditing = true;
                              _selectedImagePath = null;
                              _removeImage = false;
                              _removePoll = false;
                              _initPollControllers();
                            });
                          } else if (value == 'delete') {
                            _showDeleteConfirmDialog(context, widget.post);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  size: 18.sp,
                                  color: AppColors.darkText,
                                ),
                                SizedBox(width: 8.w),
                                Text('Edit', style: TextStyle(fontSize: 14.sp)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  size: 18.sp,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                widget.post.content,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.darkText,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.post.imageUrl != null &&
                  widget.post.imageUrl!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl:
                        ApiConstants.getImageUrl(widget.post.imageUrl!) ?? '',
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
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 32.sp,
                        color: Colors.grey.shade400,
                      ),
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
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: isMyVote
                              ? AppColors.primaryBlue.withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isMyVote
                                ? AppColors.primaryBlue
                                : Colors.grey.shade200,
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
                                    color: isMyVote
                                        ? AppColors.primaryBlue.withValues(
                                            alpha: 0.15,
                                          )
                                        : Colors.grey.shade200,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (isMyVote) ...[
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.primaryBlue,
                                              size: 18.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                          ],
                                          Expanded(
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: isMyVote
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
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
                      context.read<SocialFeedCubit>().toggleLike(
                        widget.post.id,
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          widget.post.isLiked
                              ? Icons.thumb_up_alt_rounded
                              : Icons.thumb_up_off_alt_rounded,
                          color: widget.post.isLiked
                              ? AppColors.primaryBlue
                              : Colors.grey.shade400,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${widget.post.likesCount}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: widget.post.isLiked
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: widget.post.isLiked
                                ? AppColors.primaryBlue
                                : Colors.grey.shade500,
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
                        builder: (context) => CommentsSheet(post: widget.post),
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
                          '${widget.post.commentsCount} Replies',
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
