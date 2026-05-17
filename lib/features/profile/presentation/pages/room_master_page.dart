import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/widgets/add_room_master_sheet.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class RoomMasterPage extends StatelessWidget {
  const RoomMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoomCubit>()..getRooms(isMaster: true),
      child: const _RoomMasterView(),
    );
  }
}

class _RoomMasterView extends StatefulWidget {
  const _RoomMasterView();

  @override
  State<_RoomMasterView> createState() => _RoomMasterViewState();
}

class _RoomMasterViewState extends State<_RoomMasterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _hostelId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  int _totalFloors(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].floors;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      body: BlocConsumer<RoomCubit, RoomState>(
        listener: (context, state) {
          if (state is RoomOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            final hostelId = _hostelId(context);
            if (hostelId.isNotEmpty) {
              context.read<DashboardCubit>().fetchDashboardData(hostelId);
            }
          } else if (state is RoomError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              _buildPremiumHeader(context),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                sliver: state is RoomLoading
                    ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                    : SliverFillRemaining(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _RoomListBuilder(rooms: state is RoomLoaded ? state.rooms : [], filter: 'All'),
                            _RoomListBuilder(rooms: state is RoomLoaded ? state.rooms : [], filter: 'AC'),
                            _RoomListBuilder(rooms: state is RoomLoaded ? state.rooms : [], filter: 'NON-AC'),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final hostelId = _hostelId(context);
          final ownerId = context.read<AuthCubit>().currentOwner?.id ?? '';
          if (ownerId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('owner_session_expired'.tr())),
            );
            return;
          }
          if (hostelId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('no_hostel_found_profile'.tr())),
            );
            return;
          }
          final totalFloors = _totalFloors(context);
          AddRoomMasterSheet.show(
            context,
            totalFloors: totalFloors,
            roomCubit: context.read<RoomCubit>(),
            onSave: (data) async => await context.read<RoomCubit>().createRoom(
                  hostelId: hostelId,
                  ownerId: ownerId,
                  roomTypename: data['roomTypename'],
                  floor: data['floor'],
                  floors: data['floors'],
                  sharingType: data['sharingType'],
                  roomType: data['roomType'],
                  rent: data['rent'],
                  dailyRent: data['dailyRent'],
                  deposit: data['deposit'],
                  maintenance: data['maintenance'],
                  isMaster: true,
                ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 54.h, 24.w, 32.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2C5EBD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.r)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'room_master'.tr(),
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.0,
                        ),
                      ),
                      Text(
                        'room_master_sub'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              height: 50.h,
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                labelColor: const Color(0xFF1E3A8A),
                unselectedLabelColor: Colors.white.withValues(alpha: 0.8),
                labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                tabs: [
                  Tab(text: StringUtils.translate('all', context: context)),
                  Tab(text: StringUtils.translate('amenity_ac', context: context)),
                  Tab(text: StringUtils.translate('amenity_non_ac', context: context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomListBuilder extends StatelessWidget {
  final List<RoomDetail> rooms;
  final String filter;

  const _RoomListBuilder({required this.rooms, required this.filter});

  @override
  Widget build(BuildContext context) {
    final filtered = filter == 'All'
        ? rooms
        : rooms.where((r) {
            if (filter == 'AC') return r.roomType == 'AC';
            return r.roomType == 'NON-AC';
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'no_rooms_found'.tr(),
          style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _RoomMasterCard(room: filtered[index]),
    );
  }
}

class _RoomMasterCard extends StatelessWidget {
  final RoomDetail room;

  const _RoomMasterCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final isAc = room.roomType == 'AC';
    return Container(
        margin: EdgeInsets.only(bottom: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _getLocalizedRoomTypename(context, room.roomTypename),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _TypeBadge(isAc: isAc),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getLocalizedSharingType(context, room.sharingType),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: room.isActive,
                    onChanged: (value) {
                      final updated = RoomDetail(
                        id: room.id,
                        hostelId: room.hostelId,
                        roomTypename: room.roomTypename,
                        floor: room.floor,
                        floors: room.floors,
                        sharingType: room.sharingType,
                        roomType: room.roomType,
                        rent: room.rent,
                        dailyRent: room.dailyRent,
                        deposit: room.deposit,
                        maintenance: room.maintenance,
                        isActive: value,
                        isMaster: room.isMaster,
                        capacity: room.capacity,
                        beds: room.beds,
                      );
                      context.read<RoomCubit>().updateRoom(updated);
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryBlue,
                    inactiveTrackColor: const Color(0xFFEAECF0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                 _FinanceItem(label: StringUtils.translate('rent', context: context), value: room.rent.toStringAsFixed(0)),
                 if (room.dailyRent > 0) ...[
                   SizedBox(width: 24.w),
                   _FinanceItem(label: StringUtils.translate('daily', context: context), value: room.dailyRent.toStringAsFixed(0)),
                 ],
                 SizedBox(width: 24.w),
                 _FinanceItem(label: StringUtils.translate('deposit', context: context), value: room.deposit.toStringAsFixed(0)),
                 SizedBox(width: 24.w),
                 _FinanceItem(label: StringUtils.translate('maintenance_short', context: context), value: room.maintenance.toStringAsFixed(0)),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: StringUtils.translate('btn_edit', context: context),
                    color: const Color(0xFFF5F8FF),
                    textColor: AppColors.primaryBlue,
                    borderColor: const Color(0xFFD1E0FF),
                    onPressed: () {
                      final hostelState = context.read<HostelCubit>().state;
                      int totalFloors = 0;
                      if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
                        totalFloors = hostelState.hostels[hostelState.selectedHostelIndex].floors;
                      }
                      
                      AddRoomMasterSheet.show(
                        context,
                        room: room,
                        totalFloors: totalFloors,
                        roomCubit: context.read<RoomCubit>(),
                        onSave: (data) async {
                        final capacity = _mapSharingToCapacity(data['sharingType']);
                        await context.read<RoomCubit>().updateRoom(
                          RoomDetail(
                            id: room.id,
                            hostelId: room.hostelId,
                            roomTypename: data['roomTypename'],
                            floor: data['floor'],
                            floors: List<int>.from(data['floors']),
                            sharingType: data['sharingType'],
                            roomType: data['roomType'],
                            rent: data['rent'],
                            dailyRent: data['dailyRent'],
                            deposit: data['deposit'],
                            maintenance: data['maintenance'],
                            isActive: room.isActive,
                            isMaster: true,
                            capacity: capacity,
                            beds: room.beds,
                          ),
                        );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_outline,
                    label: StringUtils.translate('btn_delete', context: context),
                    color: const Color(0xFFFFF1F0),
                    textColor: const Color(0xFFF04438),
                    borderColor: const Color(0xFFFEE4E2),
                    onPressed: () => _showDeleteDialog(context, room),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Divider(height: 1, color: AppColors.roomCardBorder.withValues(alpha: 0.6)),
          ],
      ),
    );
  }

  int _mapSharingToCapacity(String sharing) {
    switch (sharing.toUpperCase()) {
      case 'SINGLE': return 1;
      case 'DOUBLE': return 2;
      case 'TRIPLE': return 3;
      case 'QUADRUPLE': return 4;
      case 'QUINTUPLE': return 5;
      default: return 1;
    }
  }

  void _showDeleteDialog(BuildContext context, RoomDetail room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(StringUtils.translate('delete_room', context: context)),
        content: Text(StringUtils.translate('delete_room_confirm', namedArgs: {'room': _getLocalizedRoomTypename(context, room.roomTypename)}, context: context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(StringUtils.translate('btn_cancel', context: context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<RoomCubit>().deleteRoom(room.id, isMaster: true);
            },
            child: Text(StringUtils.translate('btn_delete', context: context), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getLocalizedSharingType(BuildContext context, String sharing) {
    switch (sharing.toUpperCase()) {
      case 'SINGLE': return StringUtils.translate('sharing_single', context: context);
      case 'DOUBLE': return StringUtils.translate('sharing_double', context: context);
      case 'TRIPLE': return StringUtils.translate('sharing_triple', context: context);
      case 'QUADRUPLE': return StringUtils.translate('sharing_quad', context: context);
      case 'QUINTUPLE': return StringUtils.translate('sharing_count', namedArgs: {'count': '5'}, context: context);
      default: return sharing;
    }
  }

  String _getLocalizedRoomTypename(BuildContext context, String name) {
    String res = name;
    res = res.replaceAll('Single Sharing', StringUtils.translate('sharing_single', context: context));
    res = res.replaceAll('2 Sharing', StringUtils.translate('sharing_double', context: context));
    res = res.replaceAll('3 Sharing', StringUtils.translate('sharing_triple', context: context));
    res = res.replaceAll('4 Sharing', StringUtils.translate('sharing_quad', context: context));
    res = res.replaceAll('5 Sharing', StringUtils.translate('sharing_count', namedArgs: {'count': '5'}, context: context));
    if (res.contains('NON-AC')) {
      res = res.replaceAll('NON-AC', StringUtils.translate('amenity_non_ac', context: context));
    } else if (res.contains('AC')) {
      res = res.replaceAll('AC', StringUtils.translate('amenity_ac', context: context));
    }
    return res;
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isAc;
  const _TypeBadge({required this.isAc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAc ? const Color(0xFFEFF4FF) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAc ? Icons.ac_unit : Icons.wb_sunny_outlined,
            size: 14.sp,
            color: isAc ? AppColors.primaryBlue : const Color(0xFFFB923C),
          ),
          SizedBox(width: 6.w),
          Text(
            isAc ? StringUtils.translate('amenity_ac', context: context) : StringUtils.translate('amenity_non_ac', context: context),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isAc ? AppColors.primaryBlue : const Color(0xFFFB923C),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceItem extends StatelessWidget {
  final String label;
  final String value;
  const _FinanceItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF667085),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
          side: BorderSide(color: borderColor),
        ),
      ),
      icon: Icon(icon, size: 18.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
