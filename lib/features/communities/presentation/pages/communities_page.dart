import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/tenants_chat_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/owners_community_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/association_intro_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/personal_chat_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/owners_list_page.dart';

class CommunitiesPage extends StatefulWidget {
  const CommunitiesPage({super.key});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  String _getHostelId() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 80.h,
          leading: const SizedBox.shrink(),
          leadingWidth: 0,
          title: Text(
            'Community',
            style: GoogleFonts.outfit(
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
              fontSize: 26.sp,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TabBar(
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.darkText,
                  unselectedLabelColor: AppColors.greyText.withValues(
                    alpha: 0.5,
                  ),
                  labelStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                  ),
                  unselectedLabelStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.only(right: 32.w),
                  tabs: const [
                    Tab(text: 'Owners Hub'),
                    Tab(text: 'Personal Chats'),
                    Tab(text: 'Tenants Chat'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: TabBarView(children: [
            _buildOwnersTab(),
            const _PersonalChatsTab(),
            _buildTenantsTab()
          ]),
        ),
      ),
    );
  }

  Widget _buildOwnersTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAssociationBanner(),
          SizedBox(height: 24.h),
          _buildOwnersHeroCard(),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Business Networking',
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.amber,
                size: 18.sp,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildCompactFeature(
            icon: Icons.trending_up_rounded,
            title: 'Market Trends',
            color: const Color(0xFF0EA5E9),
          ),
          _buildCompactFeature(
            icon: Icons.policy_rounded,
            title: 'Legal Compliance',
            color: const Color(0xFF6366F1),
          ),
          _buildCompactFeature(
            icon: Icons.groups_3_rounded,
            title: 'Staff Hiring',
            color: const Color(0xFF8B5CF6),
          ),
          SizedBox(height: 24.h),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildTenantsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primaryBlue,
              size: 40.sp,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Direct Access to Tenants',
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Keep your community active and informed.\nBroadcast notices instantly to everyone.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              color: AppColors.greyText,
              height: 1.5,
            ),
          ),
          SizedBox(height: 48.h),
          BouncingWrapper(
            onTap: () {
              final hostelId = _getHostelId();
              if (hostelId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TenantsChatPage(hostelId: hostelId),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Enter Community Chat',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFeature({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 16.w),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.greyText.withValues(alpha: 0.3),
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildOwnersHeroCard() {
    return BouncingWrapper(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OwnersCommunityPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.amber,
                        size: 12.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'OWNER EXCLUSIVE',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 20.sp,
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Owners Hub',
              style: GoogleFonts.outfit(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Network with verified property owners,\nshare insights and grow your business.',
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
            SizedBox(height: 28.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Join Discussion',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryBlue,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Join discussions to improve your property management.',
              style: GoogleFonts.outfit(
                fontSize: 13.sp,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssociationBanner() {
    return BouncingWrapper(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssociationIntroPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2C5990).withValues(alpha: 0.08),
              const Color(0xFFF98125).withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFF2C5990).withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: const BoxDecoration(
                color: Color(0xFF2C5990),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.handshake_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay India Association',
                    style: GoogleFonts.outfit(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2C5990),
                    ),
                  ),
                  Text(
                    'Why Join Us? Learn the benefits.',
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF98125),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF2C5990).withValues(alpha: 0.3),
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalChatsTab extends StatefulWidget {
  const _PersonalChatsTab();

  @override
  State<_PersonalChatsTab> createState() => _PersonalChatsTabState();
}

class _PersonalChatsTabState extends State<_PersonalChatsTab> {
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatsList();
  }

  Future<void> _fetchChatsList() async {
    try {
      final dio = sl<Dio>();
      final response = await dio.get('${ApiConstants.baseUrl}${ApiConstants.ownerCommunities}/personal-chat/list');
      if (response.statusCode == 200) {
        final List<dynamic> fetched = response.data['data'] ?? [];
        if (mounted) {
          setState(() {
            _chats = List<Map<String, dynamic>>.from(fetched);
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Error fetching personal chats list: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatChatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final min = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
        return '$hour:$min $ampm';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    if (_chats.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchChatsList,
      color: AppColors.primaryBlue,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: _chats.length,
        separatorBuilder: (context, index) => Divider(height: 1.h, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final avatarUrl = chat['avatar'] as String?;
          final name = chat['name'] as String? ?? 'PG Owner';
          final lastMsg = chat['lastMessage']?['text'] as String? ?? 'No messages yet';
          final time = _formatChatTime(chat['lastMessage']?['createdAt']);

          return BouncingWrapper(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PersonalChatPage(
                    chatId: chat['id'],
                    otherUserName: name,
                    otherUserAvatar: avatarUrl ?? '',
                    isOnline: chat['isOnline'] ?? false,
                  ),
                ),
              );
              _fetchChatsList(); // Refresh on return
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? CachedNetworkImageProvider(ApiConstants.getImageUrl(avatarUrl)!)
                        : null,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.08),
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 26.sp)
                        : null,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.outfit(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            if (time.isNotEmpty)
                              Text(
                                time,
                                style: GoogleFonts.outfit(
                                  fontSize: 10.sp,
                                  color: AppColors.greyText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          lastMsg,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _fetchChatsList,
      color: AppColors.primaryBlue,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.forum_outlined, size: 48.sp, color: AppColors.primaryBlue),
                ),
                SizedBox(height: 24.h),
                Text(
                  'No Chats Yet',
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Start messaging with verified property owners\nin the Global Community directory.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: const Icon(Icons.search_rounded),
                  label: Text('Find Owners', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OwnersListPage()),
                    );
                    _fetchChatsList();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
