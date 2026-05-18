import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';

class RoomMasterPage extends StatelessWidget {
  const RoomMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    String hostelId = '';
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return BlocProvider(
      create: (_) =>
          sl<RoomCubit>()..getRooms(isMaster: true, hostelId: hostelId),
      child: const _RoomMasterView(),
    );
  }
}

class _RoomMasterView extends StatefulWidget {
  const _RoomMasterView();

  @override
  State<_RoomMasterView> createState() => _RoomMasterViewState();
}

class _RoomMasterViewState extends State<_RoomMasterView> {
  String _selectedType = 'AC';
  bool _isEditing = false;
  late List<int> _activeSharingTypes;
  late Map<String, Map<int, Map<String, TextEditingController>>> _controllers;
  late Map<String, Map<int, Map<String, FocusNode>>> _focusNodes;
  bool _initializedFromState = false;

  @override
  void initState() {
    super.initState();
    _activeSharingTypes = [1, 2, 3, 4];
    _controllers = {'AC': {}, 'NON_AC': {}};
    _focusNodes = {'AC': {}, 'NON_AC': {}};

    for (final type in ['AC', 'NON_AC']) {
      for (int s = 1; s <= 10; s++) {
        _controllers[type]![s] = {
          'rent': TextEditingController(),
          'deposit': TextEditingController(),
          'maintenance': TextEditingController(),
          'daily': TextEditingController(),
        };
        _focusNodes[type]![s] = {
          'rent': FocusNode(),
          'deposit': FocusNode(),
          'maintenance': FocusNode(),
          'daily': FocusNode(),
        };

        final rentCtrl = _controllers[type]![s]!['rent']!;
        final dailyCtrl = _controllers[type]![s]!['daily']!;
        rentCtrl.addListener(() {
          if (_isEditing && dailyCtrl.text.isEmpty) {
            final monthly = double.tryParse(rentCtrl.text) ?? 0;
            if (monthly > 0) {
              dailyCtrl.text = (monthly / 30).round().toString();
            }
          }
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<RoomCubit>().state;
      if (state is RoomLoaded) {
        _initializeFromRooms(state.rooms);
      }
    });
  }

  @override
  void dispose() {
    _controllers.forEach((type, sharingMap) {
      sharingMap.forEach((sharing, fieldMap) {
        fieldMap.forEach((field, ctrl) => ctrl.dispose());
      });
    });
    _focusNodes.forEach((type, sharingMap) {
      sharingMap.forEach((sharing, fieldMap) {
        fieldMap.forEach((field, node) => node.dispose());
      });
    });
    super.dispose();
  }

  String _hostelId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  void _initializeFromRooms(List<RoomDetail> rooms) {
    for (final type in ['AC', 'NON_AC']) {
      for (final s in _controllers[type]!.keys) {
        _controllers[type]![s]!['rent']!.text = '';
        _controllers[type]![s]!['deposit']!.text = '';
        _controllers[type]![s]!['maintenance']!.text = '';
        _controllers[type]![s]!['daily']!.text = '';
      }
    }

    final Set<int> activeTypes = {1, 2, 3, 4};
    for (final room in rooms) {
      if (room.isMaster) {
        final int sharing = room.capacity;
        if (sharing >= 1) {
          _addNewSharingType(sharing);
          activeTypes.add(sharing);
          final bool isAC = room.roomType == 'AC';
          final typeKey = isAC ? 'AC' : 'NON_AC';

          _controllers[typeKey]![sharing]!['rent']!.text = room.rent > 0
              ? room.rent.toStringAsFixed(0)
              : '';
          _controllers[typeKey]![sharing]!['deposit']!.text = room.deposit > 0
              ? room.deposit.toStringAsFixed(0)
              : '';
          _controllers[typeKey]![sharing]!['maintenance']!.text =
              room.maintenance > 0 ? room.maintenance.toStringAsFixed(0) : '';
          _controllers[typeKey]![sharing]!['daily']!.text = room.dailyRent > 0
              ? room.dailyRent.toStringAsFixed(0)
              : '';
        }
      }
    }

    setState(() {
      _activeSharingTypes = activeTypes.toList()..sort();
      _initializedFromState = true;
    });
  }

  void _addNewSharingType(int sharing) {
    if (_activeSharingTypes.contains(sharing)) return;

    for (final type in ['AC', 'NON_AC']) {
      if (!_controllers[type]!.containsKey(sharing)) {
        _controllers[type]![sharing] = {
          'rent': TextEditingController(),
          'deposit': TextEditingController(),
          'maintenance': TextEditingController(),
          'daily': TextEditingController(),
        };
        _focusNodes[type]![sharing] = {
          'rent': FocusNode(),
          'deposit': FocusNode(),
          'maintenance': FocusNode(),
          'daily': FocusNode(),
        };

        final rentCtrl = _controllers[type]![sharing]!['rent']!;
        final dailyCtrl = _controllers[type]![sharing]!['daily']!;
        rentCtrl.addListener(() {
          if (_isEditing && dailyCtrl.text.isEmpty) {
            final monthly = double.tryParse(rentCtrl.text) ?? 0;
            if (monthly > 0) {
              dailyCtrl.text = (monthly / 30).round().toString();
            }
          }
        });
      }
    }

    setState(() {
      if (!_activeSharingTypes.contains(sharing)) {
        _activeSharingTypes.add(sharing);
        _activeSharingTypes.sort();
      }
    });
  }

  Future<void> _savePricing(List<RoomDetail> currentLoadedRooms) async {
    final ownerId = context.read<AuthCubit>().currentOwner?.id ?? '';
    final hostelId = _hostelId(context);

    if (ownerId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('owner_session_expired'.tr())));
      return;
    }
    if (hostelId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('no_hostel_found_profile'.tr())));
      return;
    }

    final List<RoomDetail> roomsToSave = [];

    for (final typeKey in ['AC', 'NON_AC']) {
      final bool isAC = typeKey == 'AC';
      for (final sharing in _activeSharingTypes) {
        final rentText = _controllers[typeKey]![sharing]!['rent']!.text.trim();
        final depositText = _controllers[typeKey]![sharing]!['deposit']!.text
            .trim();
        final maintText = _controllers[typeKey]![sharing]!['maintenance']!.text
            .trim();
        final dailyText = _controllers[typeKey]![sharing]!['daily']!.text
            .trim();

        if (rentText.isNotEmpty) {
          final rent = double.tryParse(rentText) ?? 0.0;
          final deposit = double.tryParse(depositText) ?? 0.0;
          final maint = double.tryParse(maintText) ?? 0.0;
          final daily = double.tryParse(dailyText) ?? 0.0;

          final matches = currentLoadedRooms.where(
            (r) =>
                r.isMaster &&
                r.capacity == sharing &&
                r.roomType == (isAC ? 'AC' : 'NON-AC'),
          );
          final String existingId = matches.isNotEmpty ? matches.first.id : '';
          final existingBeds = matches.isNotEmpty
              ? matches.first.beds
              : const <BedInfo>[];
          final existingFloors = matches.isNotEmpty
              ? matches.first.floors
              : const <int>[0];

          roomsToSave.add(
            RoomDetail(
              id: existingId,
              hostelId: hostelId,
              roomTypename: '$sharing Sharing ${isAC ? "AC" : "NON-AC"}',
              floor: 0,
              floors: existingFloors,
              sharingType: sharing == 1
                  ? 'SINGLE'
                  : sharing == 2
                  ? 'DOUBLE'
                  : sharing == 3
                  ? 'TRIPLE'
                  : sharing == 4
                  ? 'QUADRUPLE'
                  : sharing == 5
                  ? 'QUINTUPLE'
                  : 'DORMITORY',
              roomType: isAC ? 'AC' : 'NON-AC',
              rent: rent,
              deposit: deposit,
              maintenance: maint,
              dailyRent: daily,
              isActive: true,
              isMaster: true,
              capacity: sharing,
              beds: existingBeds,
            ),
          );
        }
      }
    }

    setState(() {
      _isEditing = false;
    });

    await context.read<RoomCubit>().bulkUpsertRooms(
      ownerId: ownerId,
      rooms: roomsToSave,
    );
  }

  void _cancelEditing(List<RoomDetail> currentLoadedRooms) {
    setState(() {
      _isEditing = false;
    });
    _initializeFromRooms(currentLoadedRooms);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomCubit, RoomState>(
      listener: (context, state) {
        if (state is RoomOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          final hostelId = _hostelId(context);
          if (hostelId.isNotEmpty) {
            context.read<DashboardCubit>().fetchDashboardData(hostelId);
          }
        } else if (state is RoomError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is RoomLoaded) {
          if (!_isEditing) {
            _initializeFromRooms(state.rooms);
          }
        }
      },
      builder: (context, state) {
        final currentLoadedRooms = state is RoomLoaded
            ? state.rooms
            : <RoomDetail>[];
        final isLoading = state is RoomLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.darkText,
                size: 18.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'room_master'.tr(),
              style: TextStyle(
                color: const Color(0xFF2C5990),
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: isLoading && !_initializedFromState
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                )
              : Column(
                  children: [
                    _buildHeaderSection(),
                    SizedBox(height: 12.h),
                    _buildToggleRow(),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLeftStaticPanel(),
                                  Expanded(child: _buildRightScrollablePanel()),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildBottomBar(currentLoadedRooms),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure standard pricing matrix',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow() {
    final isAC = _selectedType == 'AC';
    return Center(
      child: Container(
        width: 320.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: isAC ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  margin: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B5797),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2B5797).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedType = 'AC';
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        'AC Room Pricing',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: isAC ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedType = 'NON_AC';
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        'Non-AC Pricing',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: !isAC ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftStaticPanel() {
    return Container(
      width: 100.w,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(3, 0),
          ),
        ],
        border: const Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStaticHeaderCell(),
          ..._activeSharingTypes.map((sharing) => _buildStaticRowCell(sharing)),
          if (_isEditing) _buildStaticAddRowCell(),
        ],
      ),
    );
  }

  Widget _buildStaticHeaderCell() {
    return Container(
      height: 44.h,
      color: const Color(0xFFEFF6FF),
      alignment: Alignment.center,
      child: Text(
        'Sharing',
        style: TextStyle(
          color: const Color(0xFF2B5797),
          fontWeight: FontWeight.w900,
          fontSize: 11.sp,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStaticRowCell(int sharing) {
    final isAlternate = sharing % 2 == 0;
    return GestureDetector(
      onLongPress: _isEditing
          ? () {
              HapticFeedback.heavyImpact();
              _deleteSharingType(sharing);
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: isAlternate ? const Color(0xFFF8FAFC) : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$sharing Sharing',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (_isEditing)
              GestureDetector(
                onTap: () => _deleteSharingType(sharing),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 32.w,
                  height: 40.h,
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: const Color(0xFFEF4444),
                    size: 20.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _deleteSharingType(int sharing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Delete Sharing Option',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFEF4444),
          ),
        ),
        content: Text(
          'Are you sure you want to delete the pricing for $sharing Sharing?',
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _activeSharingTypes.remove(sharing);
                for (final type in ['AC', 'NON_AC']) {
                  _controllers[type]?[sharing]?.forEach((field, controller) {
                    controller.clear();
                  });
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticAddRowCell() {
    return InkWell(
      onTap: _showAddSharingDialog,
      child: Container(
        height: 48.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        padding: EdgeInsets.only(left: 12.w),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: const Color(0xFF2B5797),
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              'Add',
              style: TextStyle(
                color: const Color(0xFF2B5797),
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightScrollablePanel() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: 400.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScrollableHeader(),
            ..._activeSharingTypes.map(
              (sharing) => _buildScrollableRow(sharing),
            ),
            if (_isEditing) _buildScrollableAddRowPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableHeader() {
    return Container(
      height: 44.h,
      color: const Color(0xFFEFF6FF),
      child: Row(
        children: [
          _buildHeaderCell('Monthly Rent', 100.w),
          _buildHeaderCell('Deposit', 100.w),
          _buildHeaderCell('Maintenance', 100.w),
          _buildHeaderCell('Daily Rent', 100.w),
        ],
      ),
    );
  }

  Widget _buildScrollableRow(int sharing) {
    final isAlternate = sharing % 2 == 0;
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: isAlternate ? const Color(0xFFF8FAFC) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          _buildTableCellField(sharing, 'rent'),
          _buildTableCellField(sharing, 'deposit'),
          _buildTableCellField(sharing, 'maintenance'),
          _buildTableCellField(sharing, 'daily'),
        ],
      ),
    );
  }

  Widget _buildScrollableAddRowPlaceholder() {
    return InkWell(
      onTap: _showAddSharingDialog,
      child: Container(
        height: 48.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        padding: EdgeInsets.only(left: 12.w),
        alignment: Alignment.centerLeft,
        child: Text(
          'Add Custom Sharing Option...',
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF2B5797),
            fontWeight: FontWeight.w900,
            fontSize: 11.sp,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCellField(int sharing, String field) {
    final controller = _controllers[_selectedType]![sharing]![field]!;
    final focusNode = _focusNodes[_selectedType]![sharing]![field]!;

    if (!_isEditing) {
      final val = controller.text.trim();
      return Container(
        width: 100.w,
        height: 52.h,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9)),
            right: BorderSide(color: Color(0xFFF1F5F9)),
          ),
        ),
        child: Text(
          val.isNotEmpty ? '₹ $val' : '-',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: val.isNotEmpty
                ? const Color(0xFF0F172A)
                : const Color(0xFF94A3B8),
          ),
        ),
      );
    }

    return Container(
      width: 100.w,
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textInputAction:
            (field == 'daily' && sharing == _activeSharingTypes.last)
            ? TextInputAction.done
            : TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          MaxValueTextInputFormatter(50000),
        ],
        onSubmitted: (_) {
          if (field == 'rent') {
            _focusNodes[_selectedType]![sharing]!['deposit']!.requestFocus();
          } else if (field == 'deposit') {
            _focusNodes[_selectedType]![sharing]!['maintenance']!
                .requestFocus();
          } else if (field == 'maintenance') {
            _focusNodes[_selectedType]![sharing]!['daily']!.requestFocus();
          } else if (field == 'daily') {
            final currentIndex = _activeSharingTypes.indexOf(sharing);
            if (currentIndex != -1 &&
                currentIndex < _activeSharingTypes.length - 1) {
              final nextSharing = _activeSharingTypes[currentIndex + 1];
              _focusNodes[_selectedType]![nextSharing]!['rent']!.requestFocus();
            }
          }
        },
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          prefixText: '₹ ',
          prefixStyle: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFF2B5797), width: 1.5),
          ),
        ),
      ),
    );
  }

  void _showAddSharingDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Add Custom Sharing Option',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter sharing capacity (e.g. 5 for 5 Sharing)',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Capacity (1 - 30)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final capacity = int.tryParse(controller.text);
                if (capacity != null && capacity >= 1 && capacity <= 30) {
                  _addNewSharingType(capacity);
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid capacity between 1 and 30',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B5797),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(List<RoomDetail> currentLoadedRooms) {
    if (!_isEditing) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFE2E8F0), width: 1.h),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            icon: Icon(Icons.edit_rounded, color: Colors.white, size: 18.sp),
            label: Text(
              'Edit Standard Pricing',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B5797),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0), width: 1.h),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: OutlinedButton(
                onPressed: () => _cancelEditing(currentLoadedRooms),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed: () => _savePricing(currentLoadedRooms),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B5797),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MaxValueTextInputFormatter extends TextInputFormatter {
  final int maxValue;

  MaxValueTextInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final value = int.tryParse(newValue.text);
    if (value == null) {
      return oldValue;
    }

    if (value > maxValue) {
      final cappedText = maxValue.toString();
      return TextEditingValue(
        text: cappedText,
        selection: TextSelection.collapsed(offset: cappedText.length),
      );
    }

    return newValue;
  }
}
