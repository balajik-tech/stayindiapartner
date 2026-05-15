import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
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

class _BookingsPageWithScroll extends StatefulWidget {
  const _BookingsPageWithScroll();

  @override
  State<_BookingsPageWithScroll> createState() => _BookingsPageWithScrollState();
}

class _BookingsPageWithScrollState extends State<_BookingsPageWithScroll> with SingleTickerProviderStateMixin {
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
        (prev is HostelLoaded && curr is HostelLoaded && prev.selectedHostelIndex != curr.selectedHostelIndex),
      listener: (context, state) => _refreshData(),
      child: BlocListener<BookingsCubit, BookingsState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          );
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          );
        }
        if (state.status == BookingsStatus.success && state.scannedBooking != null) {
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
          );
          context.read<BookingsCubit>().clearScannedBooking();
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
                    'add_property_first'.tr(), 
                    'start_by_adding_property_desc'.tr()
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
                        _buildTabContent(context, state, state.requests, 'no_pending_requests'.tr(), 'new_booking_requests_here'.tr()),
                        _buildTabContent(context, state, state.checkIns, 'no_active_residents'.tr(), 'manage_residents_subtitle'.tr()),
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
      padding: EdgeInsets.fromLTRB(8.w, 12.h, 16.w, 24.h),
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
                      'bookings_title'.tr(),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'bookings_subtitle'.tr(),
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
                  _buildHeaderAction(Icons.search_rounded, () => setState(() => _isSearching = !_isSearching)),
                  _buildHeaderAction(Icons.filter_list_rounded, () => _showFilterSheet(context)),
                  _buildHeaderAction(Icons.refresh_rounded, () {
                    final hostelId = context.read<HostelCubit>().state.selectedHostelId;
                    context.read<BookingsCubit>().fetchBookings(hostelId: hostelId);
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
                  onChanged: (value) => context.read<BookingsCubit>().searchBookings(value),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, room...',
                    hintStyle: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.3)),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.5), size: 20.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
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
        unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          _buildTabItem('tab_requests'.tr(), state.requests.length, 0),
          _buildTabItem('tab_active'.tr(), state.checkIns.length, 1),
          Tab(text: 'tab_history'.tr()),
        ],
      ),
    );
  }

  Tab _buildTabItem(String label, int count, int index) {
    bool isSelected = _tabController.index == index;
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.primaryBlue.withValues(alpha: 0.1),
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
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, BookingsState state, List<Booking> items, String emptyTitle, String emptySubtitle) {
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
      onRefresh: () => context.read<BookingsCubit>().fetchBookings(hostelId: hostelId),
      color: AppColors.primaryBlue,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
            context.read<BookingsCubit>().loadMoreBookings();
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, UIConstants.bottomPadding(context) + 20.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length + (state.isLoadMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < items.length) {
              return BookingCard(booking: items[index]);
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, BookingsState state) {
    final historyBookings = state.bookings.where((b) => [BookingStatus.cancelled, BookingStatus.checkedOut].contains(b.status)).toList();
    return _buildTabContent(context, state, historyBookings, 'no_history_found'.tr(), 'history_empty_subtitle'.tr());
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
            child: Icon(Icons.inbox_rounded, size: 64.sp, color: AppColors.textSecondary.withValues(alpha: 0.1)),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final cubit = context.read<BookingsCubit>();
    String? tempKycStatus = cubit.state.kycStatus;
    String? tempRoomType = cubit.state.roomType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'filter_bookings'.tr(),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        tempKycStatus = null;
                        tempRoomType = null;
                      });
                      cubit.changeFilter(kycStatus: '', roomType: '');
                      Navigator.pop(context);
                    },
                    child: Text('reset'.tr(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.accentOrange)),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildFilterSection(
                'kyc_status'.tr(),
                ['verified'.tr(), 'pending'.tr()],
                tempKycStatus,
                (val) => setSheetState(() => tempKycStatus = val),
              ),
              SizedBox(height: 24.h),
              _buildFilterSection(
                'room_type'.tr(),
                ['1 Sharing', '2 Sharing', '3 Sharing'],
                tempRoomType,
                (val) => setSheetState(() => tempRoomType = val),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cubit.changeFilter(
                      kycStatus: tempKycStatus ?? '',
                      roomType: tempRoomType ?? '',
                    );
                    Navigator.pop(context);
                  },
                  child: Text('apply_filters'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String? selectedValue,
    Function(String?) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: options.map((opt) {
            final isSelected = selectedValue == opt;
            return InkWell(
              onTap: () => onSelected(isSelected ? null : opt),
              borderRadius: BorderRadius.circular(12.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
        child: SafeArea(
          child: _BookingsPageWithScroll(),
        ),
      ),
    );
  }
}
