import 'package:flutter/material.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/model/task_model.dart';

/// Schedule Animator - Following TaskAnimator pattern
class ScheduleAnimator {
  final TickerProvider vsync;
  String animationStyle;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  dynamic _currentItem;
  bool _isCompletion = false;

  ScheduleAnimator({
    required this.vsync,
    required this.animationStyle,
  }) {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void updateAnimationStyle(String newStyle) {
    animationStyle = newStyle;
  }

  /// Prepare item for completion animation (tasks only)
  void prepareItemAnimation(dynamic item, bool isCompleting) {
    _currentItem = item;
    _isCompletion = isCompleting;
  }

  /// Prepare item for deletion animation (both aktivitas and tasks)
  void prepareItemDeletion(dynamic item, Future<void> Function() onDelete) {
    _currentItem = item;
    _isCompletion = false;
    
    // Start animation then execute delete
    _animationController.forward().then((_) async {
      await onDelete();
      _animationController.reset();
    });
  }

  /// Build animated item widget - following TaskAnimator pattern
  Widget buildAnimatedItem(
    dynamic item,
    Widget child, {
    required VoidCallback onAnimationComplete,
  }) {
    switch (animationStyle.toLowerCase()) {
      case 'fade':
        return _buildFadeAnimation(child, onAnimationComplete);
      case 'slide':
        return _buildSlideAnimation(child, onAnimationComplete);
      case 'scale':
      default:
        return _buildScaleAnimation(child, onAnimationComplete);
    }
  }

  Widget _buildScaleAnimation(Widget child, VoidCallback onAnimationComplete) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, _) {
        if (_scaleAnimation.isCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onAnimationComplete();
          });
        }
        
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _scaleAnimation.value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildFadeAnimation(Widget child, VoidCallback onAnimationComplete) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, _) {
        if (_fadeAnimation.isCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onAnimationComplete();
          });
        }
        
        return Opacity(
          opacity: _fadeAnimation.value,
          child: child,
        );
      },
    );
  }

  Widget _buildSlideAnimation(Widget child, VoidCallback onAnimationComplete) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, _) {
        if (_slideAnimation.isCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onAnimationComplete();
          });
        }
        
        return SlideTransition(
          position: _slideAnimation,
          child: Opacity(
            opacity: 1.0 - _slideAnimation.value.dx,
            child: child,
          ),
        );
      },
    );
  }

  /// Get current item being animated
  dynamic get currentItem => _currentItem;

  /// Check if current animation is for completion
  bool get isCompletion => _isCompletion;

  /// Dispose animations
  void dispose() {
    _animationController.dispose();
  }
}
