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
import 'package:stayindia_owner/core/constants/ui_constants.dart';

class TenantsPage extends StatefulWidget {
  const TenantsPage({super.key});

  @override
  State<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      backgroundColor: const Color(0xFFF8F9FA), 
      body: SafeArea(
        child: BlocListener<TenantCubit, TenantState>(
          listener: (context, state) {
            if (state is TenantLoaded && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              );
            }
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppHeader(),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverHeaderDelegate(
                  height: 60.h,
                  child: Container(
                    color: const Color(0xFFF8F9FA),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: _buildTabBar(),
                  ),
                ),
              ),
              if (_selectedTabIndex == 0)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                  sliver: SliverToBoxAdapter(
                    child: _buildControlBar(context),
                  ),
                ),
              ..._buildSliverContent(context),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: UIConstants.bottomPadding(context)),
        child: _buildFAB(context),
      ),
    );
  }

  Widget _buildAppHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tenant Management',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Monitor and manage your property residents',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _buildHeaderAction(Icons.refresh_rounded, () => _loadData()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.roomCardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 20.sp, color: AppColors.darkText),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(14.r),
      ),
      padding: EdgeInsets.all(4.w),
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
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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
                color: isSelected ? AppColors.primaryBlue : AppColors.greyText,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.darkText : AppColors.greyText,
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
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.roomCardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.greyText, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      final hostelState = context.read<HostelCubit>().state;
                      if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
                        final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
                        context.read<TenantCubit>().searchTenants(hostelId, value);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search residents...',
                      hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        _buildControlAction(Icons.history_rounded, () => PastTenantsSheet.show(context), isActive: true),
        SizedBox(width: 8.w),
        _buildControlAction(Icons.tune_rounded, () {}),
      ],
    );
  }

  Widget _buildControlAction(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 52.h,
          width: 52.w,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.roomCardBorder),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(icon, color: isActive ? AppColors.primaryBlue : AppColors.darkText, size: 22.sp),
        ),
      ),
    );
  }

  List<Widget> _buildSliverContent(BuildContext context) {
    if (_selectedTabIndex == 1) {
      return [const SliverFillRemaining(child: MaintenanceTabView())];
    }
    if (_selectedTabIndex == 2) {
      return [const SliverFillRemaining(child: NoticesTabView())];
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
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, UIConstants.bottomPadding(context) + 20.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < state.tenants.length) {
                      return TenantCard(tenant: state.tenants[index]);
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64.sp, color: AppColors.primaryBlue.withValues(alpha: 0.3)),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTenantPage()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        icon: Icon(Icons.add, color: Colors.white, size: 22.sp),
        label: Text(
          'Add Tenant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
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
        elevation: 4,
        icon: Icon(Icons.assignment_late_rounded, color: Colors.white, size: 22.sp),
        label: Text(
          'Give Notice',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
