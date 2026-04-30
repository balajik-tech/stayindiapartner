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
import 'package:stayindia_owner/features/profile/presentation/widgets/add_hostel_sheet.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/communities_page.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/notices/presentation/cubit/notice_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:stayindia_owner/features/staff/presentation/cubit/staff_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/app_drawer.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
    if (hostelId.isEmpty || _currentHostelId == hostelId) return;

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
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              
            }
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
              final ownerId = context.read<AuthCubit>().currentOwner?.id;

              
              context.read<CommunityCubit>().loadCommunityData(hostelId);
              
              
              if (ownerId != null) {
                for (var hostel in state.hostels) {
                  context.read<CommunityCubit>().joinCommunity(hostel.id, ownerId);
                }
              }

              _setupSocket(hostelId);
              context.read<DashboardCubit>().fetchDashboardData(hostelId);
              AppLogger.info('Hostel changed: $hostelId. Syncing data...');
              
              
              

              
              context.read<DashboardCubit>().fetchDashboardData(hostelId);
              context.read<BookingsCubit>().fetchBookings();
              context.read<TenantCubit>().loadTenants(hostelId);
              context.read<MaintenanceCubit>().loadIssues(hostelId: hostelId);
              context.read<NoticeCubit>().loadNotices(hostelId: hostelId);
              context.read<StaffCubit>().loadStaff(hostelId);
              context.read<OwnerCommunityCubit>().loadCommunities();
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
            if (hostelState.hostels.isEmpty) {
              return _NoHostelsView();
            }

            return Scaffold(
                key: MainNavigationPage.scaffoldKey,
                extendBody: false,
                drawer: const AppDrawer(),
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
    );
  }

  Widget _buildPremiumFAB(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: BouncingWrapper(
        onTap: () {
          HapticFeedback.heavyImpact();
          final hostelState = context.read<HostelCubit>().state;
          Hostel? currentHostel;
          if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
            currentHostel = hostelState.hostels[hostelState.selectedHostelIndex];
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertySetupStepperPage(existingHostel: currentHostel),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please select or add a hostel first'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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
        },
        child: Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7000), Color(0xFFFF9F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7000).withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28.sp),
        ),
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _PremiumNavBar({required this.currentIndex, required this.onTap});

  @override
  Size get preferredSize => Size.fromHeight(80.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      maintainBottomViewPadding: true,
      child: Container(
        height: 72.h,
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarItem(
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.grid_view_rounded,
              activeIcon: Icons.grid_view_rounded,
              label: 'Home',
              onTap: onTap,
            ),
            _NavBarItem(
              index: 1,
              currentIndex: currentIndex,
              icon: Icons.receipt_long_rounded,
              activeIcon: Icons.receipt_long_rounded,
              label: 'Bookings',
              onTap: onTap,
            ),
            _NavBarItem(
              index: 2,
              currentIndex: currentIndex,
              icon: Icons.forum_rounded,
              activeIcon: Icons.forum_rounded,
              label: 'Community',
              isPrimary: true,
              onTap: onTap,
            ),
            _NavBarItem(
              index: 3,
              currentIndex: currentIndex,
              icon: Icons.groups_2_rounded,
              activeIcon: Icons.groups_2_rounded,
              label: 'Tenants',
              onTap: onTap,
            ),
            _NavBarItem(
              index: 4,
              currentIndex: currentIndex,
              icon: Icons.account_circle_rounded,
              activeIcon: Icons.account_circle_rounded,
              label: 'Profile',
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isPrimary;
  final Function(int) onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentIndex == widget.index;
    final color = isSelected ? AppColors.primaryBlue : AppColors.greyText.withValues(alpha: 0.5);

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.04) : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? widget.activeIcon : widget.icon,
                color: color,
                size: widget.isPrimary ? 26.sp : 24.sp,
              ),
              SizedBox(height: 2.h),
              Text(
                widget.label,
                style: TextStyle(
                  color: color,
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoHostelsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work_outlined, size: 80.sp, color: AppColors.greyText),
              SizedBox(height: 16.h),
              Text('No Hostels Found', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Text('You need to add a hostel to start managing it.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.greyText)),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddHostelSheet(),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h)),
                child: const Text('Add Your First Hostel', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
