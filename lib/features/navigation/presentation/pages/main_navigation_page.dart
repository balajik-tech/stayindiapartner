import 'dart:async';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/property_setup/presentation/pages/property_setup_stepper_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/bookings/pages/bookings_page.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/tenants_page.dart';
import 'package:stayindia_owner/features/profile/presentation/pages/profile_page.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/communities_page.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/notices/presentation/cubit/notice_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:stayindia_owner/features/staff/presentation/cubit/staff_cubit.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import '../widgets/global_action_sheet.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/add_tenant_page.dart';
import 'package:stayindia_owner/features/profile/presentation/pages/floor_management_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;
  StreamSubscription? _bookingSubscription;
  String? _currentHostelId;
  
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializePages();
    _currentIndex = widget.initialIndex;
    _bookingSubscription = sl<SocketService>().bookingStream.listen(_onNewBooking);
  }

  void _initializePages() {
    if (_pages.isNotEmpty) return;
    _pages.addAll([
      const DashboardPage(key: ValueKey('dash_page')),
      const BookingsPage(key: ValueKey('book_page')),
      const CommunitiesPage(key: ValueKey('comm_page')),
      const TenantsPage(key: ValueKey('tenant_page')),
      const ProfilePage(key: ValueKey('profile_page')),
    ]);
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }

  void _onNewBooking(Map<String, dynamic> data) {
    if (!mounted) return;

    final tenantName = data['tenantName'] ?? 'New Tenant';
    final sharingType = data['sharingType'] ?? '';
    final amount = data['amount'] ?? 0;

    sl<NotificationService>().showNotification(
      id: DateTime.now().millisecond,
      title: 'New Booking Found! ',
      body: '$tenantName booked a $sharingType room ($amount)',
      payload: 'booking',
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New Booking: $tenantName booked a $sharingType room'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => setState(() => _currentIndex = 1),
        ),
      ),
    );

    if (_currentIndex == 0 && _currentHostelId != null) {
      context.read<DashboardCubit>().fetchDashboardData(_currentHostelId!);
    }
  }

  void _setupSocket(String hostelId) {
    if (hostelId.isEmpty) return;

    if (_currentHostelId != null) {
      sl<SocketService>().leaveCommunity(_currentHostelId!);
    }

    _currentHostelId = hostelId;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      sl<SocketService>().joinCommunity(hostelId, authState.owner.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<FinanceCubit>()..loadDashboard()),
      ],
      child: MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {}
          },
        ),
        BlocListener<BookingsCubit, BookingsState>(
          listener: (context, state) {
            if (state.status == BookingsStatus.success && 
               (state.successMessage?.contains('successfully') ?? false)) {
              final hostelState = context.read<HostelCubit>().state;
              if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
                final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
                context.read<DashboardCubit>().fetchDashboardData(hostelId);
                setState(() => _currentIndex = 0);
              }
            }
          },
        ),
        BlocListener<HostelCubit, HostelState>(
          listener: (context, state) {
            if (state is HostelLoaded && state.hostels.isNotEmpty) {
              final hostelId = state.hostels[state.selectedHostelIndex].id;

              if (hostelId == _currentHostelId) return;
              
              AppLogger.info('Hostel changed to: $hostelId. Syncing data...');

              context.read<CommunityCubit>().loadCommunityData(hostelId);
              _setupSocket(hostelId);
              _currentHostelId = hostelId;

              context.read<DashboardCubit>().fetchDashboardData(hostelId);
              context.read<BookingsCubit>().fetchBookings();
              context.read<TenantCubit>().loadTenants(hostelId);
              context.read<MaintenanceCubit>().loadIssues(hostelId: hostelId);
              context.read<NoticeCubit>().loadNotices(hostelId: hostelId);
              context.read<StaffCubit>().loadStaff(hostelId);
              context.read<OwnerCommunityCubit>().loadCommunities();
              context.read<FinanceCubit>().loadDashboard(hostelId: hostelId);
            }
          },
        ),
      ],
      child: BlocBuilder<HostelCubit, HostelState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, hostelState) {
          if (hostelState is HostelInitial || hostelState is HostelLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
            );
          }

          if (hostelState is HostelLoaded) {
            return Scaffold(
              extendBody: true,
              body: IndexedStack(
                index: _currentIndex >= _pages.length ? 0 : _currentIndex, 
                children: _pages,
              ),
              bottomNavigationBar: _PremiumNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  HapticFeedback.lightImpact();
                  setState(() => _currentIndex = index);
                },
              ),
              floatingActionButton: _currentIndex == 0 ? _buildPremiumFAB(context) : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          }

          return const Scaffold(
            body: Center(child: Text('Something went wrong. Please restart.')),
          );
        },
      ),
    ),
  );
}

  Widget _buildPremiumFAB(BuildContext context) {
    return BouncingWrapper(
      onTap: () {
        HapticFeedback.heavyImpact();
        final hostelState = context.read<HostelCubit>().state;
        Hostel? currentHostel;
        if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
          currentHostel = hostelState.hostels[hostelState.selectedHostelIndex];
        }

        GlobalActionSheet.show(
          context,
          onNewProperty: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PropertySetupStepperPage()),
            );
          },
          onAddFloor: () {
            if (currentHostel != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FloorManagementPage(hostel: currentHostel!),
                ),
              );
            } else {
              _showNoHostelError(context);
            }
          },
          onAddRoom: () {
            if (currentHostel != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FloorManagementPage(hostel: currentHostel!),
                ),
              );
            } else {
              _showNoHostelError(context);
            }
          },
          onAddTenant: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTenantPage()),
            );
          },
        );
      },
      child: Container(
        width: 56.w,
        height: 56.w,
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppColors.accentOrange,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            // Strong Directional Shadow (Highest Priority)
            BoxShadow(
              color: AppColors.accentOrange.withValues(alpha: 0.35),
              blurRadius: 32,
              offset: const Offset(4, 12),
            ),
            // Secondary tight shadow
            BoxShadow(
              color: AppColors.accentOrange.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 32.sp),
      ),
    );
  }

  void _showNoHostelError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please select or add a hostel first'),
        backgroundColor: AppColors.accentOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        action: SnackBarAction(
          label: 'ADD',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PropertySetupStepperPage()),
            );
          },
        ),
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _PremiumNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 85.h,
          decoration: BoxDecoration(
            color: AppColors.backgroundPrimary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavBarItem(
                      index: 0,
                      currentIndex: currentIndex,
                      icon: Icons.grid_view_rounded,
                      label: 'Home',
                      onTap: onTap,
                    ),
                    _NavBarItem(
                      index: 1,
                      currentIndex: currentIndex,
                      icon: Icons.receipt_long_rounded,
                      label: 'Bookings',
                      onTap: onTap,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 80.w),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavBarItem(
                      index: 3,
                      currentIndex: currentIndex,
                      icon: Icons.groups_2_rounded,
                      label: 'Tenants',
                      onTap: onTap,
                    ),
                    _NavBarItem(
                      index: 4,
                      currentIndex: currentIndex,
                      icon: Icons.account_circle_rounded,
                      label: 'Profile',
                      onTap: onTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -32.h,
          child: _FloatingCommunityButton(
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
        ),
      ],
    );
  }
}

class _FloatingCommunityButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _FloatingCommunityButton({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                color: const Color(0xFF2C5990), // Solid Deep Blue Base
                shape: BoxShape.circle,
                boxShadow: [
                  // 1. Primary High-Elevation Shadow (Create the 3D lift)
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: isSelected ? 0.3 : 0.22),
                    blurRadius: 40,
                    offset: Offset(0, isSelected ? 16 : 12),
                    spreadRadius: -2,
                  ),
                  // 2. Brand Identity Glow (Subtle Orange Underglow)
                  BoxShadow(
                    color: const Color(0xFFF98125).withValues(alpha: 0.12),
                    blurRadius: 25,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.diversity_3_rounded,
                  color: Colors.white,
                  size: 30.sp,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Community',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? const Color(0xFF2C5990) : AppColors.textSecondary.withValues(alpha: 0.6),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final Function(int) onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary.withValues(alpha: 0.4),
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          if (isSelected) ...[
            SizedBox(height: 4.h),
            Container(
              width: 4.w,
              height: 4.w,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
