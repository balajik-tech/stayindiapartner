import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/profile/domain/entities/room_detail.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_state.dart';
import 'package:stayindia_owner/injection_container.dart' as di;

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

  DateTime? _checkInDate;
  late AddTenantCubit _addTenantCubit;

  @override
  void initState() {
    super.initState();
    _addTenantCubit = di.sl<AddTenantCubit>();
    final hostelCubit = context.read<HostelCubit>();
    if (hostelCubit.state is HostelLoaded) {
      final hostels = (hostelCubit.state as HostelLoaded).hostels;
      if (hostels.isNotEmpty) {
        _addTenantCubit.selectHostel(hostels.first);
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
    super.dispose();
  }

  void _submit(AddTenantState state) {
    if (state is! AddTenantReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final rentText = _rentController.text.trim();
    final depositText = _depositController.text.trim();

    if (phone.isEmpty || rentText.isEmpty || _checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final nameParts = name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : null;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

    _addTenantCubit.submit(
      hostel: state.hostel,
      room: state.selectedRoom,
      bed: state.selectedBed,
      phone: phone,
      rent: double.tryParse(rentText) ?? 0,
      firstName: firstName,
      lastName: lastName,
      deposit: depositText.isNotEmpty ? double.tryParse(depositText) : null,
      startDate: _checkInDate!,
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
              const SnackBar(content: Text('Tenant added successfully'), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else if (state is AddTenantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          } else if (state is AddTenantBedsLoaded) {
            _rentController.text = state.selectedRoom.rent.toString();
            _depositController.text = state.selectedRoom.deposit.toString();
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
              'Add New Tenant',
              style: TextStyle(color: AppColors.darkText, fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<HostelCubit, HostelState>(
              builder: (context, hostelState) {
                List<Hostel> hostels = [];
                if (hostelState is HostelLoaded) {
                  hostels = hostelState.hostels;
                }

                return BlocBuilder<AddTenantCubit, AddTenantState>(
                  builder: (context, state) {
                    Hostel? selectedHostel;
                    List<int> floors = [];
                    int? selectedFloor;
                    List<RoomDetail> rooms = [];
                    RoomDetail? selectedRoom;
                    List<String> beds = [];
                    String? selectedBed;
                    bool isLoading = state is AddTenantLoading;

                    if (state is AddTenantFloorsLoaded) {
                      selectedHostel = state.hostel;
                      floors = state.floors;
                    } else if (state is AddTenantRoomsLoaded) {
                      selectedHostel = state.hostel;
                      floors = state.floors;
                      selectedFloor = state.selectedFloor;
                      rooms = state.rooms;
                    } else if (state is AddTenantBedsLoaded) {
                      selectedHostel = state.hostel;
                      floors = state.floors;
                      selectedFloor = state.selectedFloor;
                      rooms = state.rooms;
                      selectedRoom = state.selectedRoom;
                      beds = state.beds;
                    } else if (state is AddTenantReady) {
                      selectedHostel = state.hostel;
                      floors = state.floors;
                      selectedFloor = state.selectedFloor;
                      rooms = state.rooms;
                      selectedRoom = state.selectedRoom;
                      beds = state.beds;
                      selectedBed = state.selectedBed;
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Property Selection'),
                          SizedBox(height: 16.h),
                          _buildDropdown<Hostel>(
                            'Select Hostel *',
                            hostels,
                            selectedHostel,
                            (h) => _addTenantCubit.selectHostel(h!),
                            itemLabel: (h) => h.name,
                          ),

                          SizedBox(height: 32.h),
                          _buildSectionTitle('Tenant Details'),
                          SizedBox(height: 16.h),
                          _buildTextField('Full Name *', Icons.person_outline, _nameController),
                          SizedBox(height: 16.h),
                          _buildTextField('Phone Number *', Icons.phone_outlined, _phoneController, keyboardType: TextInputType.phone),
                          SizedBox(height: 16.h),
                          _buildTextField('Email Address (Optional)', Icons.email_outlined, _emailController, keyboardType: TextInputType.emailAddress),

                          SizedBox(height: 32.h),
                          _buildSectionTitle('Room Allocation'),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown<int>(
                                  'Floor *',
                                  floors,
                                  selectedFloor,
                                  (f) => _addTenantCubit.selectFloor(selectedHostel!, f!, floors),
                                  isLoading: isLoading,
                                  itemLabel: (f) => f == 0 ? 'Ground' : '$f${f == 1 ? 'st' : f == 2 ? 'nd' : f == 3 ? 'rd' : 'th'} Floor',
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildDropdown<RoomDetail>(
                                  'Room *',
                                  rooms,
                                  selectedRoom,
                                  (r) => _addTenantCubit.selectRoom(selectedHostel!, selectedFloor!, floors, r!, rooms),
                                  isLoading: isLoading,
                                  itemLabel: (r) => r.roomTypename,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _buildDropdown<String>(
                            'Bed *',
                            beds,
                            selectedBed,
                            (b) => _addTenantCubit.selectBed(selectedHostel!, selectedFloor!, floors, selectedRoom!, rooms, b!, beds),
                            isLoading: isLoading,
                            itemLabel: (b) {
                              final num = int.tryParse(b);
                              if (num != null && num > 0 && num <= 26) {
                                return 'Bed ${String.fromCharCode(64 + num)}';
                              }
                              return 'Bed $b';
                            },
                          ),

                          SizedBox(height: 32.h),
                          _buildSectionTitle('Stay Details'),
                          SizedBox(height: 16.h),
                          _buildTextField('Monthly Rent *', Icons.currency_rupee, _rentController, keyboardType: TextInputType.number),
                          SizedBox(height: 16.h),
                          _buildTextField('Security Deposit *', Icons.account_balance_wallet_outlined, _depositController, keyboardType: TextInputType.number),
                          SizedBox(height: 16.h),
                          _buildDatePicker(context, 'Check-in Date *'),

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
        onPressed: isSubmitting ? null : () => _submit(state),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: isSubmitting
            ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Add Tenant', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue));
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: AppColors.greyText, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15.sp, color: AppColors.darkText),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.greyText),
            hintText: 'Enter ${label.replaceAll(' *', '')}',
            hintStyle: TextStyle(color: AppColors.greyText.withValues(alpha: 0.5), fontSize: 15.sp),
            filled: true,
            fillColor: const Color(0xFFF2F4F7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(String label, List<T> items, T? value, ValueChanged<T?> onChanged, {bool isLoading = false, String Function(T)? itemLabel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: AppColors.greyText, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(12.r)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              hint: isLoading 
                ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(strokeWidth: 2))
                : Text('Select ${label.replaceAll(' *', '')}', style: TextStyle(color: AppColors.greyText.withValues(alpha: 0.5), fontSize: 15.sp)),
              items: items.map((T item) => DropdownMenuItem<T>(value: item, child: Text(itemLabel != null ? itemLabel(item) : item.toString(), style: TextStyle(fontSize: 15.sp)))).toList(),
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
        Text(label, style: TextStyle(fontSize: 14.sp, color: AppColors.greyText, fontWeight: FontWeight.w500)),
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
            decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(12.r)),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.greyText),
                SizedBox(width: 12.w),
                Text(
                  _checkInDate == null ? 'Select Date' : '${_checkInDate!.day}/${_checkInDate!.month}/${_checkInDate!.year}',
                  style: TextStyle(color: _checkInDate == null ? AppColors.greyText.withValues(alpha: 0.5) : AppColors.darkText, fontSize: 15.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
