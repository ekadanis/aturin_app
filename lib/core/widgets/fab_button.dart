import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class FabButton extends StatelessWidget {
  final String heroTag;
  final String iconPath;
  final VoidCallback onPressed;

  const FabButton({
    super.key,
    required this.heroTag,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: true,
      onPressed: onPressed,
      backgroundColor: AppTheme.primaryColor,
      shape: const CircleBorder(),
      child: SvgPicture.asset(
        iconPath,
        height: 24,
        width: 24,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
