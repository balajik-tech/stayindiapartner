import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ResponsiveBreakpoints {
  static const double xs = 320.0;
  static const double sm = 360.0;
  static const double md = 393.0;
  static const double lg = 412.0;

  static bool isSmallDevice(BuildContext context) {
    return MediaQuery.of(context).size.width <= sm;
  }

  static bool isUltraSmallDevice(BuildContext context) {
    return MediaQuery.of(context).size.width <= xs;
  }
}



class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final double minFontSize;
  final double maxFontSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.softWrap = true,
    this.overflow,
    this.maxLines,
    this.minFontSize = 10,
    this.maxFontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final double textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);
    final double screenWidth = MediaQuery.of(context).size.width;
    
    double baseFontSize = style?.fontSize ?? 14.sp;
    
    
    double widthScale = screenWidth < 360 ? 0.9 : 1.0;
    
    
    double adjustedScale = textScaleFactor > 1.3 ? (1.3 / textScaleFactor) : 1.0;
    
    double finalFontSize = (baseFontSize * widthScale * adjustedScale).clamp(minFontSize, maxFontSize);

    return Text(
      text,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      maxLines: maxLines,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: finalFontSize,
      ),
    );
  }
}



class AdaptiveActionRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final bool forceStackOnSmall;

  const AdaptiveActionRow({
    super.key,
    required this.children,
    this.spacing = 12.0,
    this.runSpacing = 12.0,
    this.forceStackOnSmall = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    
    if ((forceStackOnSmall && screenWidth <= 360.0) || textScale >= 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == children.length - 1 ? 0 : runSpacing,
            ),
            child: child,
          );
        }).toList(),
      );
    }

    
    return Row(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final isLast = index == children.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : spacing),
            child: child,
          ),
        );
      }).toList(),
    );
  }
}



class ResponsiveButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final double? height;

  const ResponsiveButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.isDestructive = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    final double verticalPadding = screenWidth <= 320 ? 10.0 : 14.0;
    final double horizontalPadding = screenWidth <= 320 ? 12.0 : 16.0;

    final TextStyle buttonTextStyle = TextStyle(
      fontSize: (screenWidth <= 320 ? 12.sp : 14.sp).clamp(10.0, 16.0),
      fontWeight: FontWeight.w800,
    );

    final Widget textWidget = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        style: buttonTextStyle,
      ),
    );

    final Widget content = icon != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: (screenWidth <= 320 ? 14.sp : 16.sp).clamp(12.0, 18.0)),
              SizedBox(width: 6.w),
              Flexible(child: textWidget),
            ],
          )
        : textWidget;

    
    final double minHeight = (height ?? 48.0).clamp(48.0, 60.0);

    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.redAccent : const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(double.infinity, minHeight),
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: content,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDestructive ? Colors.red.shade700 : const Color(0xFF0F172A),
        side: BorderSide(
          color: isDestructive ? Colors.red.shade200 : const Color(0xFFE2E8F0),
        ),
        minimumSize: Size(double.infinity, minHeight),
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: content,
    );
  }
}


class ResponsiveTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController? controller;
  final List<Widget> tabs;
  final bool isScrollable;
  final ValueChanged<int>? onTap;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Decoration? indicator;
  final TabBarIndicatorSize? indicatorSize;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  const ResponsiveTabBar({
    super.key,
    this.controller,
    required this.tabs,
    this.isScrollable = false,
    this.onTap,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicator,
    this.indicatorSize,
    this.labelStyle,
    this.unselectedLabelStyle,
  });

  int _getWidgetTextLength(Widget widget) {
    if (widget is Text) {
      return widget.data?.length ?? 0;
    } else if (widget is Row) {
      int length = 0;
      for (var child in widget.children) {
        length += _getWidgetTextLength(child);
      }
      return length;
    } else if (widget is Column) {
      int length = 0;
      for (var child in widget.children) {
        length += _getWidgetTextLength(child);
      }
      return length;
    } else if (widget is Container) {
      return widget.child != null ? _getWidgetTextLength(widget.child!) : 0;
    } else if (widget is Padding) {
      return widget.child != null ? _getWidgetTextLength(widget.child!) : 0;
    } else if (widget is SizedBox) {
      return widget.child != null ? _getWidgetTextLength(widget.child!) : 0;
    } else if (widget is Center) {
      return widget.child != null ? _getWidgetTextLength(widget.child!) : 0;
    } else if (widget is Align) {
      return widget.child != null ? _getWidgetTextLength(widget.child!) : 0;
    } else if (widget is Tab) {
      if (widget.text != null) {
        return widget.text!.length;
      }
      return widget.child != null ? _getWidgetTextLength(widget.child!) : 0;
    }
    return 0;
  }

  bool _evaluateShouldScroll(BuildContext context) {
    int totalTextLength = 0;
    for (var tab in tabs) {
      totalTextLength += _getWidgetTextLength(tab);
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final double estimatedTextWidth = totalTextLength * 8.5;
    final double totalRequiredWidth = estimatedTextWidth + (tabs.length * 32);
    
    return totalRequiredWidth > (screenWidth - 32);
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldScroll = isScrollable || _evaluateShouldScroll(context);

    return TabBar(
      controller: controller,
      isScrollable: shouldScroll,
      tabAlignment: shouldScroll ? TabAlignment.start : TabAlignment.fill,
      onTap: onTap,
      indicator: indicator ?? BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      labelColor: labelColor ?? Colors.white,
      unselectedLabelColor: unselectedLabelColor ?? const Color(0xFF64748B),
      labelStyle: labelStyle ?? TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
      unselectedLabelStyle: unselectedLabelStyle ?? TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
      indicatorSize: indicatorSize ?? TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}


class MultilingualSafeCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? padding;
  final double? margin;
  final double? borderRadius;
  final Border? border;

  const MultilingualSafeCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    final double calculatedPadding = padding ?? (screenWidth <= 320 ? 12.0 : 16.0);
    
    return Container(
      margin: EdgeInsets.only(bottom: margin ?? 16.h),
      padding: EdgeInsets.all(calculatedPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
        border: border ?? Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}


class ResponsiveSpacing {
  static Widget vertical(double height, BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    double calculated = (height * (screenHeight / 844.0)).clamp(4.0, height * 1.2);
    return SizedBox(height: calculated);
  }

  static Widget horizontal(double width, BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double calculated = (width * (screenWidth / 390.0)).clamp(4.0, width * 1.2);
    return SizedBox(width: calculated);
  }
}
