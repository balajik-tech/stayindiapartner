import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/location/location_service.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/settings_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'hostel_documents_page.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'dart:io';

class HostelProfilePage extends StatefulWidget {
  const HostelProfilePage({super.key});

  @override
  State<HostelProfilePage> createState() => _HostelProfilePageState();
}

class _HostelProfilePageState extends State<HostelProfilePage> {
  final _nameController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _areaController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  double? _lat;
  double? _lng;
  String _hostelType = 'men';
  String _propertyTag = 'PG';
  List<String> _images = [];
  final List<String> _localImagePaths = [];

  late final SettingsCubit _cubit;
  bool _isFetchingLocation = false;

  String _hostelId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _cubit = sl<SettingsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hostelId = _hostelId(context);
      if (hostelId.isNotEmpty) _cubit.loadSettings(hostelId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _areaController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    HapticFeedback.mediumImpact();
    
    try {
      final locationResult = await LocationService().getCurrentLocation();
      
      setState(() {
        _lat = locationResult.latitude;
        _lng = locationResult.longitude;
        _stateController.text = locationResult.administrativeArea ?? "";
        _districtController.text = locationResult.subAdministrativeArea ?? "";
        _villageController.text = locationResult.locality ?? locationResult.subLocality ?? "";
        _areaController.text = "${locationResult.street ?? ""}, ${locationResult.subLocality ?? ""}".trim();
        _pincodeController.text = locationResult.pincode ?? "";
        _addressController.text = "${locationResult.street ?? ''}, ${locationResult.subLocality ?? ''}, ${locationResult.locality ?? ''}, ${locationResult.administrativeArea ?? ''}".trim();
      });
      HapticFeedback.heavyImpact();
    } catch (e) {
      if (mounted) {
        String message = 'Error: $e';
        if (e.toString().contains('Location services are disabled')) {
          message = 'Location services are disabled. Please enable them.';
        } else if (e.toString().contains('denied')) {
          message = 'Location permissions denied.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            final p = state.settings.profile;
            _nameController.text = p.name;
            _stateController.text = p.state;
            _districtController.text = p.district;
            _villageController.text = p.village.isNotEmpty ? p.village : p.city;
            _areaController.text = p.area;
            _pincodeController.text = p.pincode;
            _addressController.text = p.address;
            _phoneController.text = p.contactNumber;
            _emailController.text = p.contactEmail;
            _images = state.settings.images ?? [];
            _descriptionController.text = p.description;
            _lat = p.lat;
            _lng = p.lng;
            _hostelType = p.hostelType;
            _propertyTag = p.propertyTag ?? 'PG';
            if (mounted) setState(() {});
          } else if (state is SettingsSaveSuccess) {
            context.read<HostelCubit>().getHostels();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8F9FA),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Hostel Profile',
              style: TextStyle(color: AppColors.darkText, fontSize: 18.sp, fontWeight: FontWeight.w900),
            ),
          ),
          body: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoading) return const Center(child: CircularProgressIndicator());
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPremiumImageSection(state),
                          SizedBox(height: 12.h),
                          _buildSection(
                            title: 'BASIC INFO',
                            icon: Icons.business_rounded,
                            children: [
                              _buildInputField(label: 'Hostel Name', controller: _nameController, hint: 'e.g. Stay India Premium'),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Expanded(child: _buildDropdownField(label: 'Hostel Type', value: _hostelType, items: ['men', 'women', 'co-ed'], onChanged: (v) => setState(() => _hostelType = v!))),
                                  SizedBox(width: 16.w),
                                  Expanded(child: _buildDropdownField(label: 'Category', value: _propertyTag, items: ['PG', 'BOYS', 'GIRLS', 'CO_LIVING'], onChanged: (v) => setState(() => _propertyTag = v!))),
                                ],
                              ),
                            ],
                          ),
                          _buildSection(
                            title: 'LOCATION DETAILS',
                            icon: Icons.location_on_rounded,
                            action: _buildGPSButton(),
                            children: [
                              if (_lat != null) _buildCoordinatesPill(),
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Expanded(child: _buildInputField(label: 'State', controller: _stateController, hint: 'State')),
                                  SizedBox(width: 16.w),
                                  Expanded(child: _buildInputField(label: 'District', controller: _districtController, hint: 'District')),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              _buildInputField(label: 'City / Village', controller: _villageController, hint: 'City name'),
                              SizedBox(height: 20.h),
                              _buildInputField(label: 'Area / Landmark', controller: _areaController, hint: 'Street, near XYZ...'),
                              SizedBox(height: 20.h),
                              _buildInputField(label: 'Pincode', controller: _pincodeController, hint: '6-digit code', keyboardType: TextInputType.number),
                              SizedBox(height: 20.h),
                              _buildInputField(label: 'Auto-generated Full Address', controller: _addressController, hint: 'Fetched from GPS', maxLines: 2, readOnly: true),
                            ],
                          ),
                          _buildSection(
                            title: 'CONTACT & DESCRIPTION',
                            icon: Icons.contact_phone_rounded,
                            children: [
                              _buildInputField(label: 'Contact Number', controller: _phoneController, hint: '9988776655', keyboardType: TextInputType.phone),
                              SizedBox(height: 20.h),
                              _buildInputField(label: 'Official Email', controller: _emailController, hint: 'hostel@email.com', keyboardType: TextInputType.emailAddress),
                              SizedBox(height: 20.h),
                              _buildInputField(label: 'About Hostel', controller: _descriptionController, hint: 'Tell tenants about your hostel...', maxLines: 4, keyboardType: TextInputType.multiline),
                            ],
                          ),
                          _buildDocumentsTile(),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ),
                  _buildStickyBottomBar(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, Widget? action, required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: AppColors.primaryBlue),
              SizedBox(width: 8.w),
              Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.greyText.withValues(alpha: 0.6), letterSpacing: 1.2)),
              const Spacer(),
              action ?? const SizedBox.shrink(),
            ],
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String hint, int maxLines = 1, bool readOnly = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.darkText.withValues(alpha: 0.8))),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: readOnly ? AppColors.greyText : AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.greyText.withValues(alpha: 0.4), fontSize: 14.sp),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF1F3F5) : const Color(0xFFF8F9FA),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.5), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String value, required List<String> items, required void Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.darkText.withValues(alpha: 0.8))),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16.r)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase(), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGPSButton() {
    return GestureDetector(
      onTap: _isFetchingLocation ? null : _fetchCurrentLocation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isFetchingLocation 
              ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue))
              : Icon(Icons.my_location_rounded, size: 14.sp, color: AppColors.primaryBlue),
            SizedBox(width: 6.w),
            Text(_isFetchingLocation ? 'Fetching...' : 'GPS Fetch', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(color: const Color(0xFFE7F5FF), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFFD0EBFF))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF228BE6), size: 16),
          SizedBox(width: 8.w),
          Text('Location Verified: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1971C2))),
        ],
      ),
    );
  }

  Widget _buildPremiumImageSection(SettingsState state) {
    final allImages = [..._images.map((e) => {'path': e, 'remote': true}), ..._localImagePaths.map((e) => {'path': e, 'remote': false})];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allImages.isNotEmpty) ...[
          Container(
            height: 220.h,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: allImages[0]['remote'] as bool
                    ? CachedNetworkImage(imageUrl: ApiConstants.getPlaceholderImageUrl(allImages[0]['path'] as String), width: double.infinity, fit: BoxFit.cover)
                    : Image.file(File(allImages[0]['path'] as String), width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(top: 12, right: 12, child: _buildImageDeleteBtn(0, allImages[0]['remote'] as bool)),
                Positioned(bottom: 12, left: 12, child: Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12.r)), child: Text('Cover Photo', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w800)))),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: allImages.length,
              itemBuilder: (context, index) {
                if (index == 0) return const SizedBox.shrink();
                final img = allImages[index];
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Stack(
                    children: [
                      Container(width: 80.w, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.white, width: 2)), child: ClipRRect(borderRadius: BorderRadius.circular(14.r), child: img['remote'] as bool ? CachedNetworkImage(imageUrl: ApiConstants.getPlaceholderImageUrl(img['path'] as String), fit: BoxFit.cover) : Image.file(File(img['path'] as String), fit: BoxFit.cover))),
                      Positioned(top: 4, right: 4, child: _buildImageDeleteBtn(index, img['remote'] as bool, small: true)),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else
          _buildEmptyImageCard(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: GestureDetector(
            onTap: _pickImages,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), style: BorderStyle.solid)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_rounded, color: AppColors.primaryBlue, size: 20.sp), SizedBox(width: 8.w), Text('Add Hostel Photos', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800, fontSize: 14.sp))]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyImageCard() {
    return Container(
      height: 180.h,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(24.r)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_search_rounded, size: 48.sp, color: AppColors.greyText.withValues(alpha: 0.3)), SizedBox(height: 12.h), Text('No images uploaded', style: TextStyle(color: AppColors.greyText, fontWeight: FontWeight.w600, fontSize: 14.sp))]),
    );
  }

  Widget _buildImageDeleteBtn(int index, bool isRemote, {bool small = false}) {
    return GestureDetector(
      onTap: () => setState(() => isRemote ? _images.removeAt(index) : _localImagePaths.removeAt(index - _images.length)),
      child: Container(padding: EdgeInsets.all(small ? 4 : 6), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: Icon(Icons.close_rounded, color: Colors.white, size: small ? 12 : 16)),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context, SettingsState state) {
    final isSaving = state is SettingsSaving;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)), elevation: 0),
          child: isSaving 
            ? const CircularProgressIndicator(color: Colors.white) 
            : Text('Save Property Profile', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
    );
  }

  void _handleSave() {
    final hostelId = _hostelId(context);
    if (hostelId.isEmpty) return;
    HapticFeedback.mediumImpact();
    _cubit.updateFullProfile(hostelId, name: _nameController.text, address: _addressController.text, city: _villageController.text, village: _villageController.text, district: _districtController.text, area: _areaController.text, state: _stateController.text, pincode: _pincodeController.text, contactNumber: _phoneController.text, contactEmail: _emailController.text, description: _descriptionController.text, hostelType: _hostelType, propertyTag: _propertyTag, lat: _lat, lng: _lng, newImagePaths: _localImagePaths.isEmpty ? null : _localImagePaths, existingImages: _images);
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.pickFiles(type: FileType.image, allowMultiple: true);
    if (result != null && result.paths.isNotEmpty) setState(() => _localImagePaths.addAll(result.paths.whereType<String>()));
  }

  Widget _buildDocumentsTile() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24.r), border: Border.all(color: Colors.grey.shade100)),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HostelDocumentsPage(hostelId: _hostelId(context)))),
        contentPadding: EdgeInsets.all(16.r),
        leading: Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(color: const Color(0xFFFFF4E6), borderRadius: BorderRadius.circular(12.r)), child: const Icon(Icons.description_rounded, color: Color(0xFFF08C00))),
        title: Text('Property Documents', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.darkText)),
        subtitle: Text('Manage certificates & legal docs', style: TextStyle(fontSize: 12.sp, color: AppColors.greyText)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
}
