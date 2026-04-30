import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/tenants_chat_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/community_detail_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/association_selection_page.dart';

class OwnersCommunityPage extends StatefulWidget {
  const OwnersCommunityPage({super.key});

  @override
  State<OwnersCommunityPage> createState() => _OwnersCommunityPageState();
}

class _OwnersCommunityPageState extends State<OwnersCommunityPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OwnerCommunityCubit>().loadCommunities();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AssociationSelectionPage()),
          ),
          backgroundColor: AppColors.primaryBlue,
          icon: const Icon(Icons.explore_rounded, color: Colors.white),
          label: Text(
            'Join Association',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        body: BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
          builder: (context, state) {
            if (state is OwnerCommunityLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OwnerCommunityLoaded) {
              return FadeInWrapper(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    _buildSliverAppBar(),
                  ],
                  body: Column(
                    children: [
                      if (state.pendingRequests.isNotEmpty)
                        _PendingRequestsSection(requests: state.pendingRequests),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildJoinedTab(state.joinedCommunities),
                            _buildDiscoverTab(state.availableCommunities),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is OwnerCommunityError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48.sp, color: Colors.red.shade300),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(color: AppColors.greyText),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () => context.read<OwnerCommunityCubit>().loadCommunities(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: TabBar(
            indicatorColor: AppColors.primaryBlue,
            indicatorWeight: 3,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.greyText,
            labelStyle: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w800),
            unselectedLabelStyle: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'My Communities'),
              Tab(text: 'Discover'),
            ],
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(24.w, 105.h, 24.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.groups_rounded, color: AppColors.primaryBlue, size: 28.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'Owners Community',
                    style: GoogleFonts.outfit(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w900,
                      fontSize: 26.sp,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Connect, share & grow with other owners',
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  color: AppColors.greyText.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinedTab(List<CommunityDetailsEntity> joinedCommunities) {
    if (joinedCommunities.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 80.h),
      itemCount: joinedCommunities.length,
      itemBuilder: (context, index) {
        return _CommunityCard(community: joinedCommunities[index]);
      },
    );
  }

  Widget _buildDiscoverTab(List<CommunityDetailsEntity> communities) {
    final filteredCommunities = communities.where((c) {
      final query = _searchController.text.toLowerCase();
      return c.name.toLowerCase().contains(query) || 
             (c.description?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
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
              decoration: InputDecoration(
                hintText: 'Search communities...',
                hintStyle: GoogleFonts.outfit(
                  color: AppColors.greyText.withValues(alpha: 0.5),
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.greyText, size: 20.sp),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, size: 18.sp, color: AppColors.greyText),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredCommunities.isEmpty
              ? _buildDiscoverEmptyState(communities.isEmpty)
              : ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: filteredCommunities.length,
                  itemBuilder: (context, index) {
                    return _AvailableCommunityItem(community: filteredCommunities[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDiscoverEmptyState(bool isTotalEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isTotalEmpty ? Icons.explore_off_rounded : Icons.search_off_rounded,
            size: 64.sp,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: 16.h),
          Text(
            isTotalEmpty ? 'No new communities to join' : 'No results found',
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.greyText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isTotalEmpty 
              ? 'You are already in all active communities.'
              : 'Try searching with a different keyword.',
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: AppColors.greyText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(
            File('/Users/koushiksoftwaresolutions/.gemini/antigravity/brain/2b806fb1-9265-4248-9f98-b19af01fbcf5/community_empty_state_illustration_1777380448859.png'),
            height: 160.h, 
          ),
          SizedBox(height: 24.h),
          Text(
            'No communities yet',
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Join your local PG association to connect with other owners and access legal support.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: AppColors.greyText.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssociationSelectionPage())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: Size(double.infinity, 54.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
            ),
            child: Text(
              'Join Association',
              style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityDetailsEntity community;

  const _CommunityCard({required this.community});

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TenantsChatPage(
              hostelId: community.id,
              communityName: community.name,
              communityIcon: community.image,
              communityDescription: community.description,
              isOwnerChat: true,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.grey.shade50),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.r),
                image: community.image != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(community.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: community.image == null
                  ? Icon(Icons.groups_2_rounded, color: AppColors.primaryBlue, size: 28.sp)
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    community.description ?? 'No description provided.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: AppColors.greyText.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 14.sp, color: AppColors.primaryBlue),
                      SizedBox(width: 4.w),
                      Text(
                        '${community.memberCount} members',
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
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
    );
  }
}

class _JoinCommunitySheet extends StatefulWidget {
  const _JoinCommunitySheet();

  @override
  State<_JoinCommunitySheet> createState() => _JoinCommunitySheetState();
}

class _JoinCommunitySheetState extends State<_JoinCommunitySheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          Text(
            'Available Communities',
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search communities...',
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
      builder: (context, state) {
        if (state is OwnerCommunityLoaded) {
          final communities = state.availableCommunities.where((c) => 
            c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          if (communities.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(24.w),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return _AvailableCommunityItem(community: community);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64.sp, color: Colors.grey.shade200),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isEmpty ? 'No communities available' : 'No communities found',
            style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }
}

class _AvailableCommunityItem extends StatelessWidget {
  final CommunityDetailsEntity community;

  const _AvailableCommunityItem({required this.community});

  @override
  Widget build(BuildContext context) {
    final isPending = community.status == 'PENDING';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14.r),
              image: community.image != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(community.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: community.image == null
                ? Icon(Icons.groups_3_rounded, color: AppColors.primaryBlue, size: 24.sp)
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommunityDetailPage(communityId: community.id),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
                  ),
                  Text(
                    '${community.memberCount} members',
                    style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isPending ? null : () {
              context.read<OwnerCommunityCubit>().joinCommunity(community.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Join request sent!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPending ? Colors.grey.shade100 : AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              isPending ? 'Requested' : 'Join', 
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700, 
                color: isPending ? AppColors.greyText : Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingRequestsSection extends StatelessWidget {
  final List<Map<String, dynamic>> requests;

  const _PendingRequestsSection({required this.requests});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.03),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'NEW',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Join Requests',
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              scrollDirection: Axis.horizontal,
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final community = requests[index];
                final communityId = community['communityId'];
                final communityName = community['communityName'];
                final userRequests = community['requests'] as List;

                return Row(
                  children: userRequests.map((req) {
                    return Container(
                      margin: EdgeInsets.only(right: 12.w),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18.r,
                            backgroundImage: req['profileImage'] != null
                                ? CachedNetworkImageProvider(req['profileImage'])
                                : null,
                            child: req['profileImage'] == null
                                ? const Icon(Icons.person, size: 20)
                                : null,
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                req['name'],
                                style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'to $communityName',
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: AppColors.greyText,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12.w),
                          Row(
                            children: [
                              _ActionBtn(
                                icon: Icons.check_rounded,
                                color: Colors.green,
                                onTap: () => context.read<OwnerCommunityCubit>().handleJoinRequest(
                                      communityId,
                                      req['userId'],
                                      'ACCEPT',
                                    ),
                              ),
                              SizedBox(width: 8.w),
                              _ActionBtn(
                                icon: Icons.close_rounded,
                                color: Colors.red,
                                onTap: () => context.read<OwnerCommunityCubit>().handleJoinRequest(
                                      communityId,
                                      req['userId'],
                                      'REJECT',
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 16.sp),
      ),
    );
  }
}

class FadeInWrapper extends StatefulWidget {
  final Widget child;
  const FadeInWrapper({super.key, required this.child});

  @override
  State<FadeInWrapper> createState() => _FadeInWrapperState();
}

class _FadeInWrapperState extends State<FadeInWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
