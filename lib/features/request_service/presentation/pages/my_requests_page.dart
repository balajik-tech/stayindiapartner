import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/request_service/presentation/cubit/request_service_cubit.dart';
import 'package:stayindia_owner/features/request_service/presentation/pages/request_service_page.dart';
import 'package:stayindia_owner/injection_container.dart';

class ServiceRequestItem {
  final String id;
  final String serviceType;
  final String code;
  final String date;
  final String slot;
  final String status; // 'Awaiting confirmation', 'Staff assigned', 'In progress', 'Completed'
  final String? statusDetail;
  final String? priority; // e.g. 'Urgent'
  final bool isPast;

  const ServiceRequestItem({
    required this.id,
    required this.serviceType,
    required this.code,
    required this.date,
    required this.slot,
    required this.status,
    this.statusDetail,
    this.priority,
    this.isPast = false,
  });
}

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  late final RequestServiceCubit _cubit;
  String _activeFilter = 'Active'; // 'Active', 'All', 'Past'

  // Default demonstration items matching screenshot design
  final List<ServiceRequestItem> _mockRequests = const [
    ServiceRequestItem(
      id: 'sr-2419',
      serviceType: 'Plumber',
      code: 'SR-2419',
      date: 'Today',
      slot: 'Evening',
      status: 'Awaiting confirmation',
      statusDetail: 'Finding staff',
      priority: 'Urgent',
      isPast: false,
    ),
    ServiceRequestItem(
      id: 'sr-2418',
      serviceType: 'Electrician',
      code: 'SR-2418',
      date: 'Today',
      slot: 'Evening',
      status: 'Staff assigned',
      statusDetail: 'Ramesh K assigned',
      isPast: false,
    ),
    ServiceRequestItem(
      id: 'sr-2417',
      serviceType: 'Cook',
      code: 'SR-2417',
      date: 'Today',
      slot: 'Evening',
      status: 'In progress',
      statusDetail: 'Started 5:12 pm',
      isPast: false,
    ),
    ServiceRequestItem(
      id: 'sr-2410',
      serviceType: 'Assistant cook',
      code: 'SR-2410',
      date: '8 Sep',
      slot: 'Morning',
      status: 'Completed',
      statusDetail: 'Finished 11:30 am',
      isPast: true,
    ),
    ServiceRequestItem(
      id: 'sr-2405',
      serviceType: 'Carpenter',
      code: 'SR-2405',
      date: '5 Sep',
      slot: 'Morning',
      status: 'Completed',
      statusDetail: 'Door lock fixed',
      isPast: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cubit = sl<RequestServiceCubit>();
  }

  Map<String, dynamic> _getServiceStyle(String serviceType) {
    final typeLower = serviceType.toLowerCase();
    if (typeLower.contains('plumb')) {
      return {
        'icon': Icons.water_drop_outlined,
        'bgColor': const Color(0xFFE0F7FA),
        'iconColor': const Color(0xFF0891B2),
      };
    } else if (typeLower.contains('electr')) {
      return {
        'icon': Icons.bolt_rounded,
        'bgColor': const Color(0xFFFEF9C3),
        'iconColor': const Color(0xFFD97706),
      };
    } else if (typeLower.contains('cook') && !typeLower.contains('assistant')) {
      return {
        'icon': Icons.soup_kitchen_outlined,
        'bgColor': const Color(0xFFFFF3E0),
        'iconColor': const Color(0xFFEA580C),
      };
    } else if (typeLower.contains('assistant cook')) {
      return {
        'icon': Icons.flatware_rounded,
        'bgColor': const Color(0xFFFCE4EC),
        'iconColor': const Color(0xFFEC4899),
      };
    } else if (typeLower.contains('carpen')) {
      return {
        'icon': Icons.handyman_rounded,
        'bgColor': const Color(0xFFE0F2FE),
        'iconColor': const Color(0xFF0284C7),
      };
    } else {
      return {
        'icon': Icons.build_rounded,
        'bgColor': const Color(0xFFF1F5F9),
        'iconColor': const Color(0xFF64748B),
      };
    }
  }

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status) {
      case 'Awaiting confirmation':
        return {
          'bgColor': const Color(0xFFFEF3C7),
          'textColor': const Color(0xFFB45309),
        };
      case 'Staff assigned':
        return {
          'bgColor': const Color(0xFFDBEAFE),
          'textColor': const Color(0xFF1D4ED8),
        };
      case 'In progress':
        return {
          'bgColor': const Color(0xFFF3E8FF),
          'textColor': const Color(0xFF7E22CE),
        };
      case 'Completed':
      default:
        return {
          'bgColor': const Color(0xFFDCFCE7),
          'textColor': const Color(0xFF15803D),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostelState = context.watch<HostelCubit>().state;
    final List<Hostel> hostels = hostelState is HostelLoaded ? hostelState.hostels : [];
    final String hostelName = hostels.isNotEmpty ? hostels.first.name : 'kn Reddy';

    return BlocProvider.value(
      value: _cubit,
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
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My requests',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                hostelName,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.add_rounded,
                color: const Color(0xFF1E40AF),
                size: 26.r,
              ),
              tooltip: 'New request',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RequestServicePage()),
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // Filter Chips Bar (Active 3, All 5, Past 2)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    _buildFilterChip('Active', 3),
                    SizedBox(width: 10.w),
                    _buildFilterChip('All', 5),
                    SizedBox(width: 10.w),
                    _buildFilterChip('Past', 2),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Requests List
              Expanded(
                child: BlocBuilder<RequestServiceCubit, RequestServiceState>(
                  builder: (context, state) {
                    List<ServiceRequestItem> currentItems = [];

                    if (state is RequestServiceListLoaded && state.requests.isNotEmpty) {
                      currentItems = state.requests.map((e) {
                        return ServiceRequestItem(
                          id: e.id,
                          serviceType: e.serviceType,
                          code: 'SR-${e.id.substring(0, 4).toUpperCase()}',
                          date: e.date,
                          slot: e.slot,
                          status: e.status,
                          priority: e.tags.contains('Urgent') ? 'Urgent' : null,
                          isPast: e.status.toLowerCase() == 'completed',
                        );
                      }).toList();
                    } else {
                      currentItems = _mockRequests;
                    }

                    final filteredList = currentItems.where((item) {
                      if (_activeFilter == 'Active') return !item.isPast;
                      if (_activeFilter == 'Past') return item.isPast;
                      return true;
                    }).toList();

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 48.r,
                              color: const Color(0xFFCBD5E1),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'No requests found',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildRequestCard(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final bool isSelected = _activeFilter == label;
    return BouncingWrapper(
      onTap: () {
        setState(() {
          _activeFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E40AF) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(ServiceRequestItem item) {
    final style = _getServiceStyle(item.serviceType);
    final statusStyle = _getStatusStyle(item.status);

    return BouncingWrapper(
      onTap: () {},
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row (Icon + Titles + Chevron)
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: style['bgColor'] as Color,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    style['icon'] as IconData,
                    color: style['iconColor'] as Color,
                    size: 22.r,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.serviceType,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${item.code} · ${item.date} · ${item.slot}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFFCBD5E1),
                  size: 24.r,
                ),
              ],
            ),

            SizedBox(height: 14.h),
            const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
            SizedBox(height: 12.h),

            // Bottom Row (Status Badge + Detail Text + Optional Priority Tag)
            Row(
              children: [
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: statusStyle['bgColor'] as Color,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: statusStyle['textColor'] as Color,
                    ),
                  ),
                ),

                if (item.statusDetail != null) ...[
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      item.statusDetail!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),

                if (item.priority != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      item.priority!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
