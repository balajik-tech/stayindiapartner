import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/electricity_bill_model.dart';

class ElectricitySettingsSheet extends StatefulWidget {
  final String currentPgName;
  final String currentSubtitle;
  final List<ElectricityRoomModel> rooms;
  final List<ElectricityBillModel> bills;
  final Function({
    required String pgName,
    required String subtitle,
    required List<ElectricityRoomModel> rooms,
  }) onSave;

  const ElectricitySettingsSheet({
    super.key,
    required this.currentPgName,
    required this.currentSubtitle,
    required this.rooms,
    required this.bills,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required String currentPgName,
    required String currentSubtitle,
    required List<ElectricityRoomModel> rooms,
    required List<ElectricityBillModel> bills,
    required Function({
      required String pgName,
      required String subtitle,
      required List<ElectricityRoomModel> rooms,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ElectricitySettingsSheet(
          currentPgName: currentPgName,
          currentSubtitle: currentSubtitle,
          rooms: rooms,
          bills: bills,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  State<ElectricitySettingsSheet> createState() => _ElectricitySettingsSheetState();
}

class _ElectricitySettingsSheetState extends State<ElectricitySettingsSheet> {
  late TextEditingController _pgNameController;
  late TextEditingController _subtitleController;
  late TextEditingController _addRoomController;
  late List<ElectricityRoomModel> _rooms;

  @override
  void initState() {
    super.initState();
    _pgNameController = TextEditingController(text: widget.currentPgName);
    _subtitleController = TextEditingController(text: widget.currentSubtitle);
    _addRoomController = TextEditingController();
    _rooms = List<ElectricityRoomModel>.from(widget.rooms);
  }

  @override
  void dispose() {
    _pgNameController.dispose();
    _subtitleController.dispose();
    _addRoomController.dispose();
    super.dispose();
  }

  void _handleAddRooms() {
    final text = _addRoomController.text.trim();
    if (text.isEmpty) return;

    final parts = text.split(RegExp(r'[,;\n]'));
    bool added = false;

    for (var p in parts) {
      final code = p.replaceAll(RegExp(r'^Room\s*', caseSensitive: false), '').trim();
      if (code.isNotEmpty && !_rooms.any((r) => r.code.toLowerCase() == code.toLowerCase())) {
        _rooms.add(ElectricityRoomModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + code,
          code: code,
          name: 'Room $code',
          isCustom: true,
        ));
        added = true;
      }
    }

    if (added) {
      setState(() {
        _addRoomController.clear();
      });
    }
  }

  void _handleRemoveRoom(String code) {
    setState(() {
      _rooms.removeWhere((r) => r.code == code);
    });
  }

  bool _hasBills(String roomCode) {
    return widget.bills.any((b) => b.roomCode == roomCode);
  }

  void _handleSave() {
    widget.onSave(
      pgName: _pgNameController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      rooms: _rooms,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Settings',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 16.h),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PG NAME
                    Text(
                      'PG NAME',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: _pgNameController,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFF112D4E), width: 1.5),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // SUBTITLE (OPTIONAL)
                    Text(
                      'SUBTITLE (OPTIONAL)',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TextFormField(
                      controller: _subtitleController,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: Color(0xFF112D4E), width: 1.5),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // ADD ROOM(S)
                    Text(
                      'ADD ROOM(S)',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _addRoomController,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. G03 or 103, 104',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(color: Color(0xFF112D4E), width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        ElevatedButton(
                          onPressed: _handleAddRooms,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF112D4E),
                            foregroundColor: Colors.white,
                            minimumSize: Size(80.w, 46.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Add',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Configured Rooms List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _rooms.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final room = _rooms[index];
                        final hasBills = _hasBills(room.code);

                        return Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              // Room Square Badge
                              Container(
                                width: 38.w,
                                height: 38.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF112D4E),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  room.code,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      room.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      hasBills ? 'Has bills' : 'No bills yet',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: const Color(0xFFEF4444),
                                  size: 20.sp,
                                ),
                                onPressed: () => _handleRemoveRoom(room.code),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Save Settings Primary Button
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF112D4E),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save settings',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
