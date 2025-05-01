import 'package:flutter/material.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CancelSliderButton extends StatefulWidget {
  final String text;
  final String description;
  final VoidCallback? onCancelled;

  const CancelSliderButton({
    Key? key,
    required this.text,
    required this.description,
    this.onCancelled,
  }) : super(key: key);

  @override
  State<CancelSliderButton> createState() => _CancelSliderButtonState();
}

class _CancelSliderButtonState extends State<CancelSliderButton> with SingleTickerProviderStateMixin {
  double _position = 0;
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hitung lebar container dan max position untuk slider
    final containerWidth = 80.w;
    final buttonSize = 12.w;
    final maxPosition = containerWidth - buttonSize - 2.w; // Padding

    return Column(
      children: [
        Container(
          width: containerWidth,
          height: 14.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: const Color(0xFFA3BBFE),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Text center
              Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 4.w,
                  ),
                ),
              ),
              
              // Shimmer effect (animasi berkilau)
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: _shimmerAnimation.value * containerWidth,
                    child: Container(
                      width: 30.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              ),
              
              // The draggable button
              Positioned(
                left: _position,
                top: 1.w,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _position += details.delta.dx;
                      // Constrain position
                      if (_position < 0) {
                        _position = 0;
                      } else if (_position > maxPosition) {
                        _position = maxPosition;
                      }
                    });
                    
                    // If slid to the end, trigger callback
                    if (_position >= maxPosition * 0.95) {
                      if (widget.onCancelled != null) {
                        widget.onCancelled!();
                      }
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (_position < maxPosition * 0.95) {
                      // Return to start if not slid far enough
                      setState(() {
                        _position = 0;
                      });
                    }
                  },
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5263F3),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 5.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          widget.description,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.lightSecondaryTextColor,
            fontSize: 3.w,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}