import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';

class FloorAccordion extends StatefulWidget {
  final String title;
  final String bedInfo;
  final List<Widget> rooms;
  final bool isInitialExpanded;
  final bool isGridView;
  final VoidCallback? onDelete;

  const FloorAccordion({
    super.key,
    required this.title,
    required this.bedInfo,
    required this.rooms,
    this.isInitialExpanded = false,
    this.isGridView = false,
    this.onDelete,
  });

  @override
  State<FloorAccordion> createState() => _FloorAccordionState();
}

class _FloorAccordionState extends State<FloorAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      color: Colors.transparent,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (mounted) {
                  setState(() => _isExpanded = !_isExpanded);
                }
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7000), 
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: Text(
                        widget.title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E325C), 
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Flexible(
                      child: _buildBedInfo(widget.bedInfo),
                    ),
                    const Spacer(),
                    if (widget.onDelete != null)
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: Icon(Icons.delete_outline_rounded, size: 20.sp, color: Colors.red.withValues(alpha: 0.6)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                    SizedBox(width: 8.w),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 24.sp,
                      color: const Color(0xFF9EA3B0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: widget.isGridView
                  ? Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      children: widget.rooms.map((room) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 80.w) / 2, 
                          child: room,
                        );
                      }).toList(),
                    )
                  : Column(
                      children: widget.rooms,
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildBedInfo(String info) {
    if (info.isEmpty) return const SizedBox.shrink();
    
    final parts = info.split('/');
    if (parts.length < 2) {
      return Text(
        info,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.greyText.withValues(alpha: 0.8),
        ),
      );
    }
    
    final currentCount = parts[0].trim();
    final remaining = parts[1].trim(); 
    
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.greyText.withValues(alpha: 0.8),
          fontFamily: 'Roboto', 
        ),
        children: [
          TextSpan(
            text: '$currentCount ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          TextSpan(text: '/ $remaining'),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
