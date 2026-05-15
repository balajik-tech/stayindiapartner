import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:stayindia_owner/features/profile/presentation/pages/room_master_page.dart';
import 'package:stayindia_owner/features/guest/presentation/pages/guest_management_screen.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/add_tenant_page.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/owners_community_page.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/social_feed_cubit.dart';
import 'package:stayindia_owner/features/notices/presentation/cubit/notice_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/pages/tenants_page.dart';
import 'package:stayindia_owner/features/profile/presentation/pages/profile_page.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_state.dart';
import 'package:stayindia_owner/features/maintenance/presentation/cubit/maintenance_cubit.dart';
import 'package:stayindia_owner/features/staff/presentation/cubit/staff_cubit.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/finance_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';
import '../widgets/global_action_sheet.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _bookingSubscription = sl<SocketService>().bookingStream.listen(_onNewBooking);
  }

  List<Widget> _getPages() {
    // We add a ValueKey with the current locale to force a full rebuild of the pages
    // when the language is changed. This ensures all translations are updated instantly.
    final localeKey = ValueKey('locale_${context.locale.languageCode}');
    
    return [
      DashboardPage(key: ValueKey('dash_page_$localeKey')),
      BookingsPage(key: ValueKey('book_page_$localeKey')),
      OwnersCommunityPage(key: ValueKey('comm_page_$localeKey')),
      TenantsPage(key: ValueKey('tenant_page_$localeKey')),
      ProfilePage(key: ValueKey('profile_page_$localeKey')),
    ];
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
      title: 'notification_new_booking_title'.tr(),
      body: 'notification_new_booking_body'.tr(namedArgs: {
        'name': tenantName,
        'sharing': sharingType,
        'amount': amount.toString(),
      }),
      payload: 'booking',
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('notification_new_booking_body'.tr(namedArgs: {
          'name': tenantName,
          'sharing': sharingType,
          'amount': amount.toString(),
        })),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        action: SnackBarAction(
          label: 'view'.tr().toUpperCase(),
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
        BlocProvider(create: (context) => sl<SocialFeedCubit>()..loadFeed()),
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
              context.read<BookingsCubit>().fetchBookings(hostelId: hostelId);
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
            final pages = _getPages();
            return Scaffold(
              extendBody: true,
              body: IndexedStack(
                index: _currentIndex >= pages.length ? 0 : _currentIndex, 
                children: pages,
              ),
              bottomNavigationBar: _PremiumNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    final owner = authState.owner;
                    if (index == 0 && !owner.hasPermission('dashboard')) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied: You do not have permission to view Dashboard.')));
                      return;
                    }
                    if (index == 1 && !owner.hasPermission('bookings')) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied: You do not have permission to view Bookings.')));
                      return;
                    }
                    if (index == 2 && owner.role != 'owner' && owner.role != 'manager') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied: You do not have permission to view Community Feed.')));
                      return;
                    }
                    if (index == 3 && !owner.hasPermission('tenants')) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied: You do not have permission to view Tenants.')));
                      return;
                    }
                  }

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
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthAuthenticated) {
          final role = authState.owner.role;
          if (role != 'owner' && role != 'manager') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied: Only Owner or Manager can perform quick actions.')));
            return;
          }
        }

        final hostelState = context.read<HostelCubit>().state;
        Hostel? currentHostel;
        bool isMultiSelect = false;
        if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
          currentHostel = hostelState.hostels[hostelState.selectedHostelIndex];
          isMultiSelect = hostelState.selectedHostelIndices.length > 1;
        }

        GlobalActionSheet.show(
          context,
          isMultiSelect: isMultiSelect,
          onNewProperty: () {
            if (authState is AuthAuthenticated && authState.owner.role != 'owner') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied: Only Owners can add new properties.')));
              return;
            }
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
            // Merged into onAddFloor in the UI
          },
          onAddTenant: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTenantPage()),
            );
          },
          onRoomMaster: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoomMasterPage()),
            );
          },
          onGuestRequests: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GuestManagementScreen()),
            );
          },
        );
      },
      child: Container(
        width: 60.w,
        height: 60.w,
        margin: EdgeInsets.only(bottom: 20.h, right: 8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFF7000),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7000).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 36.sp),
      ),
    );
  }

  void _showNoHostelError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please select or add a hostel first'),
        backgroundColor: const Color(0xFFFF7000),
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

  const _PremiumNavBar({
    required this.currentIndex, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final owner = authState is AuthAuthenticated ? authState.owner : null;
    final bool hasBookings = owner?.hasPermission('bookings') ?? true;
    final bool hasCommunity = owner?.role == 'owner' || owner?.role == 'manager';
    final bool hasTenants = owner?.hasPermission('tenants') ?? true;

    if (!hasCommunity) {
      return Container(
        height: 85.h,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.grid_view_rounded,
              label: 'dashboard'.tr(),
              onTap: onTap,
            ),
            if (hasBookings)
              _NavBarItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.receipt_long_rounded,
                label: 'bookings'.tr(),
                onTap: onTap,
              ),
            if (hasTenants)
              _NavBarItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.group_rounded,
                label: 'tenants'.tr(),
                onTap: onTap,
              ),
            _NavBarItem(
              index: 4,
              currentIndex: currentIndex,
              icon: Icons.account_circle_rounded,
              label: 'profile'.tr(),
              onTap: onTap,
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 85.h,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
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
                      label: 'dashboard'.tr(),
                      onTap: onTap,
                    ),
                    if (hasBookings)
                      _NavBarItem(
                        index: 1,
                        currentIndex: currentIndex,
                        icon: Icons.receipt_long_rounded,
                        label: 'bookings'.tr(),
                        onTap: onTap,
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
              SizedBox(width: 70.w),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (hasTenants)
                      _NavBarItem(
                        index: 3,
                        currentIndex: currentIndex,
                        icon: Icons.group_rounded,
                        label: 'tenants'.tr(),
                        onTap: onTap,
                      )
                    else
                      const SizedBox.shrink(),
                    _NavBarItem(
                      index: 4,
                      currentIndex: currentIndex,
                      icon: Icons.account_circle_rounded,
                      label: 'profile'.tr(),
                      onTap: onTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -24.h,
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
      child: Container(
        color: Colors.transparent, // Ensure the whole area is hit-testable
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 65.w, // Slightly decreased circle size to look better with smaller icon
              height: 65.w,
              decoration: BoxDecoration(
                color: const Color(0xFF2C599D),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2C599D).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'community'.tr(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? const Color(0xFF2C599D) : const Color(0xFF64748B),
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
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF2C599D) : const Color(0xFF94A3B8),
            size: 26.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2C599D) : const Color(0xFF94A3B8),
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          if (isSelected) ...[
            SizedBox(height: 4.h),
            Container(
              width: 5.w,
              height: 5.w,
              decoration: const BoxDecoration(
                color: Color(0xFF2C599D),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
