import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/injection_container.dart';
import '../cubit/rent_due_cubit.dart';
import '../../domain/entities/rent_due_details.dart';
import 'package:intl/intl.dart';

class RentDuePage extends StatelessWidget {
  final String hostelId;

  const RentDuePage({super.key, required this.hostelId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RentDueCubit>()..fetchRentDueDetails(hostelId),
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFE),
        appBar: AppBar(
          title: Text(
            'Rent Due Status',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<RentDueCubit, RentDueState>(
          builder: (context, state) {
            if (state is RentDueLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is RentDueError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            }
            if (state is RentDueLoaded) {
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        labelColor: AppColors.primaryBlue,
                        unselectedLabelColor: AppColors.greyText,
                        indicatorColor: AppColors.primaryBlue,
                        indicatorWeight: 3.h,
                        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Overdue'),
                          Tab(text: 'Upcoming'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _RentList(payments: state.details.overdue, isOverdue: true),
                          _RentList(payments: state.details.upcoming, isOverdue: false),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _RentList extends StatelessWidget {
  final List<RentPayment> payments;
  final bool isOverdue;

  const _RentList({required this.payments, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64.sp, color: Colors.green.shade200),
            SizedBox(height: 16.h),
            Text(
              isOverdue ? 'No overdue rents!' : 'No upcoming rents!',
              style: TextStyle(fontSize: 16.sp, color: AppColors.greyText, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: payments.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red.shade50 : Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOverdue ? Icons.priority_high_rounded : Icons.calendar_today_rounded,
                  color: isOverdue ? Colors.red : Colors.blue,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.tenantName,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    Text(
                      'Due: ${DateFormat('dd MMM yyyy').format(payment.dueDate)}',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${payment.amount.toInt()}',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.darkText),
                  ),
                  Text(
                    payment.month,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.greyText, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
