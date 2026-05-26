import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_state.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/tenant_card.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/maintenance_tab_view.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/notices_tab_view.dart';
import 'package:stayindia_owner/features/notices/presentation/pages/give_notice_page.dart';
import 'package:stayindia_owner/features/notices/presentation/cubit/notice_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/add_tenant_page.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/past_tenants_sheet.dart';
import 'package:stayindia_owner/core/widgets/shimmer_loading.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/widgets/pattern_background.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';

import 'package:stayindia_owner/features/communities/presentation/pages/tenants_chat_page.dart';

class TenantsPage extends StatefulWidget {
  const TenantsPage({super.key});

  @override
  State<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_selectedTabIndex == 0) {
        final hostelId = context.read<HostelCubit>().state.selectedHostelId;
        if (hostelId != null) {
          context.read<TenantCubit>().loadMoreTenants(hostelId);
        }
      }
    }
  }

  void _loadData() {
    final hostelId = context.read<HostelCubit>().state.selectedHostelId;
    if (hostelId != null) {
      context.read<TenantCubit>().loadTenants(hostelId);
      context.read<NoticeCubit>().loadNotices(hostelId: hostelId);
      try {
        context.read<DashboardCubit>().fetchDashboardData(hostelId);
      } catch (e) {
        debugPrint('Error refreshing dashboard in TenantsPage: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: PatternBackground(
        child: SafeArea(
          child: BlocListener<HostelCubit, HostelState>(
            listenWhen: (prev, curr) =>
                (prev is! HostelLoaded && curr is HostelLoaded) ||
                (prev is HostelLoaded &&
                    curr is HostelLoaded &&
                    prev.selectedHostelIndex != curr.selectedHostelIndex),
            listener: (context, state) => _loadData(),
            child: BlocListener<TenantCubit, TenantState>(
              listener: (context, state) {
                if (state is TenantLoaded && state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                }
              },
              child: RefreshIndicator(
                onRefresh: () async => _loadData(),
                color: AppColors.primaryBlue,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    _buildAppHeader(),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverHeaderDelegate(
                        height: 56.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.scaffoldBackground.withValues(
                              alpha: 0.9,
                            ),
                          ),
                          child: _buildTabBar(),
                        ),
                      ),
                    ),
                    if (_selectedTabIndex == 0)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                        sliver: SliverToBoxAdapter(
                          child: _buildControlBar(context),
                        ),
                      ),
                    ..._buildSliverContent(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context) != null
          ? Padding(
              padding: EdgeInsets.only(
                bottom: 10.h + MediaQuery.of(context).padding.bottom,
              ),
              child: _buildFAB(context),
            )
          : null,
    );
  }

  Widget _buildAppHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tenants_title'.tr(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'tenants_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            BouncingWrapper(
              onTap: () {
                String hostelId = '';
                final hostelState = context.read<HostelCubit>().state;
                if (hostelState is HostelLoaded &&
                    hostelState.hostels.isNotEmpty) {
                  hostelId =
                      hostelState.hostels[hostelState.selectedHostelIndex].id;
                }
                if (hostelId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.white, size: 16.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              "No hostels found. Please add a hostel and check-in tenants to view the Tenants Community.",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  return;
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
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forum_rounded,
                      size: 15.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Community',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            BouncingWrapper(
              onTap: () => _loadData(),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'tab_tenants'.tr(), Icons.group_rounded),
          _buildTabItem(1, 'tab_services'.tr(), Icons.build_rounded),
          _buildTabItem(
            2,
            'tab_notices'.tr(),
            Icons.notification_important_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 11.sp,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
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

  Widget _buildControlBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      final hostelState = context.read<HostelCubit>().state;
                      if (hostelState is HostelLoaded &&
                          hostelState.hostels.isNotEmpty) {
                        final hostelId = hostelState
                            .hostels[hostelState.selectedHostelIndex]
                            .id;
                        context.read<TenantCubit>().searchTenants(
                          hostelId,
                          value,
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'search_residents'.tr(),
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        _buildControlAction(
          Icons.history_rounded,
          () => PastTenantsSheet.show(context),
          isActive: true,
        ),
      ],
    );
  }

  Widget _buildControlAction(
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        height: 42.h,
        width: 42.w,
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          border: Border.all(
            color: isActive
                ? AppColors.primaryBlue.withValues(alpha: 0.3)
                : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
          size: 18.sp,
        ),
      ),
    );
  }

  List<Widget> _buildSliverContent(BuildContext context) {
    if (_selectedTabIndex == 1) {
      return [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          sliver: const SliverToBoxAdapter(child: MaintenanceTabView()),
        ),
      ];
    }
    if (_selectedTabIndex == 2) {
      return [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          sliver: const SliverToBoxAdapter(child: NoticesTabView()),
        ),
      ];
    }

    return [
      BlocBuilder<HostelCubit, HostelState>(
        builder: (context, hostelState) {
          if (hostelState is HostelLoaded && hostelState.hostels.isEmpty) {
            return SliverFillRemaining(
              child: _buildEmptyState(
                icon: Icons.add_business_rounded,
                title: 'add_property_first'.tr(),
                message: 'start_by_adding_property_desc'.tr(),
              ),
            );
          }

          return BlocBuilder<TenantCubit, TenantState>(
            builder: (context, state) {
              if (state is TenantLoading) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const TenantCardSkeleton(),
                      childCount: 5,
                    ),
                  ),
                );
              }

              if (state is TenantError) {
                final bool isForbidden =
                    state.message.toLowerCase().contains('not allowed') ||
                    state.message.toLowerCase().contains('forbidden');

                return SliverFillRemaining(
                  child: _buildEmptyState(
                    icon: isForbidden
                        ? Icons.lock_person_rounded
                        : Icons.error_outline_rounded,
                    title: isForbidden
                        ? 'access_denied'.tr()
                        : 'something_wrong'.tr(),
                    message: isForbidden
                        ? 'access_denied_msg'.tr()
                        : state.message,
                  ),
                );
              }

              if (state is TenantEmpty || state is TenantInitial) {
                return SliverFillRemaining(
                  child: _buildEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'no_residents_found'.tr(),
                    message:
                        (state is TenantEmpty ? state.message : null) ??
                        'no_residents_desc'.tr(),
                  ),
                );
              }

              if (state is TenantLoaded) {
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 140.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < state.tenants.length) {
                          return TenantCard(tenant: state.tenants[index]);
                        }
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        );
                      },
                      childCount:
                          state.tenants.length + (state.isLoadMore ? 1 : 0),
                    ),
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          );
        },
      ),
    ];
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 100.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64.sp,
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFAB(BuildContext context) {
    if (_selectedTabIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTenantPage()),
          );
          if (!context.mounted) return;
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 8,
        icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
        label: Text(
          'add_tenant'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      );
    } else if (_selectedTabIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GiveNoticePage()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 8,
        icon: Icon(
          Icons.assignment_late_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
        label: Text(
          'move_out_notice'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      );
    }
    return null;
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _SliverHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
