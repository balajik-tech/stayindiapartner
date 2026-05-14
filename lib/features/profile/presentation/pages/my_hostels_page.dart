import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/widgets/shimmer_loading.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/property_setup/presentation/pages/property_setup_stepper_page.dart';

class MyHostelsPage extends StatefulWidget {
  const MyHostelsPage({super.key});

  @override
  State<MyHostelsPage> createState() => _MyHostelsPageState();
}

class _MyHostelsPageState extends State<MyHostelsPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          if (state is HostelLoading) {
            return _buildLoadingState();
          } else if (state is HostelError) {
            return _buildErrorState(state.message);
          } else if (state is HostelLoaded) {
            final filteredHostels = state.hostels
                .where((h) => h.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                             h.address.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            if (filteredHostels.isEmpty && _searchQuery.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => context.read<HostelCubit>().getHostels(),
              color: AppColors.primaryBlue,
              strokeWidth: 3,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final hostel = filteredHostels[index];
                          return _StaggeredEntry(
                            delayMs: index * 100,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: _PremiumHostelCard(
                                name: hostel.name,
                                address: hostel.address,
                                floors: hostel.floors,
                                occupied: hostel.occupiedBeds ?? 0,
                                total: hostel.totalBeds ?? 0,
                                onTap: () {
                                  
                                },
                              ),
                            ),
                          );
                        },
                        childCount: filteredHostels.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      // FAB Removed as per requirements (moved to Dashboard)
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'My Hostels',
        style: TextStyle(
          color: AppColors.darkText,
          fontSize: 18.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
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
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search by name or area...',
            hintStyle: TextStyle(color: AppColors.greyText.withValues(alpha: 0.6), fontSize: 14.sp),
            border: InputBorder.none,
            icon: Icon(Icons.search_rounded, color: AppColors.primaryBlue, size: 20.sp),
            suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18), 
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    }
                  ) 
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: 4,
      itemBuilder: (context, index) => const PropertyCardSkeleton(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48.sp),
          SizedBox(height: 16.h),
          Text(message, style: TextStyle(color: AppColors.greyText, fontSize: 14.sp)),
          TextButton(
            onPressed: () => context.read<HostelCubit>().getHostels(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.apartment_rounded, size: 64.sp, color: AppColors.primaryBlue.withValues(alpha: 0.3)),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Hostels Registered',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Register your first property to start managing floors, rooms and tenants.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.greyText, height: 1.5),
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PropertySetupStepperPage())),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add My First Hostel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
            ),
          ),
        ],
      ),
    );
  }

}

class _PremiumHostelCard extends StatelessWidget {
  final String name;
  final String address;
  final int floors;
  final int occupied;
  final int total;
  final VoidCallback onTap;

  const _PremiumHostelCard({
    required this.name,
    required this.address,
    required this.floors,
    required this.occupied,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double occupancyRate = total > 0 ? (occupied / total) : 0;
    
    Color occupancyColor = const Color(0xFF099268); 
    if (occupancyRate >= 0.9) {
      occupancyColor = const Color(0xFFE03131); 
    } else if (occupancyRate >= 0.6) {
      occupancyColor = const Color(0xFFF08C00); 
    }

    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.apartment_rounded,
                    color: AppColors.primaryBlue,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 12.sp, color: AppColors.greyText.withValues(alpha: 0.6)),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              address,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.greyText.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                _buildStatBadge(
                  icon: Icons.layers_rounded,
                  label: '$floors Floors',
                  color: Colors.grey.shade700,
                ),
                SizedBox(width: 12.w),
                _buildStatBadge(
                  icon: Icons.people_rounded,
                  label: '$occupied/$total Beds',
                  color: occupancyColor,
                  isColored: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required Color color,
    bool isColored = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isColored ? color.withValues(alpha: 0.08) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isColored ? color.withValues(alpha: 0.1) : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredEntry extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _StaggeredEntry({required this.child, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
