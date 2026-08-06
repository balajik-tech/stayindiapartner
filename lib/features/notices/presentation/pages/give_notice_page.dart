import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/features/tenants/domain/usecases/tenant_usecases.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/notices/presentation/cubit/notice_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';

enum NoticeType { general, vacant }

class NoticeTemplate {
  final String icon;
  final String label;
  final String title;
  final String content;

  const NoticeTemplate({
    required this.icon,
    required this.label,
    required this.title,
    required this.content,
  });
}

class GiveNoticePage extends StatefulWidget {
  final TenantEntity? tenant;
  const GiveNoticePage({super.key, this.tenant});

  @override
  State<GiveNoticePage> createState() => _GiveNoticePageState();
}

class _GiveNoticePageState extends State<GiveNoticePage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _titleController = TextEditingController();
  final _tenantSearchController = TextEditingController();

  NoticeType _noticeType = NoticeType.vacant;
  bool _sendToAllTenants = false;
  DateTime _noticeDate = DateTime.now();
  DateTime _vacatingDate = DateTime.now().add(const Duration(days: 30));

  TenantEntity? _selectedTenant;
  List<TenantEntity> _allTenants = [];
  List<TenantEntity> _filteredTenants = [];
  bool _isLoadingTenants = false;

  final List<NoticeTemplate> _generalTemplates = const [
    NoticeTemplate(
      icon: '🌴',
      label: 'Festival Leave',
      title: 'Festival Vacation Update',
      content: 'Going home for the festival? Please update your travel dates and return date in the app now for our records.',
    ),
    NoticeTemplate(
      icon: '✈️',
      label: 'Leave Mode',
      title: 'Turn On Leave Mode',
      content: 'Traveling out? Kindly turn on the \'Leave/Out of Station\' mode in your app and set your correct return date.',
    ),
    NoticeTemplate(
      icon: '🍽️',
      label: 'Food Plan',
      title: 'Food Attendance Mapping',
      content: 'Please update your return status in the app before arriving, so the kitchen team can prepare food accordingly.',
    ),
    NoticeTemplate(
      icon: '⚠️',
      label: '1-Month Notice',
      title: '1-Month Prior Notice Required',
      content: 'Planning to vacate? As per policy, you must submit your 1-month prior Notice Period directly through the app.',
    ),
    NoticeTemplate(
      icon: '📱',
      label: 'App Notice',
      title: 'Intimation Through App Only',
      content: 'Important: Vacating notices will not be accepted over calls or messages. Please submit it only via the app.',
    ),
    NoticeTemplate(
      icon: '✅',
      label: 'Checkout',
      title: 'Checkout Inspection & Dues',
      content: 'Before final checkout, ensure all your pending dues are cleared in the app for a smooth exit approval.',
    ),
    NoticeTemplate(
      icon: '🍳',
      label: 'Breakfast',
      title: 'Breakfast Active Alert',
      content: 'Breakfast is ready and active now. Please visit the mess hall before timings end.',
    ),
    NoticeTemplate(
      icon: '🍛',
      label: 'Lunch',
      title: 'Lunch Active Alert',
      content: 'Lunch is officially served. Kindly have your meal on time today.',
    ),
    NoticeTemplate(
      icon: '☕',
      label: 'Snacks',
      title: 'Evening Snacks Alert',
      content: 'Evening tea and snacks are ready at the counter. Please collect yours.',
    ),
    NoticeTemplate(
      icon: '🍲',
      label: 'Dinner',
      title: 'Dinner Active Alert',
      content: 'Dinner is served. Please visit the dining area before the kitchen closes for the night.',
    ),
    NoticeTemplate(
      icon: '🔒',
      label: '10 PM Gate',
      title: 'Strict 10:00 PM Gate Lock',
      content: 'Gate closing reminder: All residents must be inside by 10:00 PM. The main gates will be locked sharp at 10:00 PM.',
    ),
    NoticeTemplate(
      icon: '👥',
      label: 'Guests',
      title: '2-Hour Advance Guest Intimation',
      content: 'Visiting Parents/Friends? Kindly inform the management through the app at least 2 hours in advance for entry permission.',
    ),
    NoticeTemplate(
      icon: '🔑',
      label: 'Lock Doors',
      title: 'Lock Doors Securely',
      content: 'Security Alert: Please ensure your room doors are securely locked whenever you step out.',
    ),
    NoticeTemplate(
      icon: '💡',
      label: 'Save Energy',
      title: 'Turn Off Appliances',
      content: 'Save Energy: Kindly turn off all lights, fans, and AC units before leaving your room.',
    ),
    NoticeTemplate(
      icon: '🗝️',
      label: 'Handover Keys',
      title: 'Handover Keys Before Leaving',
      content: 'Traveling or Vacating? Do not forget to handover your room keys to the warden/reception before leaving.',
    ),
    NoticeTemplate(
      icon: '🛠️',
      label: 'Maintenance',
      title: 'Scheduled Maintenance Work',
      content:
          'Please note that scheduled maintenance work will be carried out today. Water supply/electricity may be briefly interrupted. We apologize for any inconvenience caused.',
    ),
    NoticeTemplate(
      icon: '💰',
      label: 'Rent Reminder',
      title: 'Rent Payment Due Reminder',
      content:
          'Dear Tenants, this is a friendly reminder that your monthly rent is due. Kindly make the payment and upload/share the receipt as soon as possible.',
    ),
    NoticeTemplate(
      icon: '📶',
      label: 'WiFi Downtime',
      title: 'Internet Connection Maintenance',
      content:
          'Our internet service provider is conducting emergency maintenance. The WiFi services will be temporarily unavailable for the next 2 hours.',
    ),
    NoticeTemplate(
      icon: '🧹',
      label: 'Cleanliness',
      title: 'Common Area Cleanliness',
      content:
          'Please help keep our PG clean and hygienic. Kindly throw garbage only in the designated bins and keep the common areas tidy after use.',
    ),
  ];

  final List<NoticeTemplate> _vacantTemplates = const [
    NoticeTemplate(
      icon: '💼',
      label: 'Job Relocation',
      title: '',
      content:
          'Relocating to a new city/office location for employment reasons.',
    ),
    NoticeTemplate(
      icon: '🎓',
      label: 'Studies',
      title: '',
      content:
          'Moving out to pursue higher education / university courses elsewhere.',
    ),
    NoticeTemplate(
      icon: '📜',
      label: 'Agreement Expired',
      title: '',
      content: 'Tenancy contract period completed and agreement is expiring.',
    ),
    NoticeTemplate(
      icon: '🏡',
      label: 'Personal Reason',
      title: '',
      content:
          'Returning to hometown / relocating due to personal or health-related reasons.',
    ),
    NoticeTemplate(
      icon: '⚠️',
      label: 'Rent Overdue',
      title: '',
      content:
          'Requested to vacate due to outstanding rent dues and continuous non-payment despite reminders.',
    ),
    NoticeTemplate(
      icon: '🚫',
      label: 'Behavior Issue',
      title: '',
      content:
          'Requested to vacate due to continuous behavioral issues and violation of PG/hostel guidelines.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.tenant != null) {
      _selectedTenant = widget.tenant;
    }
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    setState(() => _isLoadingTenants = true);
    try {
      final hostelState = context.read<HostelCubit>().state;
      if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
        final hostelId =
            hostelState.hostels[hostelState.selectedHostelIndex].id;

        final tenants = await sl<GetTenantsForHostelUseCase>()(hostelId);
        if (!mounted) return;
        setState(() {
          _allTenants = tenants;
          _isLoadingTenants = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingTenants = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTenants = false);
    }
  }

  void _filterTenants(String query) {
    setState(() {
      _filteredTenants = _allTenants.where((t) {
        final fullName = t.fullName.toLowerCase();
        final mobile = t.mobile.toLowerCase();
        return fullName.contains(query.toLowerCase()) || mobile.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NoticeCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColors.darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Give Notice',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocListener<NoticeCubit, NoticeState>(
          listener: (context, state) {
            if (state is NoticeSuccess) {
              if (_noticeType == NoticeType.general) {
                _showGeneralNoticeSuccessDialog(context);
              } else {
                _showVacantNoticeSuccessDialog(context);
              }
            } else if (state is NoticeSubmitError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24.w,
              24.h,
              24.w,
              MediaQuery.of(context).padding.bottom + 24.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeToggle(),
                  SizedBox(height: 32.h),

                  if (_noticeType == NoticeType.general) ...[
                    _buildGeneralNoticeSection(),
                  ] else ...[
                    _buildVacantNoticeSection(),
                  ],

                  SizedBox(height: 48.h),
                  _buildSubmitButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildTenantSelector() {
    return Column(
      children: [
        TextFormField(
          controller: _tenantSearchController,
          decoration: InputDecoration(
            hintText: 'Search tenant by name or phone',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isLoadingTenants
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.roomCardBorder),
            ),
          ),
          onChanged: _filterTenants,
        ),
        if (_tenantSearchController.text.isNotEmpty && _selectedTenant == null)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredTenants.length,
              itemBuilder: (context, index) {
                final t = _filteredTenants[index];
                return ListTile(
                  title: Text(t.fullName),
                  subtitle: Text('${t.mobile}  ${t.roomTypename}'),
                  onTap: () {
                    setState(() {
                      _selectedTenant = t;
                      _tenantSearchController.clear();
                      _filteredTenants = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedTenantInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              _selectedTenant!.firstName[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTenant!.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  '${_selectedTenant!.roomTypename}  Bed: ${_selectedTenant!.bedNumber}',
                  style: TextStyle(color: AppColors.greyText, fontSize: 13.sp),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => setState(() => _selectedTenant = null),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime selectedDate,
    Function(DateTime) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2025),
              lastDate: DateTime(2030),
            );
            if (date != null) onSelected(date);
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.roomCardBorder),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8.w),
                Text(
                  DateFormat('dd MMM yyyy').format(selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildTypeButton('General Notice', NoticeType.general),
          _buildTypeButton('Vacant Notice', NoticeType.vacant),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, NoticeType type) {
    final isSelected = _noticeType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _noticeType = type),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppColors.primaryBlue : AppColors.greyText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralNoticeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Recipients'),
            Row(
              children: [
                Text(
                  'All Tenants',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                ),
                Switch(
                  value: _sendToAllTenants,
                  onChanged: (val) => setState(() => _sendToAllTenants = val),
                  activeThumbColor: AppColors.primaryBlue,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (!_sendToAllTenants) ...[
          _buildTenantSelector(),
          if (_selectedTenant != null) ...[
            SizedBox(height: 16.h),
            _buildSelectedTenantInfo(),
          ],
          SizedBox(height: 24.h),
        ],
        _buildTemplatesSection(_generalTemplates),
        SizedBox(height: 24.h),
        _buildSectionTitle('Title'),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g. Water Maintenance Update',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.roomCardBorder),
            ),
          ),
          validator: (val) =>
              val == null || val.isEmpty ? 'Please enter a title' : null,
        ),
        SizedBox(height: 24.h),
        _buildSectionTitle('Message Content'),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _reasonController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your message here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.roomCardBorder),
            ),
          ),
          validator: (val) => val == null || val.isEmpty
              ? 'Please enter message content'
              : null,
        ),
      ],
    );
  }

  Widget _buildVacantNoticeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tenant Details'),
        SizedBox(height: 16.h),
        _buildTenantSelector(),
        if (_selectedTenant != null) ...[
          SizedBox(height: 16.h),
          _buildSelectedTenantInfo(),
        ],
        SizedBox(height: 32.h),
        _buildSectionTitle('Dates'),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                'Notice Date',
                _noticeDate,
                (d) => setState(() => _noticeDate = d),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildDatePicker(
                'Vacating Date',
                _vacatingDate,
                (d) => setState(() => _vacatingDate = d),
              ),
            ),
          ],
        ),
        _buildTemplatesSection(_vacantTemplates),
        SizedBox(height: 24.h),
        _buildSectionTitle('Reason (Optional)'),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g. Relocating for work',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.roomCardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.roomCardBorder),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<NoticeCubit, NoticeState>(
      builder: (context, state) {
        final isLoading = state is NoticeSubmitting;
        final isReady = _noticeType == NoticeType.general
            ? (_sendToAllTenants || _selectedTenant != null)
            : (_selectedTenant != null);

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (!isReady || isLoading) ? null : () => _submit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Confirm Notice',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTemplatesSection(List<NoticeTemplate> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Templates'),
        SizedBox(height: 12.h),
        SizedBox(
          height: 48.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final t = templates[index];
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ActionChip(
                  avatar: Text(t.icon, style: TextStyle(fontSize: 14.sp)),
                  label: Text(
                    t.label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  backgroundColor: const Color(0xFFF1F5F9),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_noticeType == NoticeType.general) {
                        _titleController.text = t.title;
                      }
                      _reasonController.text = t.content;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showGeneralNoticeSuccessDialog(BuildContext context) async {
    final recipientLabel = _sendToAllTenants
        ? 'All tenants will get it as an app notification and SMS.'
        : '${_selectedTenant?.fullName ?? 'Tenant'} (${_selectedTenant?.roomTypename ?? ''}${_selectedTenant?.bedNumber != null ? ', Bed ${_selectedTenant?.bedNumber}' : ''}) will get it as an app notification and SMS.';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    child: Center(
                      child: Container(
                        width: 82.sp,
                        height: 82.sp,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFCAEAC8),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 50.sp,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 6.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Notice sent',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        Text(
                          recipientLabel,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: const Color(0xFF636260),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                              Navigator.of(context).pop(); // Back to previous screen
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            child: Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _submit(context);
                          },
                          child: Text(
                            'Send another notice',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showVacantNoticeConfirmationDialog(BuildContext context) async {
    final noticeDays = _vacatingDate.difference(_noticeDate).inDays;
    final bookingAvailabilityDate = DateFormat('dd MMM').format(_vacatingDate);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm vacate notice',
                style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8.h),
              Text(
                'Check the details before recording',
                style: GoogleFonts.inter(fontSize: 14.sp, color: Color(0xFF636260)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfcfcfb),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTenant?.fullName ?? '',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp,color: Colors.black),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '${_selectedTenant?.roomTypename ?? ''} - Bed ${_selectedTenant?.bedNumber ?? ''}',
                            style: TextStyle(fontSize: 13.sp,  color: Color(0xFF636260)),
                          ),

                          SizedBox(height: 16.h),
                          _buildConfirmationRow('Notice date', DateFormat('dd MMM yyyy').format(_noticeDate)),
                          SizedBox(height: 12.h),
                          _buildConfirmationRow('Vacating date', DateFormat('dd MMM yyyy').format(_vacatingDate)),
                          SizedBox(height: 12.h),
                          _buildConfirmationRow('Notice period', '$noticeDays days'),
                          SizedBox(height: 12.h),
                          _buildConfirmationRow('Reason', _reasonController.text.isEmpty ? 'Job relocation' : _reasonController.text),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFcce3fb),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color:  AppColors.primaryBlue, size: 20.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Bed ${_selectedTenant?.bedNumber ?? ''} in ${_selectedTenant?.roomTypename ?? ''} becomes available for booking from $bookingAvailabilityDate. Rent is calculated up to that date.',
                              style: TextStyle(fontSize: 12.sp, color: AppColors.primaryBlue,fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkText,
                          side: BorderSide(color: AppColors.roomCardBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text('Go back',
                          style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _submitVacantNotice(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                        ),
                        child: Text('Confirm',
                          style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        ),),
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

  Widget _buildConfirmationRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Color(0xFF636260)),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600,color: Colors.black),
          ),
        ),
      ],
    );
  }

  Future<void> _showVacantNoticeSuccessDialog(BuildContext context) async {
    final vacatingDateText = DateFormat('dd MMM yyyy').format(_vacatingDate);
    final noticeDays = _vacatingDate.difference(_noticeDate).inDays;
    final roomLabel = '${_selectedTenant?.roomTypename ?? ''} - Bed ${_selectedTenant?.bedNumber ?? ''}';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F7EE),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    color: const Color(0xFF2F855A),
                    size: 56.sp,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Vacate notice recorded',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '${_selectedTenant?.fullName ?? 'Tenant'} has been notified on the app and by SMS.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16.sp, color: AppColors.primaryBlue),
                              SizedBox(width: 8.w),
                              Text(
                                'Vacating on $vacatingDateText',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '$noticeDays days from today',
                            style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roomLabel,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Open for new bookings from $vacatingDateText',
                            style: TextStyle(fontSize: 13.sp, color: AppColors.greyText),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
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

  void _resetGeneralNoticeForm() {
    setState(() {
      _titleController.clear();
      _reasonController.clear();
    });
  }

  void _submitVacantNotice(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is! HostelLoaded || hostelState.hostels.isEmpty) return;

    final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
    if (_selectedTenant != null) {
      context.read<NoticeCubit>().createNotice(
            hostelId: hostelId,
            tenantId: _selectedTenant!.id,
            roomId: _selectedTenant!.roomId,
            bedNumber: _selectedTenant!.bedNumber,
            vacatingDate: DateFormat('yyyy-MM-dd').format(_vacatingDate),
            reason: _reasonController.text,
          );
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is! HostelLoaded || hostelState.hostels.isEmpty) return;

    if (_noticeType == NoticeType.general) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      context.read<NoticeCubit>().postAnnouncement(
        hostelId: hostelId,
        title: _titleController.text,
        content: _reasonController.text,
      );
    } else {
      if (_selectedTenant != null) {
        _showVacantNoticeConfirmationDialog(context);
      }
    }
  }
}
