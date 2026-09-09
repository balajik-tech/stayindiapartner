import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart' as entity;
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/notifications/domain/repositories/notification_repository.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';

class DetailTenantItem {
  final String id;
  final String shortId;
  final String name;
  final String? avatar;
  final String roomBed;
  final String subtitle;
  final String? mobile;

  DetailTenantItem({
    required this.id,
    required this.shortId,
    required this.name,
    this.avatar,
    required this.roomBed,
    required this.subtitle,
    this.mobile,
  });
}

class SummaryCardDetailsSection extends StatefulWidget {
  const SummaryCardDetailsSection({super.key});

  @override
  State<SummaryCardDetailsSection> createState() => _SummaryCardDetailsSectionState();
}

class _SummaryCardDetailsSectionState extends State<SummaryCardDetailsSection> {
  bool _isExpanded = true;
  final Set<String> _selectedIds = {};

  @override
  void didUpdateWidget(covariant SummaryCardDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedIds.clear();
  }

  String _findRoomBedForTenant(String tenantName, entity.Occupancy occupancy) {
    for (final floor in occupancy.floors) {
      for (final room in floor.rooms) {
        for (final bed in room.beds) {
          if (bed.tenantName == tenantName) {
            return '${room.roomNumber}-${bed.bedNumber}';
          }
        }
      }
    }
    return 'N/A';
  }

  List<DetailTenantItem> _getTenants(DashboardLoaded state, String metric) {
    final List<DetailTenantItem> items = [];
    final occupancy = state.data.occupancy;
    int index = 0;

    if (metric == 'overdue') {
      final overdueList = state.data.rentDueDetails.overdue;
      for (final payment in overdueList) {
        index++;
        final shortId = 'T${index.toString().padLeft(3, '0')}';
        final roomBed = _findRoomBedForTenant(payment.tenantName, occupancy);
        final dueDateStr = DateFormat('dd MMM').format(payment.dueDate);
        items.add(
          DetailTenantItem(
            id: payment.tenantId,
            shortId: shortId,
            name: payment.tenantName,
            avatar: payment.tenantAvatar,
            roomBed: roomBed,
            subtitle: 'Due: ₹${payment.amount.toStringAsFixed(0)} on $dueDateStr',
            mobile: payment.tenantMobile,
          ),
        );
      }
      return items;
    }

    for (final floor in occupancy.floors) {
      for (final room in floor.rooms) {
        for (final bed in room.beds) {
          bool matches = false;
          String subtitle = '';
          String displayName = bed.tenantName ?? '';

          switch (metric) {
            case 'away':
              if (bed.tenantName == null || bed.tenantName!.isEmpty) continue;
              matches = bed.isAway ||
                  bed.status.toLowerCase() == 'away' ||
                  bed.status.toLowerCase() == 'unknown';
              final hours = ((index * 3) + 4) % 12;
              final minutes = ((index * 7) + 12) % 60;
              final timeStr = '${hours.toString().padLeft(2, '0')} h:${minutes.toString().padLeft(2, '0')} ago';
              subtitle = bed.awayReturnDate != null && bed.awayReturnDate!.isNotEmpty
                  ? 'Return: ${bed.awayReturnDate}'
                  : 'last active: $timeStr';
              break;
            case 'notice':
              if (bed.tenantName == null || bed.tenantName!.isEmpty) continue;
              matches = bed.status.toLowerCase() == 'notice';
              subtitle = 'Notice active';
              break;
            case 'reserved':
              matches = bed.status.toLowerCase() == 'reserved' ||
                  bed.status.toLowerCase() == 'pre_booked' ||
                  bed.status.toLowerCase() == 'pre-booked';
              subtitle = 'Reservation confirmed';
              if (displayName.isEmpty) displayName = 'Reserved Guest';
              break;
            case 'occupied':
              if (bed.tenantName == null || bed.tenantName!.isEmpty) continue;
              matches = bed.status.toLowerCase() == 'occupied';
              subtitle = 'Checked in';
              break;
            case 'repair':
              matches = bed.status.toLowerCase() == 'repair' ||
                  bed.status.toLowerCase() == 'maintenance';
              subtitle = 'Maintenance active';
              if (displayName.isEmpty) displayName = 'Maintenance Bed';
              break;
            case 'free':
              matches = bed.status.toLowerCase() == 'free' || bed.status.toLowerCase() == 'vacant' || bed.status.toLowerCase() == 'available';
              subtitle = 'Available for booking';
              if (displayName.isEmpty) displayName = 'Empty Bed';
              break;
            case 'total':
            case 'total_rooms':
              matches = true;
              subtitle = bed.status.toUpperCase();
              if (displayName.isEmpty) displayName = 'Empty Bed';
              break;
            case 'in':
              if (bed.tenantName == null || bed.tenantName!.isEmpty) continue;
              matches = bed.geofenceStatus == 'INSIDE' && !bed.isAway;
              subtitle = 'Currently In';
              break;
            case 'out':
              if (bed.tenantName == null || bed.tenantName!.isEmpty) continue;
              matches = bed.geofenceStatus == 'OUTSIDE' && !bed.isAway;
              subtitle = 'Currently Out';
              break;
            default:
              matches = false;
          }

          if (matches) {
            index++;
            final shortId = 'T${index.toString().padLeft(3, '0')}';
            items.add(
              DetailTenantItem(
                id: bed.tenantId ?? displayName,
                shortId: shortId,
                name: displayName,
                avatar: bed.tenantAvatar,
                roomBed: '${room.roomNumber}-${bed.bedNumber}',
                subtitle: subtitle,
              ),
            );
          }
        }
      }
    }

    return items;
  }

  String _getTitle(String metric) {
    switch (metric) {
      case 'away':
        return 'Tenants Currently Away';
      case 'notice':
        return 'Tenants on Notice';
      case 'reserved':
        return 'Reservations';
      case 'occupied':
        return 'Occupied Beds';
      case 'overdue':
        return 'Overdue Payments';
      case 'repair':
        return 'Beds under Maintenance';
      case 'free':
        return 'Available Beds';
      case 'total':
        return 'All Beds';
      case 'total_rooms':
        return 'All Rooms';
      case 'in':
        return 'Tenants Currently In';
      case 'out':
        return 'Tenants Currently Out';
      default:
        return 'Tenant List';
    }
  }

  void _sendBulkMessage(List<DetailTenantItem> selectedTenants) {
    if (selectedTenants.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController(text: 'Hostel Notice');
        final messageController = TextEditingController();
        bool isSending = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              title: Text(
                'Bulk Message (${selectedTenants.length} tenants)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter title (e.g. Notice, Alert)',
                      labelText: 'Title',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Enter your broadcast message here...',
                      labelText: 'Message',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: isSending
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final message = messageController.text.trim();
                          if (title.isEmpty || message.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill both Title and Message.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSending = true;
                          });

                          try {
                            final tenantIds = selectedTenants
                                .map((t) => t.id)
                                .where((id) => id.isNotEmpty && !id.contains(' '))
                                .toList();

                            if (tenantIds.isEmpty) {
                              throw Exception('No valid tenant user IDs found to send notifications.');
                            }

                            await sl<NotificationRepository>().sendBulkMessage(
                              tenantIds: tenantIds,
                              title: title,
                              message: message,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Bulk message sent to ${tenantIds.length} tenants successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setDialogState(() {
                                isSending = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to send bulk message: ${e.toString().replaceAll('Exception: ', '')}'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: isSending
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Send', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is! DashboardLoaded) return const SizedBox.shrink();

        final metric = state.selectedMetric;
        if (metric == null || metric == 'properties') {
          return const SizedBox.shrink();
        }

        final tenants = _getTenants(state, metric);

        final title = _getTitle(metric);
        final allChecked = tenants.every((t) => _selectedIds.contains(t.id));

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE25822),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 20.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              if (_isExpanded)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: tenants.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.h),
                          child: Center(
                            child: Text(
                              'No beds found',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tenants.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.black.withValues(alpha: 0.06),
                          height: 1,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          final tenant = tenants[index];
                          final isSelected = _selectedIds.contains(tenant.id);

                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 45.w,
                                  child: Text(
                                    tenant.shortId,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),

                                CustomAvatar(
                                  imageUrl: tenant.avatar,
                                  name: tenant.name,
                                  size: 32,
                                  isCircle: true,
                                ),
                                SizedBox(width: 12.w),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tenant.name,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        tenant.subtitle,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Text(
                                  tenant.roomBed,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (metric != 'repair' && metric != 'free' && metric != 'total') ...[
                                  SizedBox(width: 16.w),

                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedIds.remove(tenant.id);
                                        } else {
                                          _selectedIds.add(tenant.id);
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 20.w,
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4.r),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary.withValues(alpha: 0.5),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.check_rounded,
                                              size: 14.sp,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      if (metric != 'repair' && metric != 'free' && metric != 'total')
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (allChecked) {
                                    _selectedIds.clear();
                                  } else {
                                    _selectedIds.addAll(tenants.map((t) => t.id));
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 18.w,
                                    height: 18.h,
                                    decoration: BoxDecoration(
                                      color: allChecked ? AppColors.primaryBlue : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4.r),
                                      border: Border.all(
                                        color: allChecked ? AppColors.primaryBlue : AppColors.textSecondary.withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: allChecked
                                        ? Icon(
                                            Icons.check_rounded,
                                            size: 12.sp,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Check All',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedIds.addAll(tenants.map((t) => t.id));
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Select All',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                elevation: 0,
                              ),
                              onPressed: () {
                                final selectedList = tenants
                                    .where((t) => _selectedIds.contains(t.id))
                                    .toList();
                                if (selectedList.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select at least one tenant.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                } else {
                                  _sendBulkMessage(selectedList);
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Bulk Message',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_selectedIds.isNotEmpty) ...[
                                    SizedBox(width: 6.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Text(
                                        '${_selectedIds.length}',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
