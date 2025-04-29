// lib/widgets/cancel_slider.dart
import 'package:flutter/material.dart';

class CancelSlider extends StatefulWidget {
  final String text;
  final String description;

  const CancelSlider({
    Key? key,
    required this.text,
    required this.description,
  }) : super(key: key);

  @override
  State<CancelSlider> createState() => _CancelSliderState();
}

class _CancelSliderState extends State<CancelSlider> {
  double _position = 0;
  final double _buttonSize = 56;
  final double _maxWidth = 300;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: _maxWidth,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.indigo.shade400,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            children: [
              // Slider background with text
              Center(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Draggable button
              GestureDetector(
                onHorizontalDragStart: (details) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _position = (_position + details.delta.dx).clamp(0, _maxWidth - _buttonSize);
                  });
                },
                onHorizontalDragEnd: (details) {
                  setState(() {
                    _isDragging = false;
                    if (_position > _maxWidth * 0.7) {
                      // Alarm canceled
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alarm dimatikan!')),
                      );
                      // Reset position after a delay
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) {
                          setState(() {
                            _position = 0;
                          });
                        }
                      });
                    } else {
                      // Return to start position
                      setState(() {
                        _position = 0;
                      });
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: _position),
                  width: _buttonSize,
                  height: _buttonSize,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    shape: BoxShape.circle,
                    boxShadow: _isDragging
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.description,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}