import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/location/location_service.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng) onLocationSelected;

  const MapPickerPage({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation =
        widget.initialLocation ?? const LatLng(12.9716, 77.5946);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final locationResult = await LocationService().getCurrentLocation();
      final newLocation = LatLng(
        locationResult.latitude,
        locationResult.longitude,
      );
      setState(() {
        _selectedLocation = newLocation;
        _mapController.move(newLocation, 15);
      });
    } catch (e) {
      if (mounted) {
        String message = 'Failed to get current location';
        SnackBarAction? action;
        if (e.toString().contains('Location services are disabled')) {
          message = 'Location services are disabled. Please enable them.';
          action = SnackBarAction(
            label: 'Enable',
            textColor: Colors.white,
            onPressed: () async {
              await Geolocator.openLocationSettings();
            },
          );
        } else if (e.toString().contains('denied')) {
          message = 'Location permissions denied.';
          action = SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () async {
              await Geolocator.openAppSettings();
            },
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            action: action,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick Property Location',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF04214E),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation!,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() => _selectedLocation = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.stayindia.owner',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                        size: 40.sp,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          PositionRectangle(
            bottom: 120.h,
            right: 16.w,
            child: FloatingActionButton(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              backgroundColor: AppColors.primaryBlue,
              child: _isLoadingLocation
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 40.h,
            left: 24.w,
            right: 24.w,
            child: ElevatedButton(
              onPressed: () => widget.onLocationSelected(_selectedLocation!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 8,
              ),
              child: Text(
                'CONFIRM LOCATION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 20.h,
            left: 24.w,
            right: 24.w,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Tap on the map to mark your hostel location precisely.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PositionRectangle extends StatelessWidget {
  final double? bottom;
  final double? right;
  final Widget child;
  const PositionRectangle({
    super.key,
    this.bottom,
    this.right,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(bottom: bottom, right: right, child: child);
  }
}
