import 'package:flutter/material.dart';
import 'dart:async';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/summary_cards.dart';
import '../widgets/floor_filter.dart';
import 'package:stayindia_owner/core/widgets/pattern_background.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import '../widgets/unified_header.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/floor_list_section.dart';
import '../widgets/dashboard_shimmer.dart';
import '../widgets/staff_dashboard_view.dart';
import 'package:stayindia_owner/features/auth/domain/entities/owner_entity.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_cubit.dart';
import 'package:stayindia_owner/features/bookings/cubit/bookings_state.dart';
import 'package:stayindia_owner/features/bookings/pages/room_selection_page.dart';

class DashboardPage extends StatefulWidget {
  final String? hostelId;
  final VoidCallback? onAddRoom;
  final bool isMultiProperty;
  final OwnerEntity? owner;

  const DashboardPage({
    super.key, 
    this.hostelId,
    this.onAddRoom,
    this.isMultiProperty = false,
    this.owner,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  StreamSubscription? _refreshSubscription;
  StreamSubscription? _bookingSubscription;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
    

    try {
      final socketService = sl<SocketService>();
      _refreshSubscription = socketService.dashboardRefreshStream.listen((data) {
        if (mounted) {
          _debouncedRefreshData();
        }
      });
      _bookingSubscription = socketService.bookingStream.listen((data) {
        if (mounted) {
          _debouncedRefreshData();
        }
      });
    } catch (e) {
      debugPrint("SocketService not found or error subscribing: $e");
    }
  }

  void _debouncedRefreshData() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _refreshData();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _debouncedRefreshData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshSubscription?.cancel();
    _bookingSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _refreshData() {
    final hostelCubit = context.read<HostelCubit>();
    final hostelState = hostelCubit.state;
    
    if (hostelState is HostelLoaded) {
      if (hostelState.hostels.isNotEmpty) {
        final hasEmptyIds = hostelState.hostels.any((h) => h.id.isEmpty);
        if (hasEmptyIds) {
          hostelCubit.getHostels(forceRefresh: true);
          return;
        }

        final selectedIds = hostelState.selectedHostelIndices
            .where((i) => i < hostelState.hostels.length)
            .map((i) => hostelState.hostels[i].id)
            .join(',');
        
        if (selectedIds.isNotEmpty) {
          context.read<DashboardCubit>().fetchDashboardData(selectedIds);
        }
      } else {
        
        context.read<DashboardCubit>().reset();
      }
    } else {
      hostelCubit.getHostels();
    }
  }

  @override
  Widget build(BuildContext context) {

    final owner = context.select((AuthCubit cubit) {
      final state = cubit.state;
      return state is AuthAuthenticated ? state.owner : null;
    });
    
    final role = owner?.role.toLowerCase() ?? 'owner';

    if (owner != null && (role == 'cook' || role == 'cleaning_staff' || role == 'security')) {
      return StaffDashboardView(owner: owner, role: role);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: PatternBackground(
        child: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<HostelCubit, HostelState>(
                listenWhen: (prev, curr) => 
                  (prev is! HostelLoaded && curr is HostelLoaded) || 
                  (prev is HostelLoaded && curr is HostelLoaded && 
                   (prev.selectedHostelIndex != curr.selectedHostelIndex || 
                    prev.selectedHostelIndices != curr.selectedHostelIndices)),
                listener: (context, state) {
                  _refreshData();
                },
              ),
              BlocListener<BookingsCubit, BookingsState>(
                listenWhen: (prev, curr) => 
                  (prev.status != BookingsStatus.success && curr.status == BookingsStatus.success && curr.successMessage != null) ||
                  (prev.scannedBooking == null && curr.scannedBooking != null),
                listener: (context, state) {
                  if (state.successMessage != null) {
                    _refreshData();
                  }
                  
                  if (state.scannedBooking != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<BookingsCubit>(),
                          child: RoomSelectionPage(
                            bookingId: state.scannedBooking!.bookingId,
                            hostelId: state.scannedBooking!.hostelId,
                            tenantName: state.scannedBooking!.tenantName,
                            preAllocatedRoomId: state.scannedBooking!.roomId,
                            preAllocatedBedNumber: state.scannedBooking!.bedNumber,
                          ),
                        ),
                      ),
                    ).then((_) {
                      if (context.mounted) {
                        context.read<BookingsCubit>().clearScannedBooking();
                      }
                    });
                  }
                },
              ),
            ],
            child: RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: AppColors.primaryBlue,
              displacement: 40,
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const DashboardShimmer();
                  }
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      const SliverToBoxAdapter(child: UnifiedHeader()),
                      
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: const SummaryCardsSection(),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: BlocBuilder<DashboardCubit, DashboardState>(
                            buildWhen: (prev, curr) => 
                              prev.selectedFloorIndex != curr.selectedFloorIndex || 
                              (prev is DashboardLoaded && curr is DashboardLoaded && prev.data.occupancy != curr.data.occupancy),
                            builder: (context, state) {
                              List<String> floors = [StringUtils.translate('all_floors', context: context)];
                              if (state is DashboardLoaded) {
                                floors.addAll(state.data.occupancy.floors.map((e) {
                                  if (e.floorName == 'basement' || (e.floorNum != null && e.floorNum! < 0)) {
                                    final absNum = e.floorNum != null ? e.floorNum!.abs() : 1;
                                    if (absNum > 1) {
                                      return '${StringUtils.translate('basement', context: context)} $absNum';
                                    }
                                    return StringUtils.translate('basement', context: context);
                                  }
                                  return StringUtils.translate(
                                    e.floorName == 'ground_floor' ? 'ground_floor' : 'floor_n',
                                    context: context,
                                    namedArgs: {'n': '${e.floorNum ?? 0}'},
                                  );
                                }));
                              }
                              return FloorFilter(
                                floors: floors,
                                selectedIndex: state.selectedFloorIndex + 1,
                                onSelected: (index) => context.read<DashboardCubit>().selectFloor(index - 1),
                              );
                            },
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                          child: const DashboardSearchBar(),
                        ),
                      ),
                      
                      SliverToBoxAdapter(child: SizedBox(height: 4.h)),

                      const FloorListSection(),
                      
                      SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
