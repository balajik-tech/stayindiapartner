import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/request_service/presentation/pages/my_requests_page.dart';
import 'package:stayindia_owner/features/request_service/presentation/pages/request_service_page.dart';

class RequestSentPage extends StatelessWidget {
  final String requestId;
  final String serviceType;
  final String hostelName;
  final String date;
  final String slot;
  final String? slotTime;

  const RequestSentPage({
    super.key,
    required this.requestId,
    required this.serviceType,
    required this.hostelName,
    required this.date,
    required this.slot,
    this.slotTime,
  });

  @override
  Widget build(BuildContext context) {
    final String displayTime =
        slotTime ??
        (slot.toLowerCase().contains('morning')
            ? '7 am – 12 pm'
            : '4 pm – 9 pm');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF1E293B),
            size: 22.r,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Request sent',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.assignment_outlined,
              color: const Color(0xFF1E293B),
              size: 22.r,
            ),
            tooltip: 'My requests',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyRequestsPage()),
            ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            children: [
              // Main Confirmation Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Success Green Circle Checkmark
                    Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: const Color(0xFF059669),
                        size: 34.r,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Request ID Title
                    Text(
                      'Request $requestId sent',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 6.h),

                    // Service & Hostel
                    Text(
                      '$serviceType at $hostelName',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 4.h),

                    // Date, Slot & Time
                    Text(
                      '$date · $slot · $displayTime',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // SizedBox(height: 24.h),

                    // Divider
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1),

                    // SizedBox(height: 20.h),

                    // 1. Track this request button
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 52.h,
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       Navigator.pushReplacement(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (_) => const MyRequestsPage(),
                    //         ),
                    //       );
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(0xFFFF7A00),
                    //       elevation: 0,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(16.r),
                    //       ),
                    //     ),
                    //     child: Text(
                    //       'Track this request',
                    //       style: TextStyle(
                    //         fontSize: 16.sp,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 12.h),

                    // 2. Request another service button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RequestServicePage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              size: 20.r,
                              color: const Color(0xFF0F172A),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Request another service',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // 3. Back to more link
                    BouncingWrapper(
                      onTap: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.h,
                          horizontal: 16.w,
                        ),
                        child: Text(
                          'Back to more',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Bottom Caption text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Requesting another keeps $hostelName, ${date.toLowerCase()} and ${slot.toLowerCase()}.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
