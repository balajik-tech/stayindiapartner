import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class DigitalCertificatePage extends StatefulWidget {
  const DigitalCertificatePage({super.key});

  @override
  State<DigitalCertificatePage> createState() => _DigitalCertificatePageState();
}

class _DigitalCertificatePageState extends State<DigitalCertificatePage> {
  bool _isLoading = false;
  List<dynamic> _certifications = [];

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    setState(() => _isLoading = true);
    try {
      final dio = sl<Dio>();
      final response = await dio.get('${ApiConstants.baseUrl}/hostels/certifications/my');
      if (response.statusCode == 200) {
        setState(() {
          _certifications = response.data['data'] ?? [];
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _applyForCertification(String hostelId) async {
    setState(() => _isLoading = true);
    try {
      final dio = sl<Dio>();
      final response = await dio.post(
        '${ApiConstants.baseUrl}/hostels/certifications/apply',
        data: {'hostelId': hostelId},
      );
      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
        _loadCertifications();
      }
    } catch (e) {
      String message = 'Failed to submit application';
      if (e is DioException) {
        message = e.response?.data?['message'] ?? message;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          StringUtils.translate('digital_certificate', context: context),
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          if (state is HostelLoaded) {
            final hostels = state.hostels;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text(
                    StringUtils.translate('digital_certificate_instruction', context: context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: hostels.length,
                    itemBuilder: (context, index) {
                      final hostel = hostels[index];
                      final cert = _certifications.firstWhere(
                        (c) => c['hostelId'] != null && (c['hostelId']['_id'] == hostel.id || c['hostelId'] == hostel.id),
                        orElse: () => null,
                      );

                      return _buildHostelCard(hostel, cert);
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHostelCard(dynamic hostel, dynamic cert) {
    String statusText = StringUtils.translate('not_applied', context: context);
    Color statusColor = Colors.grey;
    bool canApply = true;

    if (cert != null) {
      final String rawStatus = cert['status'] ?? 'PENDING';
      statusText = StringUtils.translate(rawStatus.toLowerCase(), context: context);
      canApply = rawStatus == 'REJECTED';
      statusColor = rawStatus == 'APPROVED' ? Colors.green : 
                   rawStatus == 'PENDING' ? Colors.orange : Colors.red;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.business_rounded, color: AppColors.primaryBlue, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hostel.name,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${hostel.city}, ${hostel.state}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (canApply) ...[
            SizedBox(height: 16.h),
            BouncingWrapper(
              onTap: () => _applyForCertification(hostel.id),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: _isLoading 
                    ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        StringUtils.translate('apply_now', context: context),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.sp),
                      ),
                ),
              ),
            ),
          ],
          if (statusText == 'APPROVED') ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.green, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        StringUtils.translate('certification_secured', context: context),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: Colors.green),
                      ),
                      const Spacer(),
                      Text(
                        cert['certificateId'],
                        style: TextStyle(
                          fontSize: 11.sp, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.green.withValues(alpha: 0.7),
                          letterSpacing: 1.2
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20.h, color: Colors.green.withValues(alpha: 0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricTile(StringUtils.translate('trust_level', context: context), _getTrustLevelLabel(cert['trustLevel']), 
                        cert['trustLevel'] == 'GOLDEN' ? Colors.orange : Colors.blue),
                      _buildMetricTile(StringUtils.translate('audit_score', context: context), '${cert['auditScore']}/5.0', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }

  String _getTrustLevelLabel(String? level) {
    if (level == 'GOLDEN') return StringUtils.translate('golden_pg', context: context);
    if (level == 'VERIFIED') return StringUtils.translate('stay_india_verified', context: context);
    return StringUtils.translate('standard_registry', context: context);
  }
}
