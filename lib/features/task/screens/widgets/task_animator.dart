// import 'package:flutter/material.dart';
// import 'dart:math' as math;
// import '../../model/task_model.dart';

// class TaskAnimator {
//   final TickerProvider vsync;
  
//   // Animation controllers
//   final Map<int?, AnimationController> _animationControllers = {};
//   final Map<int?, Animation<double>> _slideAnimations = {};
//   final Map<int?, Animation<double>> _opacityAnimations = {};
//   final Map<int?, Animation<double>> _scaleAnimations = {};
//   final Map<int?, Animation<double>> _rotationAnimations = {};
  
//   // Animation style - can be changed to try different animations
//   // Options: "slide", "flip", "fade", "rotate", "bounce"
//   String animationStyle;
  
//   TaskAnimator({
//     required this.vsync,
//     this.animationStyle = "rotate",
//   });
  
//   // Update animation style
//   void updateAnimationStyle(String newStyle) {
//     animationStyle = newStyle;
//   }
  
//   // Create a new animation controller
//   AnimationController _createAnimationController({Duration? duration}) {
//     return AnimationController(
//       duration: duration ?? const Duration(milliseconds: 550),
//       vsync: vsync,
//     );
//   }
  
//   // Dispose all animation controllers
//   void dispose() {
//     for (final controller in _animationControllers.values) {
//       controller.dispose();
//     }
//     _animationControllers.clear();
//     _slideAnimations.clear();
//     _opacityAnimations.clear();
//     _scaleAnimations.clear();
//     _rotationAnimations.clear();
//   }
  
//   // Prepare task animation (only setup, doesn't modify the list)
//   void prepareTaskAnimation(Task task, bool isCompleting) {
//     // Setup controller for animation
//     final controller = _createAnimationController();
    
//     // Configure animations based on selected style
//     switch (animationStyle) {
//       case "flip":
//         _setupFlipAnimation(task, controller, isCompleting);
//         break;
//       case "fade":
//         _setupFadeAnimation(task, controller, isCompleting);
//         break;
//       case "rotate":
//         _setupRotateAnimation(task, controller, isCompleting);
//         break;
//       case "bounce":
//         _setupBounceAnimation(task, controller, isCompleting);
//         break;
//       case "slide":
//       default:
//         _setupSlideAnimation(task, controller, isCompleting);
//         break;
//     }
    
//     // Start animation
//     controller.forward();
//   }
  
//   // Prepare task deletion animation (only setup, doesn't modify the list)
//   void prepareTaskDeletion(Task task, VoidCallback onComplete) {
//     final controller = _createAnimationController(
//       duration: const Duration(milliseconds: 300),
//     );
    
//     final exitOpacityAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeOut,
//     ));
    
//     final exitScaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.8,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeOutQuint,
//     ));
    
//     final exitSlideAnimation = Tween<double>(
//       begin: 0.0,
//       end: 0.3,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeOutCubic,
//     ));
    
//     _animationControllers[task.id] = controller;
//     _opacityAnimations[task.id] = exitOpacityAnimation;
//     _scaleAnimations[task.id] = exitScaleAnimation;
//     _slideAnimations[task.id] = exitSlideAnimation;
    
//     controller.forward().then((_) {
//       _cleanupAnimation(task.id);
//       onComplete();
//     });
//   }
  
//   // Build animated task widget
//   Widget buildAnimatedTask(Task task, Widget child, {VoidCallback? onAnimationComplete}) {
//     final controller = _animationControllers[task.id];
//     if (controller == null) return child;
    
//     // Add listener for animation completion if needed
//     if (onAnimationComplete != null && !controller.isCompleted) {
//       controller.removeStatusListener(_getStatusListener(task.id));
//       controller.addStatusListener(_getStatusListener(task.id, onComplete: onAnimationComplete));
//     }
    
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         // Apply different transformations based on animation style
//         Widget animatedWidget = child!;
        
//         // Apply opacity if available
//         if (_opacityAnimations.containsKey(task.id)) {
//           animatedWidget = Opacity(
//             opacity: _opacityAnimations[task.id]!.value,
//             child: animatedWidget,
//           );
//         }
        
//         // Apply scale if available
//         if (_scaleAnimations.containsKey(task.id)) {
//           animatedWidget = Transform.scale(
//             scale: _scaleAnimations[task.id]!.value,
//             child: animatedWidget,
//           );
//         }
        
//         // Apply rotation if available (for 3D flip or rotate animations)
//         if (_rotationAnimations.containsKey(task.id)) {
//           if (animationStyle == "flip") {
//             // For flip, rotate around Y axis (horizontal flip)
//             animatedWidget = Transform(
//               transform: Matrix4.identity()
//                 ..setEntry(3, 2, 0.001) // perspective
//                 ..rotateY(_rotationAnimations[task.id]!.value),
//               alignment: Alignment.center,
//               child: animatedWidget,
//             );
//           } else {
//             // For other rotations, rotate around Z axis
//             animatedWidget = Transform.rotate(
//               angle: _rotationAnimations[task.id]!.value,
//               child: animatedWidget,
//             );
//           }
//         }
        
//         // Apply slide if available
//         if (_slideAnimations.containsKey(task.id)) {
//           animatedWidget = Transform.translate(
//             offset: Offset(0, _slideAnimations[task.id]!.value * 120),
//             child: animatedWidget,
//           );
//         }
        
//         return animatedWidget;
//       },
//       child: child,
//     );
//   }
  
//   // Status listener factory to handle animation completion
//   AnimationStatusListener _getStatusListener(int? taskId, {VoidCallback? onComplete}) {
//     return (AnimationStatus status) {
//       if (status == AnimationStatus.completed) {
//         _cleanupAnimation(taskId);
//         onComplete?.call();
//       }
//     };
//   }
  
//   // Clean up animation resources
//   void _cleanupAnimation(int? taskId) {
//     final controller = _animationControllers[taskId];
//     if (controller != null) {
//       controller.removeStatusListener(_getStatusListener(taskId));
//       controller.dispose();
//     }
//     _animationControllers.remove(taskId);
//     _opacityAnimations.remove(taskId);
//     _scaleAnimations.remove(taskId);
//     _slideAnimations.remove(taskId);
//     _rotationAnimations.remove(taskId);
//   }
  
//   // 1. FLIP ANIMATION - 3D card flip effect
//   void _setupFlipAnimation(Task task, AnimationController controller, bool isCompleting) {
//     // Rotation animation for 3D flip effect
//     final rotationAnimation = Tween<double>(
//       begin: 0,
//       end: isCompleting ? math.pi / 2 : -math.pi / 2, // 90 degrees rotation
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeInOutCubic,
//     ));
    
//     // Scale down slightly during flip
//     final scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.9,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeInOutCubic,
//     ));
    
//     // Store animations
//     _animationControllers[task.id] = controller;
//     _rotationAnimations[task.id] = rotationAnimation;
//     _scaleAnimations[task.id] = scaleAnimation;
//   }
  
//   // 2. FADE ANIMATION - Elegant fade with scale
//   void _setupFadeAnimation(Task task, AnimationController controller, bool isCompleting) {
//     // Opacity animation
//     final opacityAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeOut,
//     ));
    
//     // Scale animation
//     final scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: isCompleting ? 0.8 : 1.2, // Scale down when completing, up when uncompleting
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeOutQuint,
//     ));
    
//     // Store animations
//     _animationControllers[task.id] = controller;
//     _opacityAnimations[task.id] = opacityAnimation;
//     _scaleAnimations[task.id] = scaleAnimation;
//   }
  
//   // 3. ROTATE ANIMATION - Rotate and slide
//   void _setupRotateAnimation(Task task, AnimationController controller, bool isCompleting) {
//     // Rotation animation
//     final rotationAnimation = Tween<double>(
//       begin: 0,
//       end: isCompleting ? 0.1 : -0.1, // Slight rotation (in radians)
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeInOutCubic,
//     ));
    
//     // Slide animation
//     final slideAnimation = Tween<double>(
//       begin: 0.0,
//       end: isCompleting ? 1.0 : -1.0, // Slide down or up
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeInOutCubic,
//     ));
    
//     // Opacity animation
//     final opacityAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
//     ));
    
//     // Store animations
//     _animationControllers[task.id] = controller;
//     _rotationAnimations[task.id] = rotationAnimation;
//     _slideAnimations[task.id] = slideAnimation;
//     _opacityAnimations[task.id] = opacityAnimation;
//   }
  
//   // 4. BOUNCE ANIMATION - Energetic bounce effect
//   void _setupBounceAnimation(Task task, AnimationController controller, bool isCompleting) {
//     // Scale animation with bounce
//     final scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: isCompleting ? 1.2 : 0.8, // Scale up when completing, down when uncompleting
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeInBack, // Overshoot for bounce effect
//     ));
    
//     // Slide animation
//     final slideAnimation = Tween<double>(
//       begin: 0.0,
//       end: isCompleting ? 0.8 : -0.8,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeInCubic,
//     ));
    
//     // Opacity animation
//     final opacityAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
//     ));
    
//     // Store animations
//     _animationControllers[task.id] = controller;
//     _scaleAnimations[task.id] = scaleAnimation;
//     _slideAnimations[task.id] = slideAnimation;
//     _opacityAnimations[task.id] = opacityAnimation;
//   }
  
//   // 5. SLIDE ANIMATION - Enhanced slide with better curves
//   void _setupSlideAnimation(Task task, AnimationController controller, bool isCompleting) {
//     // Slide animation
//     final slideAnimation = Tween<double>(
//       begin: 0.0,
//       end: isCompleting ? 0.5 : -0.5,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeOutCubic,
//     ));
    
//     // Opacity animation
//     final opacityAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
//     ));
    
//     // Scale animation
//     final scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: controller,
//       curve: Curves.easeOutCubic,
//     ));
    
//     // Store animations
//     _animationControllers[task.id] = controller;
//     _slideAnimations[task.id] = slideAnimation;
//     _opacityAnimations[task.id] = opacityAnimation;
//     _scaleAnimations[task.id] = scaleAnimation;
//   }
// }