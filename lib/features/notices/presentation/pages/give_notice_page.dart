import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notice submitted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
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

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is! HostelLoaded || hostelState.hostels.isEmpty) return;

    final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;

    if (_noticeType == NoticeType.general) {
      context.read<NoticeCubit>().postAnnouncement(
        hostelId: hostelId,
        title: _titleController.text,
        content: _reasonController.text,
      );
    } else {
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
  }
}
