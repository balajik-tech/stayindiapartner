import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';

class GovernmentLicensesPage extends StatefulWidget {
  const GovernmentLicensesPage({super.key});

  @override
  State<GovernmentLicensesPage> createState() => _GovernmentLicensesPageState();
}

class _GovernmentLicensesPageState extends State<GovernmentLicensesPage> {
  Hostel? _selectedHostel;
  final Map<String, Map<String, dynamic>> _mockCompliances = {};

  @override
  void initState() {
    super.initState();
  }

  void _initMockData(List<Hostel> hostels) {
    if (_mockCompliances.isNotEmpty) return;
    for (var hostel in hostels) {
      _mockCompliances[hostel.id] = {
        'fssai': {
          'status': hostel.foodLicense != null && hostel.foodLicense!.isNotEmpty ? 'VERIFIED' : 'NOT_STARTED',
          'number': hostel.foodLicense ?? '',
          'expiry': '12 Dec 2028',
          'docName': 'fssai_cert.pdf',
        },
        'trade': {
          'status': hostel.tradeLicense != null && hostel.tradeLicense!.isNotEmpty ? 'VERIFIED' : 'PENDING_UPLOAD',
          'number': hostel.tradeLicense ?? '',
          'expiry': '28 Aug 2027',
          'docName': 'trade_license.pdf',
        },
        'police': {
          'status': 'IN_PROGRESS',
          'number': 'POL-8827110',
          'expiry': 'N/A',
          'docName': 'police_clearance.pdf',
          'steps': [
            {'title': 'Form Submitted', 'done': true, 'date': '10 Jun 2026'},
            {'title': 'Documents Verified', 'done': true, 'date': '11 Jun 2026'},
            {'title': 'Physical Inspection', 'done': false, 'date': 'Pending Schedule'},
            {'title': 'NOC Issuance', 'done': false, 'date': 'Awaiting Inspection'},
          ]
        },
        'fire': {
          'status': 'ACTION_REQUIRED',
          'number': '',
          'expiry': '',
          'docName': '',
        },
        'gst': {
          'status': 'NOT_STARTED',
          'number': '',
          'expiry': '',
          'docName': '',
        }
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Govt Licenses & Verifications',
          style: GoogleFonts.dmSans(
            color: AppColors.darkText,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          if (state is HostelInitial || state is HostelLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }

          if (state is HostelLoaded) {
            if (state.hostels.isEmpty) {
              return Center(
                child: Text(
                  'No properties available.',
                  style: GoogleFonts.dmSans(color: AppColors.greyText, fontSize: 14.sp),
                ),
              );
            }

            _initMockData(state.hostels);
            _selectedHostel ??= state.hostels[state.selectedHostelIndex < state.hostels.length ? state.selectedHostelIndex : 0];

            final currentData = _mockCompliances[_selectedHostel!.id] ?? {};

            return Column(
              children: [
                _buildPropertySelector(state.hostels),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    children: [
                      _buildHeaderCard(),
                      SizedBox(height: 20.h),
                      Text(
                        'REQUIRED COMPLIANCES',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyText,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildComplianceItem(
                        key: 'fssai',
                        title: 'FSSAI Food Safety License',
                        subtitle: 'Required for properties offering catering or food services.',
                        icon: Icons.restaurant_menu_rounded,
                        accentColor: Colors.orange,
                        data: currentData['fssai'],
                      ),
                      _buildComplianceItem(
                        key: 'trade',
                        title: 'Trade & Business License',
                        subtitle: 'Authorizes commercial lodging operations in the municipal area.',
                        icon: Icons.business_center_rounded,
                        accentColor: Colors.blue,
                        data: currentData['trade'],
                      ),
                      _buildComplianceItem(
                        key: 'police',
                        title: 'Police Verification & NOC',
                        subtitle: 'Local jurisdiction verification for guest and tenant safety.',
                        icon: Icons.local_police_rounded,
                        accentColor: Colors.teal,
                        data: currentData['police'],
                      ),
                      _buildComplianceItem(
                        key: 'fire',
                        title: 'Fire Safety NOC',
                        subtitle: 'Certification of fire safety measures and emergency planning.',
                        icon: Icons.local_fire_department_rounded,
                        accentColor: Colors.red,
                        data: currentData['fire'],
                      ),
                      _buildComplianceItem(
                        key: 'gst',
                        title: 'GSTIN Registration',
                        subtitle: 'Tax registration for hospitality commercial invoicing.',
                        icon: Icons.percent_rounded,
                        accentColor: Colors.purple,
                        data: currentData['gst'],
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Failed to load properties.'));
        },
      ),
    );
  }

  Widget _buildPropertySelector(List<Hostel> hostels) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT PROPERTY',
            style: GoogleFonts.dmSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.greyText,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: () => _showPropertySelectorSheet(hostels),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.business_rounded, color: AppColors.primaryBlue, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedHostel!.name,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          _selectedHostel!.address,
                          style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            color: AppColors.greyText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.greyText, size: 24.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPropertySelectorSheet(List<Hostel> hostels) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Text(
                  'Select Property',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const Divider(color: Color(0xFFE2E8F0)),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: hostels.length,
                  itemBuilder: (context, index) {
                    final hostel = hostels[index];
                    final isSelected = hostel.id == _selectedHostel!.id;

                    return ListTile(
                      onTap: () {
                        setState(() {
                          _selectedHostel = hostel;
                        });
                        Navigator.pop(context);
                      },
                      leading: Icon(
                        Icons.business_rounded,
                        color: isSelected ? AppColors.primaryBlue : AppColors.greyText,
                      ),
                      title: Text(
                        hostel.name,
                        style: GoogleFonts.dmSans(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryBlue : AppColors.darkText,
                          fontSize: 14.sp,
                        ),
                      ),
                      subtitle: Text(
                        hostel.address,
                        style: GoogleFonts.dmSans(fontSize: 11.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue)
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_rounded, color: Colors.orange.shade300, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Legal Compliance Center',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Upload required government licenses and NOCs to verify and list your property safely on Stay India.',
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceItem({
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Map<String, dynamic>? data,
  }) {
    if (data == null) return const SizedBox.shrink();
    final status = data['status'] as String? ?? 'NOT_STARTED';
    final number = data['number'] as String? ?? '';

    Color statusColor;
    String statusText;

    switch (status) {
      case 'VERIFIED':
        statusColor = Colors.green;
        statusText = 'Verified';
        break;
      case 'IN_PROGRESS':
        statusColor = Colors.orange;
        statusText = 'In Progress';
        break;
      case 'ACTION_REQUIRED':
        statusColor = Colors.red;
        statusText = 'Action Required';
        break;
      case 'PENDING_UPLOAD':
        statusColor = Colors.blue;
        statusText = 'Pending Upload';
        break;
      default:
        statusColor = AppColors.greyText;
        statusText = 'Not Started';
    }

    return BouncingWrapper(
      onTap: () => _showComplianceDetails(key, title, icon, accentColor, data),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5.sp,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 0.8),
                        ),
                        child: Text(
                          statusText,
                          style: GoogleFonts.dmSans(
                            color: statusColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 11.sp,
                      color: AppColors.greyText,
                      height: 1.3,
                    ),
                  ),
                  if (number.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.vpn_key_rounded, color: AppColors.greyText, size: 12.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'ID: $number',
                          style: GoogleFonts.dmSans(
                            fontSize: 11.sp,
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplianceDetails(
    String key,
    String title,
    IconData icon,
    Color accentColor,
    Map<String, dynamic> data,
  ) {
    final status = data['status'] as String? ?? 'NOT_STARTED';
    final number = data['number'] as String? ?? '';
    final expiry = data['expiry'] as String? ?? '';
    final docName = data['docName'] as String? ?? '';
    final steps = data['steps'] as List<dynamic>?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: accentColor, size: 24.sp),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  if (status == 'VERIFIED') ...[
                    _buildDetailField('License Number', number),
                    _buildDetailField('Expiry Date', expiry),
                    _buildDetailField('Attached Document', docName),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Downloading Certificate...')),
                              );
                            },
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Download PDF'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(color: AppColors.primaryBlue),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (status == 'IN_PROGRESS' && steps != null) ...[
                    Text(
                      'VERIFICATION TIMELINE',
                      style: GoogleFonts.dmSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyText,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ...List.generate(steps.length, (index) {
                      final step = steps[index] as Map<String, dynamic>;
                      final isDone = step['done'] as bool;
                      final stepTitle = step['title'] as String;
                      final stepDate = step['date'] as String;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 20.r,
                                height: 20.r,
                                decoration: BoxDecoration(
                                  color: isDone ? Colors.teal : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: isDone
                                    ? Icon(Icons.check, color: Colors.white, size: 12.sp)
                                    : null,
                              ),
                              if (index < steps.length - 1)
                                Container(
                                  width: 2.w,
                                  height: 30.h,
                                  color: isDone ? Colors.teal : Colors.grey.shade200,
                                ),
                            ],
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stepTitle,
                                  style: GoogleFonts.dmSans(
                                    fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                    color: isDone ? AppColors.darkText : AppColors.greyText,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                Text(
                                  stepDate,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11.sp,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ] else ...[
                    Text(
                      'SUBMIT APPLICATION DETAILS',
                      style: GoogleFonts.dmSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyText,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'License / Registration ID',
                        labelStyle: GoogleFonts.dmSans(fontSize: 13.sp),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecting PDF/Image document...')),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.cloud_upload_rounded, color: AppColors.primaryBlue, size: 36.sp),
                              SizedBox(height: 8.h),
                              Text(
                                'Upload Certificate Copy (PDF or Image)',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.sp,
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Max size 5 MB',
                                style: GoogleFonts.dmSans(fontSize: 10.sp, color: AppColors.greyText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                data['status'] = 'IN_PROGRESS';
                                data['number'] = 'APP-${DateTime.now().millisecond}';
                                data['steps'] = [
                                  {'title': 'Form Submitted', 'done': true, 'date': 'Today'},
                                  {'title': 'Documents Verification', 'done': false, 'date': 'Pending Review'},
                                  {'title': 'Inspection Scheduled', 'done': false, 'date': 'Awaiting Verification'},
                                ];
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Compliance application submitted successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: const Text('Submit Verification Request'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.greyText,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
