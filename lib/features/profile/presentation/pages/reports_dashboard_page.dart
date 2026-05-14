import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stayindia_owner/injection_container.dart';

class ReportsDashboardPage extends StatefulWidget {
  const ReportsDashboardPage({super.key});

  @override
  State<ReportsDashboardPage> createState() => _ReportsDashboardPageState();
}

class _ReportsDashboardPageState extends State<ReportsDashboardPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedHostelId;
  String? _selectedReportType; // 'payments', 'tenants', 'bookings'
  bool _isGenerating = false;
  List<dynamic> _previewData = [];
  Map<String, dynamic> _summary = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reports & Analytics',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterPanel(),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('SELECT REPORT TYPE'),
                  SizedBox(height: 16.h),
                  _buildReportGrid(),
                  if (_previewData.isNotEmpty) ...[
                    SizedBox(height: 32.h),
                    _buildPreviewSection(),
                  ],
                  SizedBox(height: 32.h),
                  if (_isGenerating) _buildGeneratingState() else _buildExportOptions(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('DATE RANGE'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildDatePicker(true)),
              SizedBox(width: 12.w),
              Expanded(child: _buildDatePicker(false)),
            ],
          ),
          SizedBox(height: 20.h),
          _buildSectionLabel('PROPERTY FILTER'),
          SizedBox(height: 12.h),
          BlocBuilder<HostelCubit, HostelState>(
            builder: (context, state) {
              final hostels = state is HostelLoaded ? state.hostels : [];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedHostelId,
                    isExpanded: true,
                    hint: Text('All Properties', style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    style: GoogleFonts.dmSans(fontSize: 14.sp, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Properties')),
                      ...hostels.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedHostelId = val);
                      if (_selectedReportType != null) _fetchPreview();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(bool isStart) {
    final date = isStart ? _startDate : _endDate;
    return BouncingWrapper(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            if (isStart) _startDate = picked; else _endDate = picked;
          });
          if (_selectedReportType != null) _fetchPreview();
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16.sp, color: AppColors.primaryBlue),
            SizedBox(width: 10.w),
            Text(
              DateFormat('dd MMM, yyyy').format(date),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportGrid() {
    return Row(
      children: [
        Expanded(child: _buildReportCard('Payments', 'payments', Icons.payments_rounded, Colors.green)),
        SizedBox(width: 12.w),
        Expanded(child: _buildReportCard('Tenants', 'tenants', Icons.people_alt_rounded, Colors.blue)),
        SizedBox(width: 12.w),
        Expanded(child: _buildReportCard('Bookings', 'bookings', Icons.event_available_rounded, Colors.orange)),
      ],
    );
  }

  Widget _buildReportCard(String title, String type, IconData icon, Color color) {
    final isSelected = _selectedReportType == type;
    return BouncingWrapper(
      onTap: () {
        setState(() => _selectedReportType = type);
        _fetchPreview();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? color : AppColors.border.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('DATA PREVIEW'),
            Text(
              'Showing latest 5',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _previewData.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
            itemBuilder: (context, index) {
              final item = _previewData[index];
              return Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? item['tenant'] ?? 'N/A',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp),
                          ),
                          Text(
                            item['property'] ?? item['status'] ?? '',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item['amount'] != null ? '₹${item['amount']}' : (item['date'] ?? item['checkIn'] ?? ''),
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryBlue, fontSize: 13.sp),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExportOptions() {
    final canExport = _selectedReportType != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('EXPORT DATA'),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _buildExportButton('Excel (.xlsx)', Icons.table_view_rounded, const Color(0xFF1D6F42), canExport)),
            SizedBox(width: 12.w),
            Expanded(child: _buildExportButton('PDF Report', Icons.picture_as_pdf_rounded, const Color(0xFFD32F2F), canExport)),
          ],
        ),
      ],
    );
  }

  Widget _buildExportButton(String label, IconData icon, Color color, bool enabled) {
    return BouncingWrapper(
      onTap: enabled ? () => _handleExport(label) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28.sp),
              SizedBox(height: 8.h),
              Text(
                label,
                style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchPreview() async {
    if (_selectedReportType == null) return;
    
    setState(() => _isGenerating = true);
    try {
      final dio = sl<Dio>();
      final String endpoint = _selectedReportType == 'payments' 
          ? ApiConstants.reportsPayments 
          : (_selectedReportType == 'tenants' ? ApiConstants.reportsTenants : ApiConstants.reportsBookings);

      final response = await dio.get(
        endpoint,
        queryParameters: {
          'startDate': _startDate.toIso8601String(),
          'endDate': _endDate.toIso8601String(),
          if (_selectedHostelId != null) 'propertyId': _selectedHostelId,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _previewData = response.data['data']['data'] ?? [];
          _summary = response.data['data']['summary'] ?? {};
        });
      }
    } catch (e) {
      debugPrint('Error fetching preview: $e');
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _handleExport(String format) async {
    setState(() => _isGenerating = true);
    try {
      final dio = sl<Dio>();
      final String endpoint = _selectedReportType == 'payments' 
          ? ApiConstants.reportsPayments 
          : (_selectedReportType == 'tenants' ? ApiConstants.reportsTenants : ApiConstants.reportsBookings);

      final response = await dio.get(
        endpoint,
        queryParameters: {
          'startDate': _startDate.toIso8601String(),
          'endDate': _endDate.toIso8601String(),
          if (_selectedHostelId != null) 'propertyId': _selectedHostelId,
        },
      );

      if (response.statusCode == 200) {
        final url = response.data['data']['fileUrl'];
        if (url != null) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report download started successfully!')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate report. Please try again.')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Widget _buildGeneratingState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primaryBlue),
          SizedBox(height: 16.h),
          Text(
            'Processing Request...',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, fontSize: 16.sp),
          ),
          Text(
            'Please wait while we crunch the numbers',
            style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}
