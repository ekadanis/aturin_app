import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileAvatar extends StatelessWidget {
  final String avatarPath;
  final VoidCallback onEditPressed;

  const ProfileAvatar({
    Key? key,
    required this.avatarPath,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage(avatarPath),
          ),
        ),
        Positioned(
          right: 5,
          bottom: 25,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFB3B3B3),
                width: 1.6,
              ),
            ),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/edit.svg',
                  width: 14,
                  height: 14,
                  color: const Color(0xFFB3B3B3),
                ),
                padding: EdgeInsets.zero,
                onPressed: onEditPressed,
              ),
            ),
          ),
        )
      ],
    );
  }
}
