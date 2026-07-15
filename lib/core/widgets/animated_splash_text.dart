import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedFutureOfLivingText extends StatefulWidget {
  const AnimatedFutureOfLivingText({super.key});

  @override
  State<AnimatedFutureOfLivingText> createState() => _AnimatedFutureOfLivingTextState();
}

class _AnimatedFutureOfLivingTextState extends State<AnimatedFutureOfLivingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = [
      {'text': 'Manage ', 'color': const Color(0xFF16539B)},
      {'text': 'simply, ', 'color': const Color(0xFF16539B)},
      {'text': 'grow ', 'color': const Color(0xFFFF7000)},
      {'text': 'rapidly', 'color': const Color(0xFFFF7000)},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(words.length, (index) {
        final start = index * 0.15;
        final end = start + 0.35;
        
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeIn),
          ),
        );

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutBack),
          ),
        );

        final word = words[index];
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Text(
              word['text'] as String,
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: word['color'] as Color,
                letterSpacing: -0.2,
                shadows: [
                  BoxShadow(
                    color: (word['color'] as Color).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
