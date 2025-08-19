import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.8;
    final buttonSize = screenWidth * 0.12;
    final maxPosition = containerWidth - buttonSize - (screenWidth * 0.02);

    return Column(
      children: [
        Container(
          width: containerWidth,
          height: screenWidth * 0.14,
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
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),

              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: _shimmerAnimation.value * containerWidth,
                    child: Container(
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.14,
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

              Positioned(
                left: _position,
                top: screenWidth * 0.01,  
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
                      size: screenWidth * 0.05, // Setara dengan 5.w
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenWidth * 0.02), // Setara dengan 1.h (perkiraan)
        Text(
          widget.description,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.lightSecondaryTextColor,
            fontSize: screenWidth * 0.03, // Setara dengan 3.w
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}