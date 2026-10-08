import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_state.dart';
import 'package:stayindia_owner/injection_container.dart' as di;
import 'package:stayindia_owner/features/profile/domain/usecases/room_usecases.dart';
import 'package:stayindia_owner/features/finance/presentation/cubit/payment_report_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final List<TextEditingController> _emergencyNameControllers = [];
  final List<TextEditingController> _emergencyMobileControllers = [];
  final List<String?> _emergencyNameErrors = [];
  final List<String?> _emergencyMobileErrors = [];
  final List<String> _allEmergencyRelations = [
    'Father',
    'Mother',
    'Guardian 1',
    'Guardian 2',
    'Guardian 3',
  ];
  final List<String> _emergencyRelations = [];

  List<String> get _availableRelations {
    return _allEmergencyRelations
        .where((r) => !_emergencyRelations.contains(r))
        .toList();
  }

  DateTime? _checkOutDate;
  StayType _stayType = StayType.MONTHLY;

  DateTime? _checkInDate;
  late AddTenantCubit _addTenantCubit;
  bool _isAC = false;
  bool _isNew = true;

  File? _userPhoto;
  File? _aadharPhoto;
  File? _aadharPhotoBack;
  File? _employeeIdProof;
  bool _isDetectingFace = false;
  bool _isExtractingText = false;

  final Map<String, String> _extractedAadharData = {
    'aadharNumber': '',
    'name': '',
    'dob': '',
    'gender': '',
    'address': '',
  };

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
    for (final controller in _emergencyNameControllers) {
      controller.dispose();
    }
    for (final controller in _emergencyMobileControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getRelationForIndex(int index) {
    if (index < _emergencyRelations.length) {
      return _emergencyRelations[index];
    }
    if (index == 0) return 'Father';
    if (index == 1) return 'Mother';
    return 'Guardian ${index - 1}';
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

  void _showCollectPaymentDialog({
    required BuildContext context,
    required String phone,
    required String firstName,
    required String lastName,
    required String sharingType,
    String? email,
    String? userPhotoPath,
    String? aadharPhotoPath,
    String? aadharCardbackPath,
    String? employeeIdProofPath,
    List<Map<String, String>>? guardianMobiles,
    required double securityDeposit,
    required double rent,
    required String checkInDate,
    required String checkOutDate,
    required double maintainance,
    required String roomType,
    required String aadhaarNumber,
    required String dob,
    required String gender,
    required String address,
    required double totalAmount
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<PaymentReportCubit>(),
          child: _CollectPaymentBottomSheet(
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            sharingType: sharingType,
            email: email,
            userPhotoPath: userPhotoPath,
            aadharPhotoPath: aadharPhotoPath,
            aadharCardbackPath: aadharCardbackPath,
            employeeIdProofPath: employeeIdProofPath,
            guardianMobiles: guardianMobiles,
            securityDeposit: securityDeposit,
            rent: rent,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            maintainance: maintainance,
            roomType: roomType,
            aadhaarNumber: aadhaarNumber,
            dob: dob,
            gender: gender,
            address: address,
            selectedHostel: _selectedHostel!,
            selectedRoom: _selectedRoom!,
            selectedBed: _selectedBed!,
            stayType: _stayType,
            addTenantCubit: _addTenantCubit,
            totalAmount:totalAmount
          ),
        );
      },
    );
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

  bool isValidAadhaar(String? aadhaar) {
    if (aadhaar == null || aadhaar.trim().isEmpty) {
      return false;
    }

    final number = aadhaar.replaceAll(RegExp(r'\D'), '');

    if (number.length != 12) {
      return false;
    }

    if (number.startsWith('0') || number.startsWith('1')) {
      return false;
    }

    return _isValidVerhoeff(number);
  }

  bool _isValidVerhoeff(String number) {
    const d = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
      [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
      [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
      [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
      [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
      [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
      [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
      [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
      [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
    ];

    const p = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
      [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
      [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
      [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
      [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
      [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
      [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
    ];

    int checksum = 0;

    final digits = number
        .split('')
        .map(int.parse)
        .toList()
        .reversed
        .toList();

    for (int i = 0; i < digits.length; i++) {
      checksum = d[checksum][p[i % 8][digits[i]]];
    }

    return checksum == 0;
  }

  void _submit(BuildContext context) {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final rentText = _rentController.text.trim();

    final aadharNumber = _extractedAadharData['aadharNumber']!;
    final extractedAadhaar = aadharNumber;

    final extractedAadhaarDOB = _extractedAadharData['dob'] ?? '';
    final extractedAadhaarGender = _extractedAadharData['gender'] ?? '';
    final extractedAadhaarAddress = _extractedAadharData['address'] ?? '';

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

    // Process Guardian Mobiles
    final List<Map<String, String>> guardianMobiles = [];
    bool hasGuardianError = false;

    for (int i = 0; i < _emergencyMobileControllers.length; i++) {
      final cName = _emergencyNameControllers[i].text.trim();
      final cPhone = _emergencyMobileControllers[i].text.trim();
      final cRelation = i < _emergencyRelations.length
          ? _emergencyRelations[i]
          : _getRelationForIndex(i);

      if (cPhone.isNotEmpty) {
        if (cPhone.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(cPhone)) {
          setState(() {
            _emergencyMobileErrors[i] = "Enter a valid 10-digit mobile number";
          });
          hasGuardianError = true;
        } else {
          guardianMobiles.add({
            'name': cName,
            'mobileNumber': cPhone,
            'relation': cRelation,
          });
        }
      }
    }

    if (hasGuardianError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number for guardian'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
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

    if (_stayType == StayType.CUSTOM) {
      if (_checkOutDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('select_check_out_date'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    // if (_userPhoto == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please take a user photo (Face validation required)'),
    //       backgroundColor: Colors.redAccent,
    //     ),
    //   );
    //   return;
    // }

    if (_aadharPhoto == null || _aadharPhotoBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both Front and Back of Aadhar Card'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (aadharNumber.isEmpty || aadharNumber.length != 12) {
      String found = aadharNumber;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              found.isEmpty
                  ? 'Could not detect Aadhaar number. Please ensure the clear and well-lit.'
                  : 'Extracted invalid Aadhaar number ($found). Please retake the photo.'
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (isValidAadhaar(extractedAadhaar)) {
      debugPrint('Valid Aadhaar format/checksum');
    } else {
      debugPrint('Invalid Aadhaar number');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Aadhaar number.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    debugPrint("Aaadhar Number ::: $extractedAadhaar");

    final authState = context.read<AuthCubit>().state;
    String? ownerPhone;
    if (authState is AuthAuthenticated) {
      ownerPhone = authState.owner.phone;
    }

    if (ownerPhone != null) {
      final cleanOwnerPhone = ownerPhone.replaceAll(RegExp(r'\D'), '');
      final last10Owner = cleanOwnerPhone.length >= 10
          ? cleanOwnerPhone.substring(cleanOwnerPhone.length - 10)
          : cleanOwnerPhone;

      if (phone == last10Owner) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Owner cannot be added as a tenant'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    final nameParts = name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : name;
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : '.';

    double? securityDeposit;
    double? rent;
    String checkInDate = "";
    String checkOutDate = "";
    double? maintainance = 0;
    // Calculate prorated rent
    double calculatedRent = rent ?? 0.0;
    double totalAmount = 0.0;

    if (_stayType == StayType.MONTHLY) {
      securityDeposit = double.tryParse(_depositController.text.trim());
      rent = double.tryParse(_rentController.text.trim());
      checkInDate = _checkInDate != null
          ? DateFormat('yyyy-MM-dd').format(_checkInDate!)
          : "";
      checkOutDate = _checkInDate != null
          ? DateFormat(
        'yyyy-MM-dd',
      ).format(
        DateTime(
          _checkInDate!.year,
          _checkInDate!.month + 1,
          0, // Last day of check-in month
        ),
      )
          : "";
      maintainance = double.tryParse(_maintenanceController.text.trim());
      if (_checkInDate != null && rent != null) {
        final DateTime monthEnd = DateTime(_checkInDate!.year, _checkInDate!.month + 1, 0);
        final int daysInMonth = monthEnd.day;
        final int occupiedDays = monthEnd.day - _checkInDate!.day + 1;

        calculatedRent = (rent / daysInMonth) * occupiedDays;
      }
      totalAmount = calculatedRent + securityDeposit! + maintainance!;
    } else if (_stayType == StayType.CUSTOM) {
      securityDeposit = double.tryParse(_customDepositController.text.trim());
      rent = double.tryParse(_dayRentController.text.trim());
      checkInDate = _checkInDate != null
          ? DateFormat('yyyy-MM-dd').format(_checkInDate!)
          : "";
      checkOutDate = _checkOutDate != null
          ? DateFormat('yyyy-MM-dd').format(_checkOutDate!)
          : "";
      maintainance = 0;
      totalAmount = calculatedRent + securityDeposit! + maintainance;
    }

    String? roomType = _isAC == true ? "AC" : "NON-AC";

    debugPrint("is NEW::::::::::$_isNew");

    if (_isNew) {
      _showCollectPaymentDialog(
        context: context,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        sharingType: _selectedRoom!.sharingType,
        email: _emailController.text.trim(),
        userPhotoPath: _userPhoto?.path,
        aadharPhotoPath: _aadharPhoto?.path,
        aadharCardbackPath: _aadharPhotoBack?.path,
        employeeIdProofPath: _employeeIdProof?.path,
        guardianMobiles: guardianMobiles,
        securityDeposit: securityDeposit ?? 0,
        rent: rent ?? 0,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        maintainance: maintainance ?? 0,
        roomType: roomType,
        aadhaarNumber: extractedAadhaar,
        dob: extractedAadhaarDOB,
        gender: extractedAadhaarGender.toLowerCase(),
        address: extractedAadhaarAddress,
        totalAmount: double.parse(
          double.tryParse(totalAmount as String)?.toStringAsFixed(2) ?? "0.00",
        ),
      );
      return;
    }

    _addTenantCubit.submit(
      hostel: _selectedHostel!,
      room: _selectedRoom!,
      bed: _selectedBed!,
      phone: phone,
      firstName: firstName,
      lastName: lastName,
      sharingType: _selectedRoom!.sharingType,
      email: _emailController.text.trim(),

      userPhotoPath: _userPhoto?.path,
      aadharPhotoPath: _aadharPhoto?.path,
      aadharCardbackPath: _aadharPhotoBack?.path,
      employeeIdProofPath: _employeeIdProof?.path,
      guardianMobiles: guardianMobiles,

      deposit: securityDeposit,
      rent: rent ?? 0,
      startDate: (checkInDate.isNotEmpty)
          ? DateTime.parse(checkInDate)
          : DateTime.now(),
      bookingType: _stayType.name.toString(),
      maintenance: maintainance.toString(),
      roomType: roomType,
      endDate: (checkOutDate.isNotEmpty)
          ? DateTime.parse(checkOutDate)
          : DateTime.now(),
      aadhaarNumber: extractedAadhaar,
      dob: extractedAadhaarDOB,
      gender: extractedAadhaarGender.toLowerCase(),
      address: extractedAadhaarAddress,
      totalAmount:totalAmount
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _addTenantCubit),
        BlocProvider(create: (context) => di.sl<PaymentReportCubit>()),
      ],
      child: BlocListener<AddTenantCubit, AddTenantState>(
        listener: (context, state) {
          if (state is AddTenantSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'tenant_added_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            if (!_isNew) {
              Navigator.pop(context, true);
            }
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
                          _buildTenantToggle(),
                          SizedBox(height: 32.h),
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
                          _buildEmergencyContactsSection(),

                          SizedBox(height: 32.h),
                          _buildSectionTitle('room_allocation'.tr()),
                          SizedBox(height: 16.h),
                          _buildAcToggle(),
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
                          _buildSubmitButton(context, state),
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

  Widget _buildEmergencyContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          "Parent / Guardian Details",
          subtitle: "Add up to 5 parent or guardian contacts",
        ),
        if (_emergencyRelations.isNotEmpty) SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _emergencyRelations.length,
          separatorBuilder: (context, index) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final currentRelation = _emergencyRelations[index];
            final cardAvailableRelations = [
              currentRelation,
              ..._availableRelations,
            ];

            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFD5DEE9), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7F2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.person_pin_rounded,
                              size: 16.sp,
                              color: const Color(0xFFF26B1A),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: currentRelation,
                              icon: Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: const Color(0xFFF26B1A),
                                  size: 18.sp,
                                ),
                              ),
                              isDense: true,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                              items: cardAvailableRelations.map((rel) {
                                return DropdownMenuItem<String>(
                                  value: rel,
                                  child: Text(
                                    rel,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newRel) {
                                if (newRel != null && newRel != currentRelation) {
                                  setState(() {
                                    _emergencyRelations[index] = newRel;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _emergencyRelations.removeAt(index);
                            _emergencyNameControllers[index].dispose();
                            _emergencyNameControllers.removeAt(index);
                            _emergencyMobileControllers[index].dispose();
                            _emergencyMobileControllers.removeAt(index);
                            _emergencyNameErrors.removeAt(index);
                            _emergencyMobileErrors.removeAt(index);
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildField(
                    label: "$currentRelation Name",
                    controller: _emergencyNameControllers[index],
                    icon: Icons.person_outline_rounded,
                    hintText: "Enter name",
                    showChevron: true,
                    iconBgColor: const Color(0xFFFFF7F2),
                    iconColor: const Color(0xFFF26B1A),
                    imagePath: '',
                    errorText: _emergencyNameErrors[index],
                    onChanged: (val) {
                      setState(() {
                        _emergencyNameErrors[index] = null;
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildField(
                    label: "$currentRelation Mobile Number",
                    controller: _emergencyMobileControllers[index],
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    hintText: "Enter 10-digit mobile number",
                    showChevron: true,
                    iconBgColor: const Color(0xFFFFF7F2),
                    iconColor: const Color(0xFFF26B1A),
                    imagePath: '',
                    errorText: _emergencyMobileErrors[index],
                    onChanged: (val) {
                      setState(() {
                        if (val.isNotEmpty &&
                            (val.length != 10 ||
                                !RegExp(r'^[6-9]\d{9}$').hasMatch(val))) {
                          _emergencyMobileErrors[index] =
                              "Enter a valid 10-digit mobile number";
                        } else {
                          _emergencyMobileErrors[index] = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        if (_availableRelations.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFD5DEE9)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: null,
                  hint: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: const Color(0xFF1E56A0),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _emergencyRelations.isEmpty
                            ? "Select Relation to Add"
                            : "Add Relation",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E56A0),
                        ),
                      ),
                    ],
                  ),
                  items: _availableRelations.map((relation) {
                    return DropdownMenuItem<String>(
                      value: relation,
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 18.sp,
                            color: const Color(0xFFF26B1A),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            relation,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedRelation) {
                    if (selectedRelation != null) {
                      setState(() {
                        _emergencyRelations.add(selectedRelation);
                        _emergencyNameControllers.add(TextEditingController());
                        _emergencyMobileControllers.add(TextEditingController());
                        _emergencyNameErrors.add(null);
                        _emergencyMobileErrors.add(null);
                      });
                    }
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    String hintText = '',
    bool showChevron = false,
    Color? iconBgColor,
    Color? iconColor,
    String? imagePath,
    String? errorText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 14.sp,
            ),
            prefixIcon: icon != null
                ? Container(
                    margin: EdgeInsets.all(8.w),
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: iconBgColor ?? const Color(0xFFFFF7F2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      icon,
                      size: 16.sp,
                      color: iconColor ?? const Color(0xFFF26B1A),
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFD5DEE9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent : const Color(0xFFD5DEE9),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent : AppColors.primaryBlue,
                width: 1.5,
              ),
            ),
            errorText: errorText,
            errorStyle: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, AddTenantState state) {
    bool isSubmitting = state is AddTenantSubmitting;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : () => _submit(context),
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

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
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
            final now = DateTime.now();

            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _isNew
                  ? DateTime(now.year, now.month, now.day)
                  : (_checkInDate ?? DateTime.now()),
              firstDate: _isNew
                  ? DateTime(now.year, now.month, now.day)
                  : DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (picked != null) {
              setState(() {
                _checkInDate = picked;
                _checkOutDate = null;
              });
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
              initialDate: _checkOutDate ??
                  (_checkInDate ?? DateTime.now()),
              firstDate: _checkInDate ?? DateTime.now(),
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

  Widget _buildTenantToggle() {
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
                if (!_isNew) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isNew = true;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _isNew ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: _isNew
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
                        Icons.fiber_new_rounded,
                        size: 16.sp,
                        color: _isNew
                            ? const Color(0xFF16539B)
                            : const Color(0xFF64748B),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'New'.tr(),
                        style: TextStyle(
                          color: _isNew
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
                if (_isNew) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isNew = false;
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !_isNew ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: !_isNew
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
                        Icons.home_work_rounded,
                        size: 16.sp,
                        color: !_isNew
                            ? const Color(0xFF16539B)
                            : const Color(0xFF64748B),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Existing'.tr(),
                        style: TextStyle(
                          color: !_isNew
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
    _pickDocumentPhoto(
      title: 'Upload Aadhar Card (Front)',
      onImagePicked: (file) async {
        File finalFile = file;
        try {
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: file.path,
            compressQuality: 85,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Aadhar Card (Front)',
                toolbarColor: AppColors.primaryBlue,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: 'Crop Aadhar Card (Front)',
              ),
            ],
          );
          if (croppedFile != null) {
            finalFile = File(croppedFile.path);
          }
        } catch (e) {
          debugPrint('Error cropping Aadhar Front: $e');
        }

        setState(() {
          _aadharPhoto = finalFile;
        });
        _extractAadharText(finalFile, isFront: true);
      },
    );
  }

  Future<void> _pickAadharPhotoBack() async {
    _pickDocumentPhoto(
      title: 'Upload Aadhar Card (Back)',
      onImagePicked: (file) async {
        File finalFile = file;
        try {
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: file.path,
            compressQuality: 85,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Aadhar Card (Back)',
                toolbarColor: AppColors.primaryBlue,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: 'Crop Aadhar Card (Back)',
              ),
            ],
          );
          if (croppedFile != null) {
            finalFile = File(croppedFile.path);
          }
        } catch (e) {
          debugPrint('Error cropping Aadhar Back: $e');
        }

        setState(() {
          _aadharPhotoBack = finalFile;
        });
      },
    );
  }

  Future<void> _pickEmployeeCardPhoto() async {
    _pickDocumentPhoto(
      title: 'Upload Employee Card',
      onImagePicked: (file) async {
        try {
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: file.path,
            compressQuality: 85,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Employee Card',
                toolbarColor: AppColors.primaryBlue,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: 'Crop Employee Card',
              ),
            ],
          );
          if (croppedFile != null) {
            setState(() {
              _employeeIdProof = File(croppedFile.path);
            });
          }
        } catch (e) {
          debugPrint('Error cropping employee card: $e');
          setState(() {
            _employeeIdProof = file;
          });
        }
      },
    );
  }

  Future<void> _extractAadharText(File imageFile, {required bool isFront}) async {
    setState(() {
      _isExtractingText = true;
    });

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String fullText = recognizedText.text;
      debugPrint('OCR Text: $fullText');
      
      String sanitizedText = fullText.replaceAll(RegExp(r'[oO]'), '0').replaceAll(RegExp(r'[iIlL|]'), '1');
      
      String extractedAadhar = '';
      
      final aadharRegex = RegExp(r'(\d{4}\s*\d{4}\s*\d{4})');
      final aadharMatch = aadharRegex.firstMatch(sanitizedText);
      
      if (aadharMatch != null) {
        extractedAadhar = aadharMatch.group(0)!.replaceAll(RegExp(r'\s+'), '');
      } else {
        String digitsOnly = sanitizedText.replaceAll(RegExp(r'\D'), '');
        final fallbackRegex = RegExp(r'\d{12}');
        final fallbackMatch = fallbackRegex.firstMatch(digitsOnly);
        if (fallbackMatch != null) {
          extractedAadhar = fallbackMatch.group(0)!;
        }
      }

      setState(() {
        if (extractedAadhar.length == 12) {
          _extractedAadharData['aadharNumber'] = extractedAadhar;
        }

        final dobRegex = RegExp(r'(?:DOB|Year of Birth|D\.O\.B)[:\s]*(\d{2}[/-]\d{2}[/-]\d{4}|\d{4})', caseSensitive: false);
        final genderRegex = RegExp(r'(Male|Female|Transgender|MALE|FEMALE)', caseSensitive: false);
        
        final dobMatch = dobRegex.firstMatch(fullText);
        final genderMatch = genderRegex.firstMatch(fullText);

        if (dobMatch != null) _extractedAadharData['dob'] = dobMatch.group(1)!;
        if (genderMatch != null) _extractedAadharData['gender'] = genderMatch.group(0)!;

        if (fullText.toLowerCase().contains('government') || fullText.toLowerCase().contains('india') || dobMatch != null) {
           List<String> lines = fullText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
           for (int i = 0; i < lines.length; i++) {
             String line = lines[i];
             if (line.toLowerCase().contains('dob') || line.toLowerCase().contains('year') || line.contains(RegExp(r'\d{4}'))) {
               if (i > 0) {
                 String potentialName = lines[i-1];
                 if (potentialName.length > 3 && !potentialName.contains(RegExp(r'\d')) && 
                     !potentialName.toLowerCase().contains('government') && !potentialName.toLowerCase().contains('india')) {
                    _extractedAadharData['name'] = potentialName;
                    break;
                 }
               }
             }
           }
        }

        if (fullText.toLowerCase().contains('address')) {
          List<String> lines = fullText.split('\n');
          int addressIndex = -1;
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].toLowerCase().contains('address')) {
              addressIndex = i;
              break;
            }
          }
          if (addressIndex != -1) {
            String address = lines.sublist(addressIndex).join(', ').replaceAll(RegExp(r'Address:?', caseSensitive: false), '').trim();
            _extractedAadharData['address'] = address;
          }
        }
      });

      debugPrint("Aaadhar Number ::: Extracted Aadhar Data: isFront = $isFront ::: $_extractedAadharData");

      await textRecognizer.close();
    } catch (e) {
      debugPrint('Error extracting text: $e');
    } finally {
      setState(() {
        _isExtractingText = false;
      });
    }
  }

  Future<void> _pickDocumentPhoto({
    required String title,
    required Function(File) onImagePicked,
  }) async {
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
                      title,
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
                    onImagePicked(File(image.path));
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
                    onImagePicked(File(image.path));
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
              child: _buildImageUploadCard(
                file: _userPhoto,
                onTap: _isDetectingFace ? null : _pickUserPhoto,
                title: 'User Photo *',
                subtitle: 'Face Scan (Camera)',
                icon: Icons.face_retouching_natural_rounded,
                iconColor: const Color(0xFF2C599D),
                isLoading: _isDetectingFace,
                loadingText: 'Detecting face...',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildImageUploadCard(
                file: _aadharPhoto,
                onTap: _isExtractingText ? null : _pickAadharPhoto,
                title: 'Aadhar Front *',
                subtitle: 'Camera or Gallery',
                icon: Icons.badge_rounded,
                iconColor: const Color(0xFFF98125),
                isLoading: _isExtractingText,
                loadingText: 'Scanning...',
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildImageUploadCard(
                file: _aadharPhotoBack,
                onTap: _isExtractingText ? null : _pickAadharPhotoBack,
                title: 'Aadhar Back *',
                subtitle: 'Camera or Gallery',
                icon: Icons.badge_rounded,
                iconColor: const Color(0xFFF98125),
                isLoading: _isExtractingText,
                loadingText: 'Scanning...',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildImageUploadCard(
                file: _employeeIdProof,
                onTap: _pickEmployeeCardPhoto,
                title: 'Employee Card',
                subtitle: 'Camera / Gallery (Crop)',
                icon: Icons.badge_outlined,
                iconColor: const Color(0xFF8E24AA),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageUploadCard({
    required File? file,
    required VoidCallback? onTap,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    bool isLoading = false,
    String? loadingText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: file != null
                ? Colors.green.withValues(alpha: 0.5)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (file != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  cacheHeight: 400,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, color: Colors.red),
                    );
                  },
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
                  if (isLoading) ...[
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: iconColor,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      loadingText ?? 'Loading...',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ] else ...[
                    Icon(
                      icon,
                      color: iconColor,
                      size: 32.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
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
    );
  }
}

class _CollectPaymentBottomSheet extends StatefulWidget {
  final String phone;
  final String firstName;
  final String lastName;
  final String sharingType;
  final String? email;
  final String? userPhotoPath;
  final String? aadharPhotoPath;
  final String? aadharCardbackPath;
  final String? employeeIdProofPath;
  final List<Map<String, String>>? guardianMobiles;
  final double securityDeposit;
  final double rent;
  final String checkInDate;
  final String checkOutDate;
  final double maintainance;
  final String roomType;
  final String aadhaarNumber;
  final String dob;
  final String gender;
  final String address;

  final Hostel selectedHostel;
  final RoomDetail selectedRoom;
  final String selectedBed;
  final StayType stayType;
  final AddTenantCubit addTenantCubit;
  final double totalAmount;

  const _CollectPaymentBottomSheet({
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.sharingType,
    this.email,
    this.userPhotoPath,
    this.aadharPhotoPath,
    this.aadharCardbackPath,
    this.employeeIdProofPath,
    this.guardianMobiles,
    required this.securityDeposit,
    required this.rent,
    required this.checkInDate,
    required this.checkOutDate,
    required this.maintainance,
    required this.roomType,
    required this.aadhaarNumber,
    required this.dob,
    required this.gender,
    required this.address,
    required this.selectedHostel,
    required this.selectedRoom,
    required this.selectedBed,
    required this.stayType,
    required this.addTenantCubit,
    required this.totalAmount
  });

  @override
  State<_CollectPaymentBottomSheet> createState() =>
      _CollectPaymentBottomSheetState();
}

class _CollectPaymentBottomSheetState
    extends State<_CollectPaymentBottomSheet> {
  late TextEditingController _collectingNowController;
  final TextEditingController _discountController = TextEditingController();
  double _discountAmount = 0.0;
  String _paymentMethod = 'Cash';
  String _collectionType = 'Full amount';
  bool _isSubmitting = false;

  int get _occupiedDays {
    if (widget.checkInDate.isEmpty) return 0;
    try {
      final checkIn = DateTime.parse(widget.checkInDate);
      if (widget.stayType == StayType.MONTHLY) {
        final monthEnd = DateTime(checkIn.year, checkIn.month + 1, 0);
        return monthEnd.day - checkIn.day + 1;
      } else if (widget.stayType == StayType.CUSTOM && widget.checkOutDate.isNotEmpty) {
        final checkOut = DateTime.parse(widget.checkOutDate);
        return checkOut.difference(checkIn).inDays + 1;
      }
    } catch (_) {}
    return 0;
  }

  int get _daysInMonth {
    if (widget.checkInDate.isEmpty) return 30;
    try {
      final checkIn = DateTime.parse(widget.checkInDate);
      final monthEnd = DateTime(checkIn.year, checkIn.month + 1, 0);
      return monthEnd.day;
    } catch (_) {}
    return 30;
  }

  double get _calculatedProratedRent {
    if (widget.stayType == StayType.MONTHLY) {
      if (_occupiedDays > 0 && _daysInMonth > 0) {
        return (widget.rent / _daysInMonth) * _occupiedDays;
      }
    } else if (widget.stayType == StayType.CUSTOM) {
      if (_occupiedDays > 0) {
        return widget.rent * _occupiedDays;
      }
    }
    return widget.rent;
  }

  bool get _isProrated {
    if (widget.stayType == StayType.MONTHLY) {
      return _occupiedDays > 0 && _occupiedDays < _daysInMonth;
    } else if (widget.stayType == StayType.CUSTOM) {
      return true;
    }
    return false;
  }

  double get _baseTotal {
    if (widget.totalAmount > 0) {
      return widget.totalAmount;
    }
    return _calculatedProratedRent + widget.securityDeposit + widget.maintainance;
  }

  @override
  void initState() {
    super.initState();
    _collectingNowController =
        TextEditingController(text: _baseTotal.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _collectingNowController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _onCollectionTypeChanged(String type) {
    double totalDue =
        (_baseTotal - _discountAmount).clamp(0, double.infinity);
    setState(() {
      _collectionType = type;
      _collectingNowController.text = totalDue.toStringAsFixed(0);
    });
  }

  void _showDiscountDialog() {
    _discountController.text =
        _discountAmount > 0 ? _discountAmount.toStringAsFixed(0) : '';
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Add Discount or Waiver',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter discount or waiver amount',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (_discountAmount > 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    _discountAmount = 0.0;
                    double totalDue = _baseTotal.clamp(0, double.infinity);
                    _collectingNowController.text =
                        totalDue.toStringAsFixed(0);
                  });
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double discount =
                    double.tryParse(_discountController.text.trim()) ?? 0.0;
                double maxTotal = _baseTotal;
                if (discount > maxTotal) {
                  discount = maxTotal;
                }
                setState(() {
                  _discountAmount = discount;
                  double totalDue =
                      (maxTotal - _discountAmount).clamp(0, double.infinity);
                  _collectingNowController.text =
                      totalDue.toStringAsFixed(0);
                });
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text(
                'Apply',
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

  Future<void> _handleProceed() async {
    setState(() => _isSubmitting = true);

    double finalTotal = (_baseTotal - _discountAmount).clamp(0, double.infinity);
    final String totalAmount = finalTotal.toStringAsFixed(2);

    try {
      final response = await widget.addTenantCubit.submit(
        hostel: widget.selectedHostel,
        room: widget.selectedRoom,
        bed: widget.selectedBed,
        phone: widget.phone,
        firstName: widget.firstName,
        lastName: widget.lastName,
        sharingType: widget.sharingType,
        email: widget.email,
        userPhotoPath: widget.userPhotoPath,
        aadharPhotoPath: widget.aadharPhotoPath,
        aadharCardbackPath: widget.aadharCardbackPath,
        employeeIdProofPath: widget.employeeIdProofPath,
        guardianMobiles: widget.guardianMobiles,
        deposit: widget.securityDeposit,
        rent: widget.rent,
        startDate: (widget.checkInDate.isNotEmpty)
            ? DateTime.parse(widget.checkInDate)
            : DateTime.now(),
        bookingType: widget.stayType.name.toString(),
        maintenance: widget.maintainance.toString(),
        roomType: widget.roomType,
        endDate: (widget.checkOutDate.isNotEmpty)
            ? DateTime.parse(widget.checkOutDate)
            : DateTime.now(),
        aadhaarNumber: widget.aadhaarNumber,
        dob: widget.dob,
        gender: widget.gender,
        address: widget.address,
        totalAmount: double.tryParse(totalAmount) ?? 0.0,
      );

      if (response != null && mounted) {
        final data = response['data'] ?? response;
        final String tenantId = (data['tenant']?['_id'] ?? data['tenantId'] ?? data['id'] ?? '').toString();
        final String bookingId = (data['bookingId'] ?? data['_id'] ?? '').toString();
        final String hostelId = (data['hostel']?['_id'] ?? widget.selectedHostel.id).toString();

        double collectingNow = finalTotal;

        if (collectingNow > 0) {
          double rentPaid = _calculatedProratedRent;
          double depositPaid = widget.securityDeposit;
          double maintenancePaid = widget.maintainance;

          await context.read<PaymentReportCubit>().submitPayment(
                tenantId: tenantId,
                hostelId: hostelId,
                bookingId: bookingId,
                amount: double.parse(collectingNow.toStringAsFixed(2)),
                rent: double.parse(rentPaid.toStringAsFixed(2)),
                deposit: depositPaid,
                utilities: 0,
                others: maintenancePaid,
                category: 'Rent',
                mode: _paymentMethod,
                date: DateTime.now().toIso8601String(),
                sendWhatsapp: true,
              );
        }
        
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double originalTotal = _baseTotal;
    double finalTotal = (originalTotal - _discountAmount).clamp(0, double.infinity);
    final authState = context.read<AuthCubit>().state;
    String collectorName = "You";
    if (authState is AuthAuthenticated) {
      collectorName = "${authState.owner.name} (you)";
    }

    String? rentSubtitle;
    if (_isProrated) {
      rentSubtitle = '$_occupiedDays days stay (Prorated: ₹${NumberFormat('#,##,###').format(_calculatedProratedRent)})';
    } else if (widget.checkInDate.isNotEmpty) {
      try {
        final checkIn = DateTime.parse(widget.checkInDate);
        final monthEnd = DateTime(checkIn.year, checkIn.month + 1, 0);
        rentSubtitle = '${DateFormat('dd MMM').format(checkIn)} - ${DateFormat('dd MMM').format(monthEnd)}';
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collect Payment',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Not collected',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  _buildDueItem('Rent', widget.rent, subtitle: rentSubtitle),
                  SizedBox(height: 12.h),
                  _buildDueItem('Security deposit', widget.securityDeposit),
                  SizedBox(height: 12.h),
                  _buildDueItem('Maintainance', widget.maintainance),
                  SizedBox(height: 12.h),
                  if (_discountAmount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Discount / Waiver',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: _showDiscountDialog,
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16.sp,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '- ₹${NumberFormat('#,##,###').format(_discountAmount)}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ]
                  else ...[
                    GestureDetector(
                      onTap: _showDiscountDialog,
                      child: Row(
                        children: [
                          Text(
                            '+ Add discount or waiver',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Divider(color: Colors.grey[200]),
                  ),
                  if (_discountAmount > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total due',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(originalTotal)}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total amount',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(finalTotal)}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total amount',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(originalTotal)}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // SizedBox(height: 24.h),
            // Text(
            //   'Collecting now',
            //   style: TextStyle(
            //     fontSize: 14.sp,
            //     fontWeight: FontWeight.w600,
            //     color: Colors.grey[600],
            //   ),
            // ),
            // SizedBox(height: 8.h),
            // TextField(
            //   controller: _collectingNowController,
            //   keyboardType: TextInputType.number,
            //   style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            //   decoration: InputDecoration(
            //     filled: true,
            //     fillColor: const Color(0xFFF1F5F9),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12.r),
            //       borderSide: BorderSide.none,
            //     ),
            //     contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            //   ),
            // ),
            // SizedBox(height: 16.h),
            // Row(
            //   children: [
            //     _buildToggleBtn('Full amount'),
            //     SizedBox(width: 8.w),
            //     _buildToggleBtn('Deposit only'),
            //     SizedBox(width: 8.w),
            //     _buildToggleBtn('Nothing now'),
            //   ],
            // ),
            // SizedBox(height: 12.h),
            // Text(
            //   'Balance carried forward: ₹${(totalDue - (double.tryParse(_collectingNowController.text) ?? 0)).toStringAsFixed(0)}',
            //   style: TextStyle(
            //     fontSize: 12.sp,
            //     color: Colors.grey[500],
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            SizedBox(height: 24.h),
            Text(
              'Payment method',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildMethodBtn('Cash'),
                SizedBox(width: 8.w),
                _buildMethodBtn('UPI / QR', value: 'UPI'),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Received by',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                collectorName,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _paymentMethod == 'Cash'
                            ? 'Mark cash as received'
                            : _paymentMethod == 'UPI'
                                ? 'Mark UPI as received'
                                : 'Send payment link',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueItem(String label, double amount, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null && subtitle.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        Text(
          '₹${NumberFormat('#,##,###').format(amount)}',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleBtn(String label) {
    bool isSelected = _collectionType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onCollectionTypeChanged(label),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodBtn(String label, {String? value}) {
    String actualValue = value ?? label;
    bool isSelected = _paymentMethod == actualValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = actualValue),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
