import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/injection_container.dart';
import '../cubit/guest_cubit.dart';
import '../cubit/guest_state.dart';
import '../../domain/entities/guest_request.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';

class GuestManagementScreen extends StatelessWidget {
  const GuestManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    String? hostelId;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
    }

    return BlocProvider(
      create: (context) {
        final cubit = sl<GuestCubit>();
        if (hostelId != null) cubit.loadHostelRequests(hostelId);
        return cubit;
      },
      child: GuestManagementView(hostelId: hostelId),
    );
  }
}

class GuestManagementView extends StatelessWidget {
  final String? hostelId;
  const GuestManagementView({super.key, this.hostelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text("guest_requests".tr(), style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: hostelId == null
          ? Center(child: Text("select_property".tr()))
          : BlocBuilder<GuestCubit, GuestState>(
              builder: (context, state) {
                if (state is GuestLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GuestError) {
                  return Center(child: Text(state.message));
                }
                if (state is GuestSuccess) {
                  if (state.requests.isEmpty) {
                    return const Center(child: Text("No guest requests found"));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: state.requests.length,
                    itemBuilder: (context, index) {
                      final request = state.requests[index];
                      return _GuestRequestCard(request: request, hostelId: hostelId!);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }
}

class _GuestRequestCard extends StatelessWidget {
  final GuestRequest request;
  final String hostelId;
  const _GuestRequestCard({required this.request, required this.hostelId});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.orange;
    if (request.status == "ACCEPTED") statusColor = Colors.green;
    if (request.status == "REJECTED") statusColor = Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.tenantName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp)),
                  Text("Tenant Phone: ${request.tenantPhone}", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                ],
              ),
              _buildStatusBadge(request.status, statusColor),
            ],
          ),
          const Divider(height: 24),
          Text("${"guest_name".tr()}: ${request.guestName} (${request.relationship})", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
              SizedBox(width: 6.w),
              Text(
                "${request.startDate.day}/${request.startDate.month} to ${request.endDate.day}/${request.endDate.month} (${request.numberOfDays} days)",
                style: TextStyle(fontSize: 13.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 14.sp, color: Colors.grey),
              SizedBox(width: 6.w),
              Text("${"total_amount".tr()}: ₹${request.totalAmount.toInt()}", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          if (request.status == "PENDING") ...[
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text("reject".tr()),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<GuestCubit>().updateStatus(request.id, "ACCEPTED", hostelId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text("accept".tr()),
                  ),
                ),
              ],
            ),
          ],
          if (request.status == "REJECTED" && request.rejectionReason != null) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8.r)),
              child: Text("${"rejection_reason".tr()}: ${request.rejectionReason}", style: TextStyle(color: Colors.red.shade800, fontSize: 12.sp)),
            ),
          ],
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("reject".tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "rejection_reason".tr()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("btn_cancel".tr())),
          TextButton(
            onPressed: () {
              context.read<GuestCubit>().updateStatus(request.id, "REJECTED", hostelId, rejectionReason: controller.text);
              Navigator.pop(ctx);
            },
            child: Text("reject".tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}
