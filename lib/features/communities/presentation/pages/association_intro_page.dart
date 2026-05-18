import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/domain/usecases/community_usecases.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/error/app_exceptions.dart';

import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/community_detail_page.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/community_discovery_hub_page.dart';
import 'package:stayindia_owner/features/communities/presentation/widgets/social_post_composer.dart';
import 'package:stayindia_owner/features/communities/presentation/widgets/social_post_card.dart';
import 'package:stayindia_owner/features/communities/presentation/widgets/community_stories_bar.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/tenants_chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/features/communities/presentation/widgets/comments_sheet.dart';
import 'package:stayindia_owner/features/communities/presentation/widgets/create_association_modal.dart';

class AssociationIntroPage extends StatefulWidget {
  const AssociationIntroPage({super.key});

  @override
  State<AssociationIntroPage> createState() => AssociationIntroPageState();
}

class AssociationIntroPageState extends State<AssociationIntroPage> {
  final Color deepBlue = AppColors.primaryBlue;
  final Color orangeAccent = AppColors.accentOrange;

  List<Map<String, dynamic>> _allStates = [];
  List<CommunityDetailsEntity> _myCommunities = [];
  final List<SocialPostEntity> _posts = <SocialPostEntity>[];
  bool _isLoading = true;
  bool _isFeedLoading = false;
  bool _isExploring = false;
  int _feedSkip = 0;
  final int _feedLimit = 20;
  bool _hasMorePosts = true;

  final TextEditingController _composerController = TextEditingController();
  bool _isComposerExpanded = false;
  final FocusNode _composerFocusNode = FocusNode();
  XFile? _selectedImage;
  List<String> _pollOptions = [];
  Map<String, dynamic>? _selectedLocation;
  final ImagePicker _picker = ImagePicker();

  Set<String> _readPostIds = {};

  Future<void> _loadReadPostIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList('read_post_ids');
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
        await prefs.setStringList('read_post_ids', _readPostIds.toList());
      } catch (e) {
        AppLogger.error('Error saving read posts: $e');
      }
    }
  }

  void _markAllPostsAsRead() async {
    final allPostIds = _posts.map((p) => p.id).toList();
    setState(() {
      _readPostIds.addAll(allPostIds);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_post_ids', _readPostIds.toList());
    } catch (e) {
      AppLogger.error('Error saving read posts: $e');
    }
  }

  int get _unreadPostsCount {
    return _posts.where((post) => !_readPostIds.contains(post.id)).length;
  }

  void _showNotificationCenterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final unreadCount = _unreadPostsCount;
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
                        StringUtils.translate(
                          'feed_updates_title',
                          context: context,
                        ),
                        style: GoogleFonts.dmSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: () {
                            _markAllPostsAsRead();
                            setModalState(() {});
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  StringUtils.translate(
                                    'all_posts_read_msg',
                                    context: context,
                                  ),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Text(
                            StringUtils.translate(
                              'mark_all_read',
                              context: context,
                            ),
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
                          color: unreadCount > 0
                              ? AppColors.accentOrange
                              : Colors.green,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unreadCount > 0
                                    ? StringUtils.translate(
                                        'new_posts_count',
                                        namedArgs: {
                                          'count': unreadCount.toString(),
                                        },
                                        context: context,
                                      )
                                    : StringUtils.translate(
                                        'all_caught_up',
                                        context: context,
                                      ),
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                unreadCount > 0
                                    ? StringUtils.translate(
                                        'feed_scroll_msg',
                                        context: context,
                                      )
                                    : StringUtils.translate(
                                        'no_unread_announcements',
                                        context: context,
                                      ),
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
                        StringUtils.translate('cancel', context: context),
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
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

  @override
  void dispose() {
    _composerController.dispose();
    _composerFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadReadPostIds();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final joinedResults = await sl<GetJoinedOwnerCommunitiesUseCase>().call();

      final results = await sl<GetAssociationsUseCase>().call(level: 'STATE');

      if (mounted) {
        setState(() {
          _myCommunities = joinedResults;
          _allStates = results;
          _isLoading = false;
          _isExploring = false;
        });

        _loadFeed();
      }
    } catch (e) {
      AppLogger.error('Error loading community data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFeed({bool isRefresh = true}) async {
    if (_isFeedLoading && !isRefresh) return;
    if (isRefresh && _isFeedLoading) return;

    if (isRefresh) {
      setState(() {
        _isFeedLoading = true;
        _feedSkip = 0;
        _hasMorePosts = true;
      });
    } else {
      if (!_hasMorePosts) return;
      setState(() => _isFeedLoading = true);
    }

    try {
      final feedResults = await sl<GetSocialFeedUseCase>().call(
        limit: _feedLimit,
        skip: _feedSkip,
      );

      if (mounted) {
        setState(() {
          if (isRefresh) {
            _posts.clear();
            _posts.addAll(feedResults);
          } else {
            _posts.addAll(feedResults);
          }
          _feedSkip += feedResults.length;
          _hasMorePosts = feedResults.length == _feedLimit;
          _isFeedLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading feed: $e');
      if (mounted) {
        setState(() => _isFeedLoading = false);
      }
    }
  }

  Future<void> _toggleLike(SocialPostEntity post) async {
    final int index = _posts.indexWhere((p) => p.id == post.id);
    if (index == -1) {
      return;
    }

    final originalPost = _posts[index];
    setState(() {
      _posts[index] = originalPost.copyWith(
        isLiked: !originalPost.isLiked,
        likesCount: originalPost.isLiked
            ? originalPost.likesCount - 1
            : originalPost.likesCount + 1,
      );
    });

    try {
      await sl<TogglePostLikeUseCase>().call(post.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _posts[index] = originalPost;
        });
      }
    }
  }

  Future<void> _voteOnPoll(SocialPostEntity post, int optionIndex) async {
    if (post.userVote != null) {
      return;
    }

    final int index = _posts.indexWhere((p) => p.id == post.id);
    if (index == -1) {
      return;
    }

    final originalPost = _posts[index];

    final poll = Map<String, dynamic>.from(originalPost.poll ?? {});
    final options = List.from(
      poll['options'] ?? [],
    ).map((o) => Map<String, dynamic>.from(o)).toList();

    if (optionIndex < options.length) {
      options[optionIndex]['votes'] =
          (options[optionIndex]['votes'] as int? ?? 0) + 1;
    }
    poll['options'] = options;

    setState(() {
      _posts[index] = originalPost.copyWith(userVote: optionIndex, poll: poll);
    });

    try {
      await sl<VotePollUseCase>().call(post.id, optionIndex);
    } catch (e) {
      if (mounted) {
        setState(() {
          _posts[index] = originalPost;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              StringUtils.translate('failed_vote_err', context: context),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          StringUtils.translate('delete_post_title', context: context),
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          StringUtils.translate('delete_post_confirm', context: context),
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              StringUtils.translate('cancel', context: context),
              style: GoogleFonts.dmSans(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              StringUtils.translate('remove', context: context),
              style: GoogleFonts.dmSans(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    final int index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) {
      return;
    }

    final originalPost = _posts[index];
    setState(() {
      _posts.removeAt(index);
    });

    try {
      await sl<DeleteSocialPostUseCase>().call(postId);
    } catch (e) {
      AppLogger.error('Error deleting post: $e');
      if (mounted) {
        setState(() {
          _posts.insert(index, originalPost);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              StringUtils.translate('failed_delete_post_err', context: context),
            ),
          ),
        );
      }
    }
  }

  void _showCommentsSheet(SocialPostEntity post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(post: post),
    ).then((_) {
      _feedSkip = 0;
      _loadFeed(isRefresh: true);
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              StringUtils.translate(
                'location_services_disabled',
                context: context,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: StringUtils.translate('settings', context: context),
              textColor: Colors.white,
              onPressed: () async {
                await Geolocator.openLocationSettings();
              },
            ),
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                StringUtils.translate(
                  'location_permission_denied',
                  context: context,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: StringUtils.translate('settings', context: context),
                textColor: Colors.white,
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
              ),
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              StringUtils.translate(
                'location_permission_denied_forever',
                context: context,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: StringUtils.translate('settings', context: context),
              textColor: Colors.white,
              onPressed: () async {
                await Geolocator.openAppSettings();
              },
            ),
          ),
        );
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _selectedLocation = {
            'address': '${place.locality}, ${place.administrativeArea}',
            'latitude': position.latitude,
            'longitude': position.longitude,
          };
        });
      }
    } catch (e) {
      AppLogger.error('Error getting placemark: $e');
    }
  }

  void _addPollOption() {
    if (_pollOptions.length < 4) {
      setState(() => _pollOptions.add('Option ${_pollOptions.length + 1}'));
    }
  }

  Future<void> _createPost(String content, String type) async {
    if (content.trim().isEmpty &&
        _pollOptions.isEmpty &&
        _selectedImage == null) {
      return;
    }

    final owner = sl<AuthCubit>().currentOwner;
    final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
    String actualType = type;
    if (_pollOptions.isNotEmpty) {
      actualType = 'POLL';
    } else if (_selectedImage != null) {
      actualType = 'IMAGE';
    }

    final tempPost = SocialPostEntity(
      id: tempId,
      userId: owner?.id ?? 'me',
      userName: owner?.name ?? 'You',
      userAvatar: owner?.avatar,
      content: content,
      type: actualType,
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      createdAt: DateTime.now(),
      visibility: 'GLOBAL',
      poll: _pollOptions.isNotEmpty
          ? {
              'options': _pollOptions
                  .map((opt) => {'text': opt, 'votes': 0})
                  .toList(),
              'totalVotes': 0,
            }
          : null,
    );

    setState(() {
      _posts.insert(0, tempPost);
      _composerController.clear();
    });

    try {
      final createdPost = await sl<CreateSocialPostUseCase>().call(
        content: content,
        type: actualType,
        imagePath: _selectedImage?.path,
        pollOptions: _pollOptions.isNotEmpty ? _pollOptions : null,
        location: _selectedLocation,
      );

      if (mounted) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == tempId);
          if (index != -1) {
            _posts[index] = createdPost;
          }
          _selectedImage = null;
          _pollOptions = [];
          _selectedLocation = null;
          _isComposerExpanded = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error creating post: $e');
      if (mounted) {
        setState(() {
          _posts.removeWhere((p) => p.id == tempId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              StringUtils.translate('failed_create_post_err', context: context),
            ),
          ),
        );
      }
    }
  }

  void resetView() {
    if (_myCommunities.isNotEmpty && _isExploring) {
      setState(() => _isExploring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    if (_isExploring) {
      return CommunityDiscoveryHubPage(
        allStates: _allStates,
        onBack: _myCommunities.isNotEmpty
            ? () => setState(() => _isExploring = false)
            : null,
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: _buildSocialFeedView(),
        ),
        floatingActionButton: _isComposerExpanded
            ? null
            : FloatingActionButton(
                heroTag: 'association_fab',
                onPressed: () {
                  setState(() {
                    _isComposerExpanded = true;
                    _composerFocusNode.requestFocus();
                  });
                },
                elevation: 4,
                backgroundColor: AppColors.primaryBlue,
                shape: const CircleBorder(),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialFeedView() {
    return BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
      builder: (context, state) {
        if (state is OwnerCommunityLoaded) {
          _myCommunities = state.joinedCommunities;
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadFeed();
            if (mounted && context.mounted) {
              context.read<OwnerCommunityCubit>().loadCommunities();
            }
          },
          color: AppColors.primaryBlue,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(),
              SliverToBoxAdapter(
                child: CommunityStoriesBar(
                  communities: _myCommunities,
                  onAddClick: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CommunityDiscoveryHubPage(allStates: _allStates),
                      ),
                    );
                  },
                  onCommunityClick: (community) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TenantsChatPage(
                          hostelId: community.id,
                          communityName: community.name,
                          communityIcon: community.image,
                          isOwnerChat: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: SocialPostComposer(
                  userAvatar:
                      context.read<AuthCubit>().currentOwner?.avatar ?? '',
                  pollOptions: _pollOptions,
                  selectedImage: _selectedImage != null
                      ? File(_selectedImage!.path)
                      : null,
                  selectedLocation: _selectedLocation,
                  onPost: (content) => _createPost(content, 'POST'),
                  onPickImage: _pickImage,
                  onCreatePoll: () {
                    if (_pollOptions.isEmpty) {
                      setState(() => _pollOptions = ['', '']);
                    }
                  },
                  onAddLocation: _getCurrentLocation,
                  onRemoveImage: () => setState(() => _selectedImage = null),
                  onRemovePollOption: (index) =>
                      setState(() => _pollOptions.removeAt(index)),
                  onPollOptionChanged: (index, val) =>
                      _pollOptions[index] = val,
                  onAddPollOption: _addPollOption,
                  onRemoveLocation: () =>
                      setState(() => _selectedLocation = null),
                ),
              ),
              _buildPostFeed(),
              SliverToBoxAdapter(child: SizedBox(height: 140.h)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      expandedHeight: 100.h,
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(color: Colors.white),
        titlePadding: EdgeInsets.only(left: 16.w, bottom: 12.h, right: 16.w),
        centerTitle: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringUtils.translate('app_name', context: context),
                    style: GoogleFonts.dmSans(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    StringUtils.translate(
                      'pg_owners_community',
                      context: context,
                    ),
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            _buildNotificationAction(),
            SizedBox(width: 8.w),
            _buildAppBarAction(
              Icons.groups_rounded,
              onTap: () {
                final hostelState = context.read<HostelCubit>().state;
                if (hostelState is HostelLoaded &&
                    hostelState.hostels.isNotEmpty) {
                  final hostelId =
                      hostelState.hostels[hostelState.selectedHostelIndex].id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TenantsChatPage(
                        hostelId: hostelId,
                        isOwnerChat: true,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        StringUtils.translate(
                          'select_property_err',
                          context: context,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationAction() {
    final unreadCount = _unreadPostsCount;
    return BouncingWrapper(
      onTap: _showNotificationCenterSheet,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_rounded,
              color: AppColors.primaryBlue,
              size: 16.sp,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -2.h,
              right: -2.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(minWidth: 14.r, minHeight: 14.r),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, {VoidCallback? onTap}) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 16.sp),
      ),
    );
  }

  Widget _buildPostFeed() {
    if (_isFeedLoading && _posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40.r),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40.r),
          child: Column(
            children: [
              Icon(Icons.feed_outlined, size: 60.sp, color: Colors.grey[300]),
              SizedBox(height: 16.h),
              Text(
                'No posts yet',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == _posts.length) {
          if (_hasMorePosts) {
            _loadFeed(isRefresh: false);
            return Padding(
              padding: EdgeInsets.all(20.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return const SizedBox();
        }

        final post = _posts[index];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _markPostAsRead(post.id);
          }
        });
        return SocialPostCard(
          post: post,
          currentUserId: context.read<AuthCubit>().currentOwner?.id ?? '',
          onLike: () => _toggleLike(post),
          onComment: () => _showCommentsSheet(post),
          onVote: (optionIndex) {
            _voteOnPoll(post, optionIndex);
          },
          onDelete: () => _deletePost(post.id),
        );
      }, childCount: _posts.length + (_hasMorePosts ? 1 : 0)),
    );
  }
}

class AssociationHierarchyPage extends StatefulWidget {
  final String parentId;
  final String parentName;
  final String level;
  final List<Map<String, dynamic>> allStates;

  const AssociationHierarchyPage({
    super.key,
    required this.parentId,
    required this.parentName,
    required this.level,
    required this.allStates,
  });

  @override
  State<AssociationHierarchyPage> createState() =>
      _AssociationHierarchyPageState();
}

class _AssociationHierarchyPageState extends State<AssociationHierarchyPage> {
  late String _currentLevel;
  late String _stateId;
  late String _stateName;

  String? _selectedDistrictId;
  String? _selectedDistrictName;
  String? _selectedWardId;
  String? _selectedWardName;
  final List<String> _levels = ['STATE', 'DISTRICT', 'WARD'];
  final TextEditingController _districtSearchController =
      TextEditingController();
  String _districtSearchQuery = '';
  List<Map<String, dynamic>>? _cachedDistricts;
  bool _isLoadingDistricts = false;

  final TextEditingController _wardSearchController = TextEditingController();
  String _wardSearchQuery = '';
  List<Map<String, dynamic>>? _cachedWards;
  bool _isLoadingWards = false;
  String? _lastDistrictIdForWards;

  @override
  void dispose() {
    _districtSearchController.dispose();
    _wardSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level;
    _stateId = widget.parentId;
    _stateName = widget.parentName;
  }

  String _getCurrentParentName() {
    switch (_currentLevel) {
      case 'STATE':
        return _stateName;
      case 'DISTRICT':
        return _stateName;
      case 'WARD':
        return _selectedDistrictName ?? _stateName;
      default:
        return _stateName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            _buildHierarchyHeader(),
            _buildLevelTabs(),
            Expanded(child: _buildDiscoveryContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchyHeader() {
    String subTitle = '';
    if (_currentLevel == 'STATE') {
      subTitle = 'National level communities in $_stateName';
    }
    if (_currentLevel == 'DISTRICT') {
      subTitle = 'Explore districts in $_stateName';
    }
    if (_currentLevel == 'WARD') {
      subTitle = 'Explore wards in ${_selectedDistrictName ?? _stateName}';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 70.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BouncingWrapper(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCurrentParentName(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      subTitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.6),
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

  Widget _buildLevelTabs() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      padding: EdgeInsets.all(6.r),
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
      child: Row(
        children: _levels.map((lvl) {
          final isSelected = _currentLevel == lvl;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentLevel = lvl),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    lvl,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiscoveryContent() {
    if (_currentLevel == 'STATE') {
      return _buildCommunityListContent(
        filters: {'level': 'STATE', 'stateId': _stateId},
        title: 'State Level Communities in $_stateName',
        emptyMessage: 'No communities found in this state',
        emptyActionLabel: 'Create Community in $_stateName',
      );
    }

    if (_currentLevel == 'DISTRICT') {
      if (_selectedDistrictId == null) {
        return _buildModernDistrictSelection(
          title: 'Select District in $_stateName',
          onSelect: (id, name) {
            setState(() {
              _selectedDistrictId = id;
              _selectedDistrictName = name;
            });
          },
        );
      } else {
        return Column(
          children: [
            _buildSelectionHeader('District: $_selectedDistrictName', () {
              setState(() {
                _selectedDistrictId = null;
                _selectedDistrictName = null;
                _selectedWardId = null;
                _selectedWardName = null;
              });
            }),
            Expanded(
              child: _buildCommunityListContent(
                filters: {
                  'level': 'DISTRICT',
                  'stateId': _stateId,
                  'districtId': _selectedDistrictId!,
                },
                title: 'Communities in $_selectedDistrictName',
                emptyMessage: 'No communities found in this district',
                emptyActionLabel: 'Create Community in $_selectedDistrictName',
              ),
            ),
          ],
        );
      }
    }

    if (_currentLevel == 'WARD') {
      if (_selectedDistrictId == null) {
        return _buildEmptyStateWithIcon(
          Icons.location_city_rounded,
          'Please select a district first',
          'Go to District tab to make a selection',
        );
      }

      if (_selectedWardId == null) {
        return _buildModernWardSelection(
          title: 'Select Ward in $_selectedDistrictName',
          onSelect: (id, name) {
            setState(() {
              _selectedWardId = id;
              _selectedWardName = name;
            });
          },
        );
      } else {
        return Column(
          children: [
            _buildSelectionHeader('Ward: $_selectedWardName', () {
              setState(() {
                _selectedWardId = null;
                _selectedWardName = null;
              });
            }),
            Expanded(
              child: _buildCommunityListContent(
                filters: {
                  'level': 'WARD',
                  'stateId': _stateId,
                  'districtId': _selectedDistrictId!,
                  'wardId': _selectedWardId!,
                },
                title: 'Communities in $_selectedWardName',
                emptyMessage: 'No communities found in this ward',
                emptyActionLabel: 'Create Community in $_selectedWardName',
              ),
            ),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildSelectionHeader(String label, VoidCallback onClear) {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: AppColors.primaryBlue,
            size: 16.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          BouncingWrapper(
            onTap: onClear,
            child: Icon(
              Icons.cancel_rounded,
              color: AppColors.primaryBlue,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityListContent({
    required Map<String, String> filters,
    required String title,
    required String emptyMessage,
    required String emptyActionLabel,
  }) {
    return FutureBuilder<List<CommunityDetailsEntity>>(
      key: ValueKey(filters.toString()),
      future: sl<GetAvailableOwnerCommunitiesUseCase>().call(filters: filters),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        final items = snapshot.data ?? [];

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 16.h),
              if (items.isEmpty)
                _buildEmptyStateFlow(emptyMessage, emptyActionLabel)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _buildEnhancedCommunityCard(items[index]),
                ),
              SizedBox(height: 32.h),
              _buildCreateOption(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateFlow(String message, String actionLabel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_3_rounded,
              size: 40.sp,
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 24.h),
          BouncingWrapper(
            onTap: () => _openCreateModal(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ensureDistrictsLoaded() async {
    if (_cachedDistricts != null || _isLoadingDistricts) {
      return;
    }

    setState(() => _isLoadingDistricts = true);
    try {
      final results = await sl<GetAssociationsUseCase>().call(
        parentId: _stateId,
        level: 'DISTRICT',
      );
      if (mounted) {
        setState(() {
          _cachedDistricts = results;
          _isLoadingDistricts = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDistricts = false);
    }
  }

  Future<void> _ensureWardsLoaded() async {
    if (_selectedDistrictId == null) {
      return;
    }
    if (_cachedWards != null &&
        _lastDistrictIdForWards == _selectedDistrictId) {
      return;
    }

    setState(() {
      _isLoadingWards = true;
      _lastDistrictIdForWards = _selectedDistrictId;
    });

    try {
      final results = await sl<GetAssociationsUseCase>().call(
        parentId: _selectedDistrictId!,
        level: 'WARD',
      );
      if (mounted) {
        setState(() {
          _cachedWards = results;
          _isLoadingWards = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingWards = false);
    }
  }

  Widget _buildModernDistrictSelection({
    required String title,
    required Function(String id, String name) onSelect,
  }) {
    if (_cachedDistricts == null && !_isLoadingDistricts) {
      _ensureDistrictsLoaded();
    }

    if (_isLoadingDistricts) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    final items = (_cachedDistricts ?? []).where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final matchesSearch = name.contains(_districtSearchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Column(
      children: [
        _buildDistrictSearchAndFilters(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select District',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                if (items.isEmpty)
                  _buildEmptyStateFlow(
                    'No districts found',
                    'Be the first to create a community here',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 60.w,
                    ),
                    itemBuilder: (context, index) =>
                        _buildDistrictListItem(items[index], onSelect),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictSearchAndFilters() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _districtSearchController,
          onChanged: (val) => setState(() => _districtSearchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search district',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primaryBlue,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 15.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernWardSelection({
    required String title,
    required Function(String id, String name) onSelect,
  }) {
    if ((_cachedWards == null ||
            _lastDistrictIdForWards != _selectedDistrictId) &&
        !_isLoadingWards) {
      _ensureWardsLoaded();
    }

    if (_isLoadingWards) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    final items = (_cachedWards ?? []).where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final matchesSearch = name.contains(_wardSearchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Column(
      children: [
        _buildWardSearchAndFilters(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Ward',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 4.h),
                if (items.isEmpty)
                  _buildEmptyStateFlow(
                    'No wards found',
                    'Be the first to create a community here',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 60.w,
                    ),
                    itemBuilder: (context, index) =>
                        _buildWardListItem(items[index], onSelect),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWardSearchAndFilters() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _wardSearchController,
          onChanged: (val) => setState(() => _wardSearchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search ward',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primaryBlue,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 15.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWardListItem(
    Map<String, dynamic> ward,
    Function(String id, String name) onSelect,
  ) {
    final String name = ward['name'] ?? 'Unknown';
    final String id = (ward['_id'] ?? ward['id'] ?? '').toString();

    return ListTile(
      onTap: () => onSelect(id, name),
      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      leading: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.maps_home_work_rounded,
            color: AppColors.primaryBlue,
            size: 22.sp,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
      ),
      subtitle: Text(
        'Find local community',
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildDistrictListItem(
    Map<String, dynamic> district,
    Function(String id, String name) onSelect,
  ) {
    final String name = district['name'] ?? 'Unknown';
    final String id = (district['_id'] ?? district['id'] ?? '').toString();

    return ListTile(
      onTap: () => onSelect(id, name),
      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      leading: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.location_on_rounded,
            color: AppColors.primaryBlue,
            size: 22.sp,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
      ),
      subtitle: Text(
        'Explore local communities',
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildEmptyStateWithIcon(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleJoin(String communityId) async {
    try {
      await sl<JoinOwnerCommunityUseCase>().call(communityId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Joined community successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(GlobalErrorMapper.map(e).message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEnhancedCommunityCard(CommunityDetailsEntity item) {
    final String itemId = item.id;
    final String name = item.name;
    final String? imageUrl = item.image;
    final int memberCount = item.memberCount;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                _buildCommunityAvatar(name, imageUrl),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              _currentLevel,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            size: 14.sp,
                            color: AppColors.greyText,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$memberCount Members',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.greyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: [
                if (_currentLevel != 'WARD')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleDrillDown(itemId, name),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Explore ${_getNextLevel()}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                if (_currentLevel != 'WARD') SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleJoin(itemId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Join Now',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CommunityDetailPage(communityId: itemId),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'View Profile',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityAvatar(String name, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final url = ApiConstants.getImageUrl(imageUrl);
      if (url != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 54.r,
            height: 54.r,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _buildDefaultAvatar(name),
          ),
        );
      }
    }
    return _buildDefaultAvatar(name);
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      width: 54.r,
      height: 54.r,
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'C',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.accentOrange,
          ),
        ),
      ),
    );
  }

  void _openCreateModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAssociationModal(
        allStates: widget.allStates,
        initialStateId: _stateId,
        initialStateName: _stateName,
        initialDistrictId: _selectedDistrictId,
        initialWardId: _selectedWardId,
      ),
    );
  }

  Widget _buildCreateOption() {
    bool canCreate = false;
    if (_currentLevel == 'STATE') {
      canCreate = true;
    }
    if (_currentLevel == 'DISTRICT' && _selectedDistrictId != null) {
      canCreate = true;
    }
    if (_currentLevel == 'WARD' && _selectedWardId != null) {
      canCreate = true;
    }

    if (!canCreate) return const SizedBox.shrink();

    return BouncingWrapper(
      onTap: _openCreateModal,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primaryBlue, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primaryBlue,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'Create New Community',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextLevel() {
    if (_currentLevel == 'STATE') return 'Districts';
    if (_currentLevel == 'DISTRICT') return 'Wards';
    return '';
  }

  void _handleDrillDown(String itemId, String itemName) {
    setState(() {
      if (_currentLevel == 'STATE') {
        _currentLevel = 'DISTRICT';
      } else if (_currentLevel == 'DISTRICT') {
        _selectedDistrictId = itemId;
        _selectedDistrictName = itemName;
        _currentLevel = 'WARD';
      }
    });
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
