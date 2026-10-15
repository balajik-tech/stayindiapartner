import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import '../cubit/bookings_cubit.dart';
import '../cubit/bookings_state.dart';
import 'room_selection_page.dart';
import 'package:stayindia_owner/core/widgets/shimmer_loading.dart';
import '../widgets/booking_card.dart';
import 'package:stayindia_owner/features/bookings/domain/booking.dart';
import 'package:stayindia_owner/core/constants/ui_constants.dart';
import 'package:stayindia_owner/core/widgets/pattern_background.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/widgets/responsive_widgets.dart';

class _BookingsPageWithScroll extends StatefulWidget {
  const _BookingsPageWithScroll();

  @override
  State<_BookingsPageWithScroll> createState() =>
      _BookingsPageWithScrollState();
}

class _BookingsPageWithScrollState extends State<_BookingsPageWithScroll>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
  }

  void _refreshData() {
    final hostelCubit = context.read<HostelCubit>();
    final hostelState = hostelCubit.state;

    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final selectedId = hostelState.selectedHostelId;
      if (selectedId != null) {
        context.read<BookingsCubit>().fetchBookings(hostelId: selectedId);
      }
    } else {
      hostelCubit.getHostels();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HostelCubit, HostelState>(
      listenWhen: (prev, curr) =>
          (prev is! HostelLoaded && curr is HostelLoaded) ||
          (prev is HostelLoaded &&
              curr is HostelLoaded &&
              prev.selectedHostelIndex != curr.selectedHostelIndex),
      listener: (context, state) => _refreshData(),
      child: BlocListener<BookingsCubit, BookingsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          }
          if (state.errorMessage != null) {
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
          if (state.status == BookingsStatus.success &&
              state.scannedBooking != null) {
            final scanned = state.scannedBooking!;
            if (scanned.reservedRoomId != null && scanned.reservedBed != null) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Reserved Bed Found'),
                  content: Text(
                    '${scanned.tenantName} has reserved Bed ${scanned.reservedBed}.\n\nDo you want to assign this bed?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<BookingsCubit>(),
                              child: RoomSelectionPage(
                                bookingId: scanned.bookingId,
                                hostelId: scanned.hostelId,
                                tenantName: scanned.tenantName,
                                preAllocatedRoomId: scanned.roomId,
                                preAllocatedBedNumber: scanned.bedNumber,
                                bookedSharingType: scanned.sharingType,
                                bookedRoomType: scanned.roomType,
                              ),
                            ),
                          ),
                        );
                        context.read<BookingsCubit>().clearScannedBooking();
                      },
                      child: const Text('Change Bed'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<BookingsCubit>().finalizeCheckin(
                          bookingId: scanned.bookingId,
                          roomId: scanned.reservedRoomId!,
                          bedNumber: scanned.reservedBed!,
                        );
                        context.read<BookingsCubit>().clearScannedBooking();
                      },
                      child: const Text('Assign Bed'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<BookingsCubit>(),
                    child: RoomSelectionPage(
                      bookingId: scanned.bookingId,
                      hostelId: scanned.hostelId,
                      tenantName: scanned.tenantName,
                      preAllocatedRoomId: scanned.roomId,
                      preAllocatedBedNumber: scanned.bedNumber,
                      bookedSharingType: scanned.sharingType,
                      bookedRoomType: scanned.roomType,
                    ),
                  ),
                ),
              );
              context.read<BookingsCubit>().clearScannedBooking();
            }
          }
        },
        child: BlocBuilder<HostelCubit, HostelState>(
          builder: (context, hostelState) {
            if (hostelState is HostelLoaded && hostelState.hostels.isEmpty) {
              return Column(
                children: [
                  _buildPowerfulHeader(context, const BookingsState()),
                  Expanded(
                    child: _buildEmptyState(
                      StringUtils.translate(
                        'add_property_first',
                        context: context,
                      ),
                      StringUtils.translate(
                        'start_by_adding_property_desc',
                        context: context,
                      ),
                    ),
                  ),
                ],
              );
            }

            return BlocBuilder<BookingsCubit, BookingsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _buildPowerfulHeader(context, state),
                    _buildSegmentedTabs(state),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTabContent(
                            context,
                            state,
                            state.requests,
                            StringUtils.translate(
                              'no_pending_requests',
                              context: context,
                            ),
                            StringUtils.translate(
                              'new_booking_requests_here',
                              context: context,
                            ),
                          ),
                          _buildTabContent(
                            context,
                            state,
                            state.checkIns,
                            StringUtils.translate(
                              'no_active_residents',
                              context: context,
                            ),
                            StringUtils.translate(
                              'manage_residents_subtitle',
                              context: context,
                            ),
                          ),
                          _buildHistoryTab(context, state),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPowerfulHeader(BuildContext context, BookingsState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 16.h, 8.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      StringUtils.translate('bookings_title', context: context),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      StringUtils.translate(
                        'bookings_subtitle',
                        context: context,
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderAction(
                    Icons.search_rounded,
                    () => setState(() => _isSearching = !_isSearching),
                  ),
                  _buildHeaderAction(Icons.refresh_rounded, () {
                    final hostelId = context
                        .read<HostelCubit>()
                        .state
                        .selectedHostelId;
                    context.read<BookingsCubit>().fetchBookings(
                      hostelId: hostelId,
                    );
                  }),
                ],
              ),
            ],
          ),
          if (_isSearching) ...[
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) =>
                      context.read<BookingsCubit>().searchBookings(value),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, room...',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        margin: EdgeInsets.only(left: 8.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      ),
    );
  }

  Widget _buildSegmentedTabs(BookingsState state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: ResponsiveTabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          _buildTabItem(
            StringUtils.translate('tab_requests', context: context),
            state.requests.length,
            0,
          ),
          _buildTabItem(
            StringUtils.translate('tab_active', context: context),
            state.checkIns.length,
            1,
          ),
          Tab(text: StringUtils.translate('tab_history', context: context)),
        ],
      ),
    );
  }

  Tab _buildTabItem(String label, int count, int index) {
    return Tab(
      child: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          final double value = _tabController.animation!.value;
          bool isSelected = value.round() == index;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              if (count > 0) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    BookingsState state,
    List<Booking> items,
    String emptyTitle,
    String emptySubtitle, {
    bool isHistory = false,
  }) {
    final hostelId = context.read<HostelCubit>().state.selectedHostelId;

    if (state.status == BookingsStatus.loading && state.bookings.isEmpty) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: 5,
        itemBuilder: (context, index) => const TenantCardSkeleton(),
      );
    }

    if (items.isEmpty) {
      return _buildEmptyState(emptyTitle, emptySubtitle);
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<BookingsCubit>().fetchBookings(hostelId: hostelId),
      color: AppColors.primaryBlue,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            // context.read<BookingsCubit>().loadMoreBookings();

            //Stopping load more for backend no pagination support
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(
            20.w,
            0,
            20.w,
            UIConstants.bottomPadding(context) + 20.h,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length + (state.isLoadMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < items.length) {
              return BookingCard(booking: items[index], isCompact: true);
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
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, BookingsState state) {
    final historyBookings = state.bookings
        .where(
          (b) => [
            BookingStatus.cancelled,
            BookingStatus.checkedOut,
          ].contains(b.status),
        )
        .toList();
    return _buildTabContent(
      context,
      state,
      historyBookings,
      StringUtils.translate('no_history_found', context: context),
      StringUtils.translate('history_empty_subtitle', context: context),
      isHistory: true,
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.r),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 64.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.1),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: PatternBackground(
        child: SafeArea(child: _BookingsPageWithScroll()),
      ),
    );
  }
}
