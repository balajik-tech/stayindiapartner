import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_state.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/tenant_card.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/maintenance_tab_view.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/notices_tab_view.dart';
import 'package:stayindia_owner/features/notices/presentation/pages/give_notice_page.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/add_tenant_page.dart';
import 'package:stayindia_owner/features/tenants/presentation/widgets/past_tenants_sheet.dart';
import 'package:stayindia_owner/core/widgets/shimmer_loading.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/widgets/pattern_background.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_selectedTabIndex == 0) {
        final hostelState = context.read<HostelCubit>().state;
        if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
          final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
          context.read<TenantCubit>().loadMoreTenants(hostelId);
        }
      }
    }
  }

  void _loadData() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      context.read<TenantCubit>().loadTenants(hostelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: PatternBackground(
        child: SafeArea(
          child: BlocListener<TenantCubit, TenantState>(
            listener: (context, state) {
              if (state is TenantLoaded && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                );
              }
            },
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              color: AppColors.primaryBlue,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  _buildAppHeader(),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverHeaderDelegate(
                      height: 80.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground.withValues(alpha: 0.9),
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
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: _buildFAB(context),
      ),
    );
  }

  Widget _buildAppHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(8.w, 12.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        ),
        child: Row(
          children: [
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tenants',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Manage property residents',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            BouncingWrapper(
              onTap: () => _loadData(),
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.refresh_rounded, size: 22.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Tenants', Icons.group_rounded),
          _buildTabItem(1, 'Services', Icons.build_rounded),
          _buildTabItem(2, 'Notices', Icons.notification_important_rounded),
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
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
            height: 54.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.textSecondary.withValues(alpha: 0.6), size: 22.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      final hostelState = context.read<HostelCubit>().state;
                      if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
                        final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
                        context.read<TenantCubit>().searchTenants(hostelId, value);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search residents...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.4), 
                        fontSize: 14.sp, 
                        fontWeight: FontWeight.w500
                      ),
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        _buildControlAction(Icons.history_rounded, () => PastTenantsSheet.show(context), isActive: true),
      ],
    );
  }

  Widget _buildControlAction(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        height: 52.h,
        width: 52.w,
        decoration: BoxDecoration(
          color: AppColors.backgroundPrimary,
          border: Border.all(color: isActive ? AppColors.primaryBlue.withValues(alpha: 0.3) : AppColors.border),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: isActive ? AppColors.primaryBlue : AppColors.textSecondary, size: 22.sp),
      ),
    );
  }

  List<Widget> _buildSliverContent(BuildContext context) {
    if (_selectedTabIndex == 1) {
      return [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          sliver: const SliverToBoxAdapter(child: MaintenanceTabView()),
        )
      ];
    }
    if (_selectedTabIndex == 2) {
      return [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          sliver: const SliverToBoxAdapter(child: NoticesTabView()),
        )
      ];
    }

    return [
      BlocBuilder<TenantCubit, TenantState>(
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
            return SliverFillRemaining(
              child: _buildEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Something went wrong',
                message: state.message,
              ),
            );
          }

          if (state is TenantEmpty) {
            return SliverFillRemaining(
              child: _buildEmptyState(
                icon: Icons.people_outline_rounded,
                title: 'No residents found',
                message: state.message ?? 'Start by adding your first tenant to this property.',
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
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue)),
                    );
                  },
                  childCount: state.tenants.length + (state.isLoadMore ? 1 : 0),
                ),
              ),
            );
          }

          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    ];
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String message}) {
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
            child: Icon(icon, size: 64.sp, color: AppColors.primaryBlue.withValues(alpha: 0.2)),
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
      return BouncingWrapper(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTenantPage()),
          );
        },
        child: FloatingActionButton.extended(
          onPressed: null, // Managed by BouncingWrapper
          backgroundColor: AppColors.accentOrange,
          elevation: 8,
          icon: Icon(Icons.add, color: Colors.white, size: 24.sp),
          label: Text(
            'Add Tenant',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      );
    } else if (_selectedTabIndex == 2) {
      return BouncingWrapper(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GiveNoticePage()),
          );
        },
        child: FloatingActionButton.extended(
          onPressed: null, // Managed by BouncingWrapper
          backgroundColor: AppColors.accentOrange,
          elevation: 8,
          icon: Icon(Icons.assignment_late_rounded, color: Colors.white, size: 22.sp),
          label: Text(
            'Give Notice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
