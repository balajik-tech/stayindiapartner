import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FloorAccordion extends StatefulWidget {
  final String title;
  final String bedInfo;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool isInitialExpanded;
  final bool isGridView;

  const FloorAccordion({
    super.key,
    required this.title,
    required this.bedInfo,
    required this.itemCount,
    required this.itemBuilder,
    this.isInitialExpanded = false,
    this.isGridView = false,
  });

  @override
  State<FloorAccordion> createState() => _FloorAccordionState();
}

class _FloorAccordionState extends State<FloorAccordion>
    with SingleTickerProviderStateMixin {
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
          Semantics(
            label: '${widget.title}, ${widget.bedInfo}',
            expanded: _isExpanded,
            button: true,
            onTap: () {
              if (mounted) {
                setState(() => _isExpanded = !_isExpanded);
              }
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (mounted) {
                    setState(() => _isExpanded = !_isExpanded);
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 4.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7000),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(child: _buildBedInfo(widget.bedInfo)),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20.sp,
                          color: const Color(0xFF3B71CA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isExpanded && widget.itemCount > 0)
            RepaintBoundary(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                child: widget.isGridView
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final double width = constraints.maxWidth;

                          int crossAxisCount = 2;
                          if (width > 600) {
                            crossAxisCount = 3;
                          }

                          final double spacing = 16.w;
                          final double itemWidth =
                              (width - (crossAxisCount - 1) * spacing) /
                              crossAxisCount;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: 16.h,
                            children: List.generate(widget.itemCount, (index) {
                              return SizedBox(
                                width: itemWidth,
                                child: widget.itemBuilder(context, index),
                              );
                            }),
                          );
                        },
                      )
                    : Column(
                        children: List.generate(widget.itemCount, (index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: widget.itemBuilder(context, index),
                          );
                        }),
                      ),
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
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          info,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
        ),
      );
    }

    final currentCount = parts[0].trim();
    final remaining = parts[1].trim();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: '$currentCount ',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C599D),
                ),
              ),
              TextSpan(text: '/ $remaining'),
            ],
          ),
        ),
      ),
    );
  }
}
