import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
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
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  StreamSubscription? _bookingSubscription;
  String? _currentHostelId;
  
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _bookingSubscription = sl<SocketService>().bookingStream.listen(_onNewBooking);
  }

  void _initializePages(String hostelId, String hostelName) {
    if (_pages.isNotEmpty) return;
    _pages.addAll([
      DashboardPage(key: ValueKey('dash_$hostelId')),
      BookingsPage(key: ValueKey('book_$hostelId')),
      const CommunitiesPage(key: ValueKey('comm')),
      TenantsPage(key: ValueKey('tenant_$hostelId')),
      const ProfilePage(),
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
          listener: (context, state) {},
        ),
        BlocListener<HostelCubit, HostelState>(
          listenWhen: (previous, current) {
            if (previous is! HostelLoaded || current is! HostelLoaded) return true;
            final prevHostelId = previous.hostels[previous.selectedHostelIndex].id;
            final currHostelId = current.hostels[current.selectedHostelIndex].id;
            return prevHostelId != currHostelId;
          },
          listener: (context, state) {
            if (state is HostelLoaded && state.hostels.isNotEmpty) {
              final hostelId = state.hostels[state.selectedHostelIndex].id;
              if (hostelId.isEmpty) {
                AppLogger.warning(' Hostel change detected but ID is empty. Skipping sync.');
                return;
              }
              _setupSocket(hostelId);
              
              AppLogger.info(' Hostel changed to $hostelId. Triggering initial sync.');
              
              
              setState(() {
                _pages.clear();
              });
              
              context.read<DashboardCubit>().fetchDashboardData(hostelId);
              context.read<BookingsCubit>().fetchBookings();
              context.read<TenantCubit>().loadTenants(hostelId);
              context.read<MaintenanceCubit>().loadIssues(hostelId: hostelId);
              context.read<NoticeCubit>().loadNotices(hostelId: hostelId);
              context.read<StaffCubit>().loadStaff(hostelId);
              context.read<CommunityCubit>().loadCommunityData(hostelId);
              context.read<OwnerCommunityCubit>().loadCommunities();
            }
          },
        ),
      ],
      child: BlocBuilder<HostelCubit, HostelState>(
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

            final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
            final hostelName = hostelState.hostels[hostelState.selectedHostelIndex].name;
            _initializePages(hostelId, hostelName);

            return BlocListener<BookingsCubit, BookingsState>(
              listener: (context, BookingsState state) {
                if (state.status == BookingsStatus.success && 
                   (state.successMessage?.contains('successfully') ?? false)) {
                  context.read<DashboardCubit>().fetchDashboardData(hostelId);
                  
                  setState(() => _currentIndex = 0);
                }
              },
              child: Scaffold(
                extendBody: true,
                drawer: const AppDrawer(),
                body: IndexedStack(index: _currentIndex, children: _pages),
                bottomNavigationBar: _PremiumNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    HapticFeedback.lightImpact();
                    setState(() => _currentIndex = index);
                    
                    
                    
                  },
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
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

class _NavBarItemState extends State<_NavBarItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentIndex == widget.index;
    final color = isSelected ? AppColors.primaryBlue : AppColors.greyText.withValues(alpha: 0.5);

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () => widget.onTap(widget.index),
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.04) : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  child: Icon(
                    isSelected ? widget.activeIcon : widget.icon,
                    color: color,
                    size: widget.isPrimary ? 26.sp : 24.sp,
                  ),
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
