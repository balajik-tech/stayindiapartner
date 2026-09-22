import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_cubit.dart';
import 'package:stayindia_owner/features/property_setup/presentation/cubit/property_setup_state.dart';

class RoomPricing {
  final int sharing;
  final String type;
  final String monthlyRent;
  final String securityDeposit;
  final String maintenance;
  final String dailyRent;

  RoomPricing({
    required this.sharing,
    required this.type,
    this.monthlyRent = '',
    this.securityDeposit = '',
    this.maintenance = '',
    this.dailyRent = '',
  });
}

class RoomCategoryScreen extends StatefulWidget {
  const RoomCategoryScreen({super.key});

  @override
  State<RoomCategoryScreen> createState() => _RoomCategoryScreenState();
}

class _RoomCategoryScreenState extends State<RoomCategoryScreen> {
  String _selectedType = 'NON_AC';
  late List<int> _activeSharingTypes;

  late Map<String, Map<int, Map<String, TextEditingController>>> _controllers;
  late Map<String, Map<int, Map<String, FocusNode>>> _focusNodes;

  final Map<String, Set<int>> _customizedDeposits = {'AC': {}, 'NON_AC': {}};
  final Map<String, Set<int>> _customizedMaintenances = {
    'AC': {},
    'NON_AC': {},
  };

  final Map<String, Set<int>> _customizedDailies = {'AC': {}, 'NON_AC': {}};

  bool _isPropagating = false;
  bool _isUpdatingFromState = false;

  void _propagateValue(
    String type,
    int sourceSharing,
    String field,
    String value,
  ) {
    if (_isPropagating) return;
    _isPropagating = true;

    try {
      final Set<int> customizedSet;
      if (field == 'deposit') {
        customizedSet = _customizedDeposits[type]!;
      } else if (field == 'maintenance') {
        customizedSet = _customizedMaintenances[type]!;
      } else {
        customizedSet = _customizedDailies[type]!;
      }

      for (int s = 1; s <= 10; s++) {
        if (s == sourceSharing) continue;
        if (!customizedSet.contains(s)) {
          _controllers[type]![s]![field]!.text = value;
        }
      }
    } finally {
      _isPropagating = false;
    }
    _silentSyncToCubit();
  }

  @override
  void initState() {
    super.initState();

    final Set<int> initialSharingTypes = {1, 2, 3, 4};

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
      }
    }

    String cleanZero(String val) {
      final trimmed = val.trim();
      if (trimmed == '0' || trimmed == '0.0' || trimmed == '0.00') {
        return '';
      }
      return trimmed;
    }

    final currentCategories = context
        .read<PropertySetupCubit>()
        .state
        .roomCategories;
    for (final cat in currentCategories) {
      final int sharing = cat['sharingType'] ?? 2;
      if (sharing >= 1 && sharing <= 10) {
        final bool isAC = cat['isAC'] == true;
        final String typeKey = isAC ? 'AC' : 'NON_AC';

        final rent = cleanZero(cat['monthlyRent']?.toString() ?? '');
        final deposit = cleanZero(cat['securityDeposit']?.toString() ?? '');
        final maint = cleanZero(cat['maintenance']?.toString() ?? '');
        final daily = cleanZero(cat['dailyRent']?.toString() ?? '');
        _controllers[typeKey]![sharing]!['rent']!.text = rent;
        _controllers[typeKey]![sharing]!['deposit']!.text = deposit;
        _controllers[typeKey]![sharing]!['maintenance']!.text = maint;
        _controllers[typeKey]![sharing]!['daily']!.text = daily;

        if (deposit.isNotEmpty) {
          _customizedDeposits[typeKey]!.add(sharing);
        }
        if (maint.isNotEmpty) {
          _customizedMaintenances[typeKey]!.add(sharing);
        }
        initialSharingTypes.add(sharing);
      }
    }

    _activeSharingTypes = initialSharingTypes.toList()..sort();

    for (final type in ['AC', 'NON_AC']) {
      for (int s = 1; s <= 10; s++) {
        final rentCtrl = _controllers[type]![s]!['rent']!;
        final depositCtrl = _controllers[type]![s]!['deposit']!;
        final maintCtrl = _controllers[type]![s]!['maintenance']!;
        final dailyCtrl = _controllers[type]![s]!['daily']!;

        final depositFocus = _focusNodes[type]![s]!['deposit']!;
        final maintFocus = _focusNodes[type]![s]!['maintenance']!;
        final dailyFocus = _focusNodes[type]![s]!['daily']!;

        depositCtrl.addListener(() {
          if (depositFocus.hasFocus) {
            final val = depositCtrl.text.trim();
            if (s == 1) {
              _propagateValue(type, 1, 'deposit', val);
            } else {
              _customizedDeposits[type]!.add(s);
            }
          }
        });

        maintCtrl.addListener(() {
          if (maintFocus.hasFocus) {
            final val = maintCtrl.text.trim();
            if (s == 1) {
              _propagateValue(type, 1, 'maintenance', val);
            } else {
              _customizedMaintenances[type]!.add(s);
            }
          }
        });

        dailyCtrl.addListener(() {
          if (dailyFocus.hasFocus) {
            final val = dailyCtrl.text.trim();
            if (s == 1) {
              _propagateValue(type, 1, 'daily', val);
            } else {
              _customizedDailies[type]!.add(s);
            }
          }
        });

        rentCtrl.addListener(_silentSyncToCubit);
        depositCtrl.addListener(_silentSyncToCubit);
        maintCtrl.addListener(_silentSyncToCubit);
        dailyCtrl.addListener(_silentSyncToCubit);
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((type, sharingMap) {
      sharingMap.forEach((sharing, fieldMap) {
        fieldMap.forEach((field, controller) {
          controller.dispose();
        });
      });
    });

    _focusNodes.forEach((type, sharingMap) {
      sharingMap.forEach((sharing, fieldMap) {
        fieldMap.forEach((field, node) {
          node.dispose();
        });
      });
    });

    super.dispose();
  }

  void _silentSyncToCubit() {
    if (_isPropagating || _isUpdatingFromState) return;
    final List<Map<String, dynamic>> categoriesToSave = [];
    _controllers.forEach((typeKey, sharingMap) {
      final bool isAC = typeKey == 'AC';
      sharingMap.forEach((sharing, fieldMap) {
        if (!_activeSharingTypes.contains(sharing)) return;
        final rent = fieldMap['rent']!.text.trim();
        final deposit = fieldMap['deposit']!.text.trim();
        final maint = fieldMap['maintenance']!.text.trim();
        final daily = fieldMap['daily']!.text.trim();

        if (rent.isNotEmpty) {
          categoriesToSave.add({
            'id': 'cat_${typeKey}_$sharing',
            'sharingType': sharing,
            'isAC': isAC,
            'roomSize': '',
            'roomCount': 0,
            'monthlyRent': rent,
            'dailyRent': daily,
            'securityDeposit': deposit.isNotEmpty ? deposit : '0',
            'maintenance': maint.isNotEmpty ? maint : '0',
            'securityDepositCustomized': true,
            'maintenanceCustomized': true,
            'dailyRentThresholdDays': '5',
          });
        }
      });
    });

    context.read<PropertySetupCubit>().setRoomCategories(categoriesToSave);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertySetupCubit, PropertySetupState>(
      listenWhen: (previous, current) =>
          previous.roomCategories != current.roomCategories,
      listener: (context, state) {
        if (mounted) {
          setState(() {
            _isUpdatingFromState = true;
          });
        } else {
          _isUpdatingFromState = true;
        }

        try {
          String cleanZero(String val) {
            final trimmed = val.trim();
            if (trimmed == '0' || trimmed == '0.0' || trimmed == '0.00') {
              return '';
            }
            return trimmed;
          }

          for (final cat in state.roomCategories) {
            final int sharing = cat['sharingType'] ?? 2;
            if (sharing >= 1 && sharing <= 10) {
              final bool isAC = cat['isAC'] == true;
              final String typeKey = isAC ? 'AC' : 'NON_AC';

              final rentCtrl = _controllers[typeKey]![sharing]!['rent']!;
              final depositCtrl = _controllers[typeKey]![sharing]!['deposit']!;
              final maintCtrl = _controllers[typeKey]![sharing]!['maintenance']!;
              final dailyCtrl = _controllers[typeKey]![sharing]!['daily']!;

              final rentFocus = _focusNodes[typeKey]![sharing]!['rent']!;
              final depositFocus = _focusNodes[typeKey]![sharing]!['deposit']!;
              final maintFocus = _focusNodes[typeKey]![sharing]!['maintenance']!;
              final dailyFocus = _focusNodes[typeKey]![sharing]!['daily']!;

              final rent = cleanZero(cat['monthlyRent']?.toString() ?? '');
              final deposit = cleanZero(cat['securityDeposit']?.toString() ?? '');
              final maint = cleanZero(cat['maintenance']?.toString() ?? '');
              final daily = cleanZero(cat['dailyRent']?.toString() ?? '');

              if (!rentFocus.hasFocus && rentCtrl.text != rent) {
                rentCtrl.text = rent;
              }
              if (!depositFocus.hasFocus && depositCtrl.text != deposit) {
                depositCtrl.text = deposit;
              }
              if (!maintFocus.hasFocus && maintCtrl.text != maint) {
                maintCtrl.text = maint;
              }
              if (!dailyFocus.hasFocus && dailyCtrl.text != daily) {
                dailyCtrl.text = daily;
              }
            }
          }
        } finally {
          if (mounted) {
            setState(() {
              _isUpdatingFromState = false;
            });
          } else {
            _isUpdatingFromState = false;
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildHeaderSection(),
            SizedBox(height: 8.h),
            _buildToggleRow(),
            SizedBox(height: 12.h),
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
            SizedBox(height: 8.h),
          ],
        ),
      ),
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
            'Room Master',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF16539B),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Configure AC and Non-AC standard pricing matrix',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
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
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,

              // NON_AC = Left, AC = Right
              alignment: isAC
                  ? Alignment.centerRight
                  : Alignment.centerLeft,

              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  margin: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16539B),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF16539B).withValues(
                          alpha: 0.3,
                        ),
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
                // LEFT - NON-AC
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
                          color: !isAC
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),

                // RIGHT - AC
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
                          color: isAC
                              ? Colors.white
                              : const Color(0xFF64748B),
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
      width: 125.w,
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
          _buildStaticAddRowCell(),
        ],
      ),
    );
  }

  Widget _buildStaticHeaderCell() {
    return Container(
      height: 44.h,
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: Text(
        'Sharing',
        style: TextStyle(
          color: const Color(0xFF475569),
          fontWeight: FontWeight.w800,
          fontSize: 12.sp,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStaticRowCell(int sharing) {
    final isAlternate = sharing % 2 == 0;
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _deleteSharingType(sharing);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: isAlternate ? const Color(0xFFF8FAFC) : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$sharing Sharing',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _deleteSharingType(sharing),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 28.w,
                height: 40.h,
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: const Color(0xFFEF4444),
                  size: 18.sp,
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
              _silentSyncToCubit();
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
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: const Color(0xFF16539B),
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              'Add',
              style: TextStyle(
                color: const Color(0xFF16539B),
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
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
        width: 440.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScrollableHeader(),
            ..._activeSharingTypes.map(
              (sharing) => _buildScrollableRow(sharing),
            ),
            _buildScrollableAddRowPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableHeader() {
    return Container(
      height: 44.h,
      color: const Color(0xFFF1F5F9),
      child: Row(
        children: [
          _buildHeaderCell('Monthly Rent', 110.w),
          _buildHeaderCell('Deposit', 110.w),
          _buildHeaderCell('Maintenance', 110.w),
          _buildHeaderCell('Daily Rent', 110.w),
        ],
      ),
    );
  }

  Widget _buildScrollableRow(int sharing) {
    final isAlternate = sharing % 2 == 0;
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: isAlternate ? const Color(0xFFF8FAFC) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
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
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        padding: EdgeInsets.only(left: 12.w),
        alignment: Alignment.centerLeft,
        child: Text(
          'Add Custom Sharing Option...',
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 13.sp,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w800,
            fontSize: 11.sp,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCellField(int sharing, String field) {
    final controller = _controllers[_selectedType]![sharing]![field]!;
    final focusNode = _focusNodes[_selectedType]![sharing]![field]!;

    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final hasFocus = focusNode.hasFocus;
        return Container(
          width: 110.w,
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 7.h),
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
              color: const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              filled: true,
              fillColor: hasFocus ? Colors.white : const Color(0xFFF8FAFC),
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
                borderSide: const BorderSide(color: Color(0xFF16539B), width: 1.5),
              ),
            ),
          ),
        );
      },
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
            'Add Custom Sharing',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF16539B),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter sharing number (e.g. 5, 6, 7)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Sharing number',
                  hintStyle: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF16539B),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
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
                final text = controller.text.trim();
                if (text.isEmpty) return;
                final sharing = int.tryParse(text);
                if (sharing == null || sharing < 1 || sharing > 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a sharing number between 1 and 10',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                if (_activeSharingTypes.contains(sharing)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This sharing option already exists'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                setState(() {
                  _activeSharingTypes.add(sharing);
                  _activeSharingTypes.sort();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16539B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
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
