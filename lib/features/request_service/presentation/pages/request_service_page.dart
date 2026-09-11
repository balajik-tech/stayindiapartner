import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/request_service/presentation/cubit/request_service_cubit.dart';
import 'package:stayindia_owner/features/request_service/presentation/pages/my_requests_page.dart';
import 'package:stayindia_owner/injection_container.dart';

class ServiceOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const ServiceOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

class RequestServicePage extends StatefulWidget {
  const RequestServicePage({super.key});

  @override
  State<RequestServicePage> createState() => _RequestServicePageState();
}

class _RequestServicePageState extends State<RequestServicePage> {
  final TextEditingController _detailsController = TextEditingController();
  late final RequestServiceCubit _cubit;

  ServiceOption? _selectedService;
  late DateTime _selectedDate;
  String _selectedSlot = 'Morning'; // 'Morning' or 'Evening'
  Hostel? _selectedHostel;
  final Set<String> _activeTags = {};

  final List<ServiceOption> _services = const [
    ServiceOption(
      id: 'cook',
      title: 'Cook',
      subtitle: 'Full meal prep for residents',
      icon: Icons.soup_kitchen_outlined,
      bgColor: Color(0xFFFFF3E0),
      iconColor: Color(0xFFEA580C),
    ),
    ServiceOption(
      id: 'assistant_cook',
      title: 'Assistant cook',
      subtitle: 'Prep, chopping, cleanup',
      icon: Icons.flatware_rounded,
      bgColor: Color(0xFFFCE4EC),
      iconColor: Color(0xFFEC4899),
    ),
    ServiceOption(
      id: 'electrician',
      title: 'Electrician',
      subtitle: 'Wiring, fittings, repairs',
      icon: Icons.bolt_rounded,
      bgColor: Color(0xFFFEF9C3),
      iconColor: Color(0xFFD97706),
    ),
    ServiceOption(
      id: 'carpenter',
      title: 'Carpenter',
      subtitle: 'Beds, doors, furniture',
      icon: Icons.handyman_rounded,
      bgColor: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
    ),
    ServiceOption(
      id: 'plumber',
      title: 'Plumber',
      subtitle: 'Leaks, taps, drainage',
      icon: Icons.water_drop_outlined,
      bgColor: Color(0xFFE0F7FA),
      iconColor: Color(0xFF0891B2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cubit = sl<RequestServiceCubit>();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _showPropertyPicker(List<Hostel> hostels) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Property',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: 8.h),
              ListView.separated(
                shrinkWrap: true,
                itemCount: hostels.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final hostel = hostels[index];
                  final isSelected = _selectedHostel?.id == hostel.id;
                  return BouncingWrapper(
                    onTap: () {
                      setState(() {
                        _selectedHostel = hostel;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEFF6FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF7A00,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.apartment_rounded,
                              color: const Color(0xFFFF7A00),
                              size: 24.r,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hostel.name,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '${hostel.totalBeds ?? 0} beds',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF2563EB),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  void _showServicePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 10.h,
            bottom: MediaQuery.of(context).padding.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select a service',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.r,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Options List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _services.length,
                separatorBuilder: (_, _) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final isSelected = _selectedService?.id == service.id;
                  return BouncingWrapper(
                    onTap: () {
                      setState(() {
                        _selectedService = service;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          // Custom color icon background
                          Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              color: service.bgColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              service.icon,
                              color: service.iconColor,
                              size: 22.r,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          // Title & Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.title,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  service.subtitle,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Radio selection indicator
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFCBD5E1),
                            size: 24.r,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_activeTags.contains(tag)) {
        _activeTags.remove(tag);
      } else {
        _activeTags.add(tag);
      }
    });
  }

  void _handleSubmit(Hostel currentHostel) async {
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service before sending request.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final String dateFormatted = DateFormat('E d MMM').format(_selectedDate);

    await _cubit.createRequest(
      hostelId: currentHostel.id,
      serviceType: _selectedService!.title,
      date: dateFormatted,
      slot: _selectedSlot,
      details: _detailsController.text.trim(),
      tags: _activeTags.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hostelState = context.watch<HostelCubit>().state;
    final List<Hostel> hostels = hostelState is HostelLoaded
        ? hostelState.hostels
        : [];

    if (hostels.isNotEmpty && _selectedHostel == null) {
      _selectedHostel = hostelState is HostelLoaded
          ? hostels[hostelState.selectedHostelIndex < hostels.length
                ? hostelState.selectedHostelIndex
                : 0]
          : hostels.first;
    }

    final Hostel activeHostel =
        _selectedHostel ??
        (hostels.isNotEmpty
            ? hostels.first
            : Hostel(
                id: 'default',
                name: 'Default Hostel',
                address: '',
                floors: 1,
                hostelType: 'Co-Ed',
                totalBeds: 16,
              ));

    final String dateShortStr = DateFormat('E d MMM').format(_selectedDate);

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<RequestServiceCubit, RequestServiceState>(
        listener: (context, state) {
          if (state is RequestServiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Service request sent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MyRequestsPage()),
            );
          } else if (state is RequestServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
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
              'Request a service',
              style: TextStyle(
                color: const Color(0xFF1E293B),
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
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Property Card
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE65100),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.apartment_rounded,
                                  color: Colors.white,
                                  size: 24.r,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Property',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      '${activeHostel.name} · ${activeHostel.totalBeds ?? 0} beds',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (hostels.length > 1)
                                TextButton(
                                  onPressed: () => _showPropertyPicker(hostels),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Change',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // 2. Service Section
                        Text(
                          'Service',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        BouncingWrapper(
                          onTap: _showServicePicker,
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    _selectedService?.icon ??
                                        Icons.build_rounded,
                                    color: const Color(0xFF64748B),
                                    size: 22.r,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedService?.title ??
                                            'Select a service',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedService != null
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        _selectedService?.subtitle ??
                                            'Cook, electrician, plumber and more',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: const Color(0xFF94A3B8),
                                  size: 24.r,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // 3. Date Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _pickCustomDate,
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                size: 14.r,
                                color: const Color(0xFF2563EB),
                              ),
                              label: Text(
                                'Calendar',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                side: const BorderSide(
                                  color: Color(0xFFDBEAFE),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 70.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            separatorBuilder: (_, _) => SizedBox(width: 10.w),
                            itemBuilder: (context, index) {
                              if (index == 4) {
                                return BouncingWrapper(
                                  onTap: _pickCustomDate,
                                  child: Container(
                                    width: 64.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 18.r,
                                          color: const Color(0xFF64748B),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'More',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final date = DateTime.now().add(
                                Duration(days: index),
                              );
                              final isSelected = DateUtils.isSameDay(
                                _selectedDate,
                                date,
                              );

                              String label = DateFormat('E').format(date);
                              if (index == 0) label = 'Today';
                              if (index == 1) label = 'Tom';

                              return BouncingWrapper(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                },
                                child: Container(
                                  width: 64.w,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1E40AF)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF1E40AF)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF1E40AF,
                                              ).withValues(alpha: 0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white70
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        DateFormat('d').format(date),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // 4. Slot Section
                        Text(
                          'Slot',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: BouncingWrapper(
                                onTap: () {
                                  setState(() {
                                    _selectedSlot = 'Morning';
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 14.h,
                                    horizontal: 12.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedSlot == 'Morning'
                                        ? const Color(0xFFFFF7ED)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: _selectedSlot == 'Morning'
                                          ? const Color(0xFFF97316)
                                          : const Color(0xFFE2E8F0),
                                      width: _selectedSlot == 'Morning'
                                          ? 1.5
                                          : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.wb_sunny_outlined,
                                        color: const Color(0xFFD97706),
                                        size: 24.r,
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        'Morning',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedSlot == 'Morning'
                                              ? const Color(0xFFD97706)
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '7 am – 12 pm',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: BouncingWrapper(
                                onTap: () {
                                  setState(() {
                                    _selectedSlot = 'Evening';
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 14.h,
                                    horizontal: 12.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedSlot == 'Evening'
                                        ? const Color(0xFFF0F9FF)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: _selectedSlot == 'Evening'
                                          ? const Color(0xFF0284C7)
                                          : const Color(0xFFE2E8F0),
                                      width: _selectedSlot == 'Evening'
                                          ? 1.5
                                          : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.dark_mode_outlined,
                                        color: const Color(0xFF0284C7),
                                        size: 24.r,
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        'Evening',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedSlot == 'Evening'
                                              ? const Color(0xFF0284C7)
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '4 pm – 9 pm',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // 5. Details Section
                        Row(
                          children: [
                            Text(
                              'Details ',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            Text(
                              'optional',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        TextField(
                          controller: _detailsController,
                          minLines: 3,
                          maxLines: 5,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Two switchboards in G03 sparking',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.all(14.r),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            _buildTagChip('Urgent'),
                            SizedBox(width: 8.w),
                            _buildTagChip('Bring own tools'),
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),

                // 6. Sticky Bottom Action Footer
                BlocBuilder<RequestServiceCubit, RequestServiceState>(
                  builder: (context, state) {
                    final isLoading = state is RequestServiceLoading;
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedService?.title ?? 'No service chosen',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$dateShortStr · $_selectedSlot',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _handleSubmit(activeHostel),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7A00),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 24.r,
                                      width: 24.r,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Send request',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    final isSelected = _activeTags.contains(tag);
    return BouncingWrapper(
      onTap: () => _toggleTag(tag),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
