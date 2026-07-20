import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import '../cubit/staff_cubit.dart';
import '../widgets/staff_card.dart';
import '../widgets/add_staff_sheet.dart';
import '../widgets/staff_options_sheet.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

enum StaffFilter {
  active,
  inactive,
}

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  StaffFilter _selectedFilter = StaffFilter.active;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      context.read<StaffCubit>().loadStaff(hostelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostelState = context.watch<HostelCubit>().state;
    final hasNoProperty =
        hostelState is HostelLoaded && hostelState.hostels.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: _buildAppBar(),
      body: BlocListener<HostelCubit, HostelState>(
        listenWhen: (prev, curr) =>
            (prev is! HostelLoaded && curr is HostelLoaded) ||
            (prev is HostelLoaded &&
                curr is HostelLoaded &&
                prev.selectedHostelIndex != curr.selectedHostelIndex),
        listener: (context, state) => _refreshData(),
        child: hasNoProperty
            ? _buildNoPropertyPlaceholder()
            : Column(
                children: [
                  _buildControlBar(),
                  _buildStatusFilter(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _refreshData(),
                      color: AppColors.primaryBlue,
                      child: BlocBuilder<StaffCubit, StaffState>(
                        builder: (context, state) {
                          if (state is StaffLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is StaffError) {
                            return _buildErrorState(state.message);
                          } else if (state is StaffLoaded) {

                            // final staff = state.staffList.where((s) {
                            //   final query = _searchController.text
                            //       .toLowerCase();
                            //   return s.name.toLowerCase().contains(query) ||
                            //       s.role.toLowerCase().contains(query) ||
                            //       s.phone.contains(query);
                            // }).toList();

                            final query = _searchController.text.toLowerCase();

                            final staff = state.staffList.where((s) {
                              final matchesSearch =
                                  s.name.toLowerCase().contains(query) ||
                                      s.role.toLowerCase().contains(query) ||
                                      s.phone.contains(query);

                              final matchesStatus =
                              _selectedFilter == StaffFilter.active
                                  ? s.isActive
                                  : !s.isActive;

                              return matchesSearch && matchesStatus;
                            }).toList();

                            if (staff.isEmpty) {
                              return _buildEmptyState();
                            }

                            return ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                10.h,
                                20.w,
                                100.h,
                              ),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount: staff.length,
                              itemBuilder: (context, index) => StaffCard(
                                staff: staff[index],
                                onTap: () {
                                  StaffOptionsSheet.show(
                                    context,
                                    staff: staff[index],
                                    onUpdated: _refreshData,
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildStatusFilter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildFilterButton(
                title: "Active",
                selected: _selectedFilter == StaffFilter.active,
                onTap: () {
                  setState(() {
                    _selectedFilter = StaffFilter.active;
                  });
                },
              ),
            ),
            Expanded(
              child: _buildFilterButton(
                title: "Inactive",
                selected: _selectedFilter == StaffFilter.inactive,
                onTap: () {
                  setState(() {
                    _selectedFilter = StaffFilter.inactive;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildNoPropertyPlaceholder() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_business_rounded,
                size: 64.sp,
                color: AppColors.primaryBlue.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              StringUtils.translate('add_property_first', context: context),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              StringUtils.translate(
                'start_by_adding_property_desc',
                context: context,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.greyText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        StringUtils.translate('staff_management', context: context),
        style: TextStyle(
          color: AppColors.darkText,
          fontSize: 24.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _refreshData,
          icon: Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: StringUtils.translate(
                    'search_staff_hint',
                    context: context,
                  ),
                  hintStyle: TextStyle(
                    color: AppColors.greyText.withValues(alpha: 0.5),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.greyText.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 64.sp,
              color: AppColors.primaryBlue.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            StringUtils.translate('no_staff_found', context: context),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            StringUtils.translate('add_staff_desc', context: context),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              StringUtils.translate('oops_wrong', context: context),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
            SizedBox(height: 8.h),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _refreshData,
              child: Text(StringUtils.translate('try_again', context: context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        final hostelState = context.read<HostelCubit>().state;
        if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
          final hostelId =
              hostelState.hostels[hostelState.selectedHostelIndex].id;
          AddStaffSheet.show(
            context,
            hostelId: hostelId,
            onAdded: _refreshData,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                StringUtils.translate('add_property_first', context: context),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      },
      backgroundColor: AppColors.primaryBlue,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        StringUtils.translate('add_staff_button', context: context),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 15.sp,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
