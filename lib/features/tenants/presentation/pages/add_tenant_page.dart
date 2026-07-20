import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_state.dart';
import 'package:stayindia_owner/injection_container.dart' as di;
import 'package:stayindia_owner/features/profile/domain/usecases/room_usecases.dart';


enum StayType {
  MONTHLY,
  CUSTOM,
}

class AddTenantPage extends StatefulWidget {
  const AddTenantPage({super.key});

  @override
  State<AddTenantPage> createState() => _AddTenantPageState();
}

class _AddTenantPageState extends State<AddTenantPage> {



  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _customDepositController = TextEditingController();

  final _maintenanceController = TextEditingController();
  final _dayRentController = TextEditingController();

  DateTime? _checkOutDate;
  StayType _stayType = StayType.MONTHLY;

  DateTime? _checkInDate;
  late AddTenantCubit _addTenantCubit;
  bool _isAC = true;

  File? _userPhoto;
  File? _aadharPhoto;
  bool _isDetectingFace = false;

  Hostel? _selectedHostel;
  bool _isLoadingRooms = false;
  List<RoomDetail> _allRooms = [];
  List<String> _availableSharings = [];
  String? _selectedSharing;

  List<int> _floors = [];
  int? _selectedFloor;
  List<RoomDetail> _rooms = [];
  RoomDetail? _selectedRoom;
  List<String> _beds = [];
  String? _selectedBed;


  @override
  void initState() {
    super.initState();
    _addTenantCubit = di.sl<AddTenantCubit>();
    final hostelCubit = context.read<HostelCubit>();
    if (hostelCubit.state is HostelLoaded) {
      final state = hostelCubit.state as HostelLoaded;
      final hostels = state.hostels;
      if (hostels.isNotEmpty) {
        final index = state.selectedHostelIndex;
        final defaultHostel = hostels[index < hostels.length ? index : 0];
        _selectedHostel = defaultHostel;
        _loadHostelRooms(defaultHostel);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _addTenantCubit.close();
    _dayRentController.dispose();
    _maintenanceController.dispose();
    _customDepositController.dispose();
    super.dispose();
  }

  Future<void> _loadHostelRooms(Hostel hostel) async {
    setState(() {
      _isLoadingRooms = true;
      _selectedHostel = hostel;
      _selectedSharing = null;
      _selectedFloor = null;
      _selectedRoom = null;
      _selectedBed = null;
      _floors = [];
      _rooms = [];
      _beds = [];
      _allRooms = [];
      _availableSharings = [];
    });

    try {
      final getRooms = di.sl<GetRoomsUseCase>();
      final rooms = await getRooms(hostelId: hostel.id, isMaster: false);

      final sharings = rooms
          .where(
            (r) => r.isActive == true && r.beds.any((b) => b.status == 'FREE'),
          )
          .map((r) {
            if (r.sharingType.toUpperCase() == 'DORMITORY') {
              return 'DORMITORY_${r.capacity}';
            }
            return r.sharingType.toUpperCase();
          })
          .toSet()
          .toList();

      setState(() {
        _allRooms = rooms;
        _availableSharings = sharings;
        _isLoadingRooms = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRooms = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load hostel details: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _onSharingSelected(String? sharing) {
    if (sharing == null) return;

    final floors =
        _allRooms
            .where(
              (r) =>
                  r.isActive == true &&
                  (r.sharingType.toUpperCase() == 'DORMITORY'
                      ? 'DORMITORY_${r.capacity}' == sharing
                      : r.sharingType.toUpperCase() == sharing) &&
                  r.beds.any((b) => b.status == 'FREE'),
            )
            .map((r) => r.floor)
            .toSet()
            .toList()
          ..sort();

    setState(() {
      _selectedSharing = sharing;
      _selectedFloor = null;
      _selectedRoom = null;
      _selectedBed = null;
      _floors = floors;
      _rooms = [];
      _beds = [];
    });
  }

  void _onFloorSelected(int? floor) {
    if (floor == null) return;

    final rooms = _allRooms
        .where(
          (r) =>
              r.isActive == true &&
              (r.sharingType.toUpperCase() == 'DORMITORY'
                  ? 'DORMITORY_${r.capacity}' == _selectedSharing
                  : r.sharingType.toUpperCase() == _selectedSharing) &&
              r.floor == floor &&
              r.beds.any((b) => b.status == 'FREE'),
        )
        .toList();

    setState(() {
      _selectedFloor = floor;
      _selectedRoom = null;
      _selectedBed = null;
      _rooms = rooms;
      _beds = [];
    });
  }

  void _onRoomSelected(RoomDetail? room) {
    if (room == null) return;

    final beds = room.beds
        .where((b) => b.status == 'FREE')
        .map((b) => b.bedNumber)
        .toList();

    setState(() {
      _selectedRoom = room;
      _selectedBed = null;
      _beds = beds;
      _rentController.text = room.rent.toString();
      _depositController.text = room.deposit.toString();
      _dayRentController.text = room.dailyRent.toString();
      _maintenanceController.text = room.maintenance.toString();
      _customDepositController.text = room.deposit.toString();
    });
  }

  void _onBedSelected(String? bed) {
    setState(() {
      _selectedBed = bed;
    });
  }

  String formatSharingType(String type) {
    if (type.startsWith('DORMITORY_')) {
      final parts = type.split('_');
      final cap = parts.length > 1 ? parts[1] : '';
      return '$cap Sharing Dormitory';
    }
    switch (type.toUpperCase()) {
      case 'SINGLE':
        return 'Single Sharing';
      case 'DOUBLE':
        return '2 Sharing';
      case 'TRIPLE':
        return '3 Sharing';
      case 'QUADRUPLE':
        return '4 Sharing';
      case 'QUINTUPLE':
        return '5 Sharing';
      case 'DORMITORY':
        return 'Dormitory';
      default:
        return type.isNotEmpty
            ? '${type[0].toUpperCase()}${type.substring(1).toLowerCase()} Sharing'
            : 'Unknown';
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final rentText = _rentController.text.trim();
    final depositText = _depositController.text.trim();
    final dayRentText = _dayRentController.text.trim();
    final maintainanceText = _maintenanceController.text.trim();
    final customDepositeText = _customDepositController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_enter_full_name'.tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('enter_valid_phone'.tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_emailController.text.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_emailController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('enter_valid_email'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    if (_selectedHostel == null ||
        _selectedSharing == null ||
        _selectedFloor == null ||
        _selectedRoom == null ||
        _selectedBed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all room allocation details'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (rentText.isEmpty || (double.tryParse(rentText) ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('enter_valid_rent'.tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('select_check_in_date'.tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('select_check_out_date'.tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_userPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take a user photo (Face validation required)'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_aadharPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload Aadhar Card'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final nameParts = name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : name;
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '.';

    _addTenantCubit.submit(
      hostel: _selectedHostel!,
      room: _selectedRoom!,
      bed: _selectedBed!,
      phone: phone,
      rent: double.tryParse(rentText) ?? 0,
      firstName: firstName,
      lastName: lastName,
      sharingType: _selectedRoom!.sharingType,
      deposit: depositText.isNotEmpty ? double.tryParse(depositText) : null,
      startDate: _checkInDate!,
      userPhotoPath: _userPhoto?.path,
      aadharPhotoPath: _aadharPhoto?.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _addTenantCubit,
      child: BlocListener<AddTenantCubit, AddTenantState>(
        listener: (context, state) {
          if (state is AddTenantSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('tenant_added_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is AddTenantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.darkText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'add_new_tenant'.tr(),
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<HostelCubit, HostelState>(
              builder: (context, hostelState) {
                List<Hostel> hostels = [];
                if (hostelState is HostelLoaded) {
                  hostels = hostelState.hostels;
                  if (_selectedHostel == null && hostels.isNotEmpty) {
                    final index = hostelState.selectedHostelIndex;
                    final defaultHostel =
                        hostels[index < hostels.length ? index : 0];
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _selectedHostel == null) {
                        setState(() {
                          _selectedHostel = defaultHostel;
                        });
                        _loadHostelRooms(defaultHostel);
                      }
                    });
                  }
                }

                return BlocBuilder<AddTenantCubit, AddTenantState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('property_selection'.tr()),
                          SizedBox(height: 16.h),
                          _buildDropdown<Hostel>(
                            'select_hostel'.tr(),
                            hostels,
                            _selectedHostel,
                            (h) => _loadHostelRooms(h!),
                            itemLabel: (h) => h.name,
                          ),

                          SizedBox(height: 32.h),
                          _buildSectionTitle('tenant_details'.tr()),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            'full_name'.tr(),
                            Icons.person_outline,
                            _nameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]'),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            'phone_number_req'.tr(),
                            Icons.phone_outlined,
                            _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            'email_optional'.tr(),
                            Icons.email_outlined,
                            _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          SizedBox(height: 32.h),
                          _buildSectionTitle('room_allocation'.tr()),
                          SizedBox(height: 16.h),
                          _buildDropdown<String>(
                            'room_sharing_req'.tr() == 'room_sharing_req'
                                ? 'Room Sharing *'
                                : 'room_sharing_req'.tr(),
                            _availableSharings,
                            _selectedSharing,
                            _onSharingSelected,
                            isLoading: _isLoadingRooms,
                            itemLabel: (s) => formatSharingType(s),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown<int>(
                                  'floor_req'.tr(),
                                  _floors,
                                  _selectedFloor,
                                  _onFloorSelected,
                                  isLoading: _isLoadingRooms,
                                  itemLabel: (f) => f == 0
                                      ? 'ground'.tr()
                                      : '$f ${'floor_suffix'.tr()}',
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildDropdown<RoomDetail>(
                                  'room_req'.tr(),
                                  _rooms,
                                  _selectedRoom,
                                  _onRoomSelected,
                                  isLoading: _isLoadingRooms,
                                  itemLabel: (r) => r.roomTypename,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _buildAcToggle(),
                          SizedBox(height: 16.h),
                          _buildDropdown<String>(
                            'bed_req'.tr(),
                            _beds,
                            _selectedBed,
                            _onBedSelected,
                            isLoading: _isLoadingRooms,
                            itemLabel: (b) {
                              final num = int.tryParse(b);
                              if (num != null && num > 0 && num <= 26) {
                                return 'bed_label'.tr(
                                  namedArgs: {
                                    'label': String.fromCharCode(64 + num),
                                  },
                                );
                              }
                              return 'bed_label'.tr(namedArgs: {'label': b});
                            },
                          ),

                          SizedBox(height: 32.h),
                          _buildSectionTitle('stay_details'.tr()),
                          SizedBox(height: 16.h),

                          _buildStayCustomToggle(),

                          SizedBox(height: 20.h),

                          if (_stayType == StayType.MONTHLY) ...[
                            _buildTextField(
                              'monthly_rent_req'.tr(),
                              Icons.currency_rupee,
                              _rentController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: 16.h),

                            _buildTextField(
                              'security_deposit_req'.tr(),
                              Icons.account_balance_wallet_outlined,
                              _depositController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildTextField(
                              'maintainance_req'.tr(),
                              Icons.account_balance_wallet_outlined,
                              _maintenanceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildDatePicker(context, 'check_in_date_req'.tr()),

                          ],

                          if (_stayType == StayType.CUSTOM) ...[

                            _buildTextField(
                              'day_rent'.tr(),
                              Icons.currency_rupee,
                              _dayRentController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildTextField(
                              'security_deposit'.tr(),
                              Icons.account_balance_wallet_outlined,
                              _customDepositController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: _buildDatePicker(context, 'check_in_date_req'.tr())),
                                SizedBox(width: 16.w),
                                Expanded(child: _buildDatePickerCheckout(context, 'check_out_date_req'.tr())),
                              ],
                            ),
                          ],

                          SizedBox(height: 32.h),
                          _buildVerificationSection(context),

                          SizedBox(height: 40.h),
                          _buildSubmitButton(state),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AddTenantState state) {
    bool isSubmitting = state is AddTenantSubmitting;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: isSubmitting
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'add_new_tenant'.tr(),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 15.sp, color: AppColors.darkText),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.greyText),
            hintText: 'enter_hint'.tr(
              namedArgs: {'field': label.replaceAll(' *', '')},
            ),
            hintStyle: TextStyle(
              color: AppColors.greyText.withValues(alpha: 0.5),
              fontSize: 15.sp,
            ),
            filled: true,
            fillColor: const Color(0xFFF2F4F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    String label,
    List<T> items,
    T? value,
    ValueChanged<T?> onChanged, {
    bool isLoading = false,
    String Function(T)? itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              hint: isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'select_hint'.tr(
                        namedArgs: {'field': label.replaceAll(' *', '')},
                      ),
                      style: TextStyle(
                        color: AppColors.greyText.withValues(alpha: 0.5),
                        fontSize: 15.sp,
                      ),
                    ),
              items: items
                  .map(
                    (T item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        itemLabel != null ? itemLabel(item) : item.toString(),
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _checkInDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _checkInDate = picked);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.greyText),
                SizedBox(width: 12.w),
                Text(
                  _checkInDate == null
                      ? 'select_date'.tr()
                      : '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}',
                  style: TextStyle(
                    color: _checkInDate == null
                        ? AppColors.greyText.withValues(alpha: 0.5)
                        : AppColors.darkText,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerCheckout(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _checkOutDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _checkOutDate = picked);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.greyText),
                SizedBox(width: 12.w),
                Text(
                  _checkOutDate == null
                      ? 'select_date'.tr()
                      : '${_checkOutDate!.day}/${_checkOutDate!.month}/${_checkOutDate!.year}',
                  style: TextStyle(
                    color: _checkOutDate == null
                        ? AppColors.greyText.withValues(alpha: 0.5)
                        : AppColors.darkText,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcToggle() {
    return Container(
      height: 48.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isAC) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isAC = true;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _isAC ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: _isAC
                      ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.ac_unit_rounded,
                        size: 16.sp,
                        color: _isAC
                            ? const Color(0xFF16539B)
                            : const Color(0xFF64748B),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'AC',
                        style: TextStyle(
                          color: _isAC
                              ? const Color(0xFF16539B)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w900,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isAC) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isAC = false;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !_isAC ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: !_isAC
                      ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thermostat_rounded,
                        size: 16.sp,
                        color: !_isAC
                            ? const Color(0xFF16539B)
                            : const Color(0xFF64748B),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Non-AC',
                        style: TextStyle(
                          color: !_isAC
                              ? const Color(0xFF16539B)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w900,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStayCustomToggle() {
    return Container(
      height: 48.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_stayType != StayType.MONTHLY) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _stayType = StayType.MONTHLY;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _stayType == StayType.MONTHLY
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: _stayType == StayType.MONTHLY
                      ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      color: _stayType == StayType.MONTHLY
                          ? const Color(0xFF16539B)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_stayType != StayType.CUSTOM) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _stayType = StayType.CUSTOM;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _stayType == StayType.CUSTOM
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: _stayType == StayType.CUSTOM
                      ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Custom',
                    style: TextStyle(
                      color: _stayType == StayType.CUSTOM
                          ? const Color(0xFF16539B)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickUserPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isDetectingFace = true;
      });

      final inputImage = InputImage.fromFilePath(image.path);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      final List<Face> faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      setState(() {
        _isDetectingFace = false;
      });

      if (faces.isNotEmpty) {
        setState(() {
          _userPhoto = File(image.path);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Face successfully detected and verified!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 28.sp,
                  ),
                  SizedBox(width: 10.w),
                  const Text(
                    'No Face Detected',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text(
                'Google ML Kit could not detect a valid human face in the photo. Please take a clear picture of the tenant\'s face with good lighting.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isDetectingFace = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Face detection error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickAadharPhoto() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Colors.white,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                child: Row(
                  children: [
                    Text(
                      'Upload Aadhar Card',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.blue[700],
                  ),
                ),
                title: const Text(
                  'Take Photo (Camera)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _aadharPhoto = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: Colors.green[700],
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _aadharPhoto = File(image.path);
                    });
                  }
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerificationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'verification_documents'.tr() == 'verification_documents'
              ? 'Verification Documents'
              : 'verification_documents'.tr(),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _isDetectingFace ? null : _pickUserPhoto,
                child: Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _userPhoto != null
                          ? Colors.green.withValues(alpha: 0.5)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_userPhoto != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.file(
                            _userPhoto!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(16.r),
                              ),
                            ),
                            child: const Text(
                              'Tap to retake',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isDetectingFace) ...[
                              const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2C599D),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Detecting face...',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ] else ...[
                              Icon(
                                Icons.face_retouching_natural_rounded,
                                color: const Color(0xFF2C599D),
                                size: 32.sp,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'User Photo *',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Face Scan (Camera)',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),

            Expanded(
              child: GestureDetector(
                onTap: _pickAadharPhoto,
                child: Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _aadharPhoto != null
                          ? Colors.green.withValues(alpha: 0.5)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_aadharPhoto != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.file(
                            _aadharPhoto!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(16.r),
                              ),
                            ),
                            child: const Text(
                              'Tap to retake',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.badge_rounded,
                              color: const Color(0xFFF98125),
                              size: 32.sp,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Aadhar Card *',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Camera or Gallery',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
