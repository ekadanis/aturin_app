import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarSelectionDialog extends StatelessWidget {
  final List<String> availableAvatars;
  final String selectedAvatar;
  final Function(String) onAvatarSelected;
  final VoidCallback onCancel;

  const AvatarSelectionDialog({
    Key? key,
    required this.availableAvatars,
    required this.selectedAvatar,
    required this.onAvatarSelected,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16.0), // Edge-to-edge with 16px margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Border radius 12
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
                16, 40, 16, 16), // Extra top padding for close button
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Pilih Jagoanmu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: availableAvatars.map((avatar) {
                    return GestureDetector(
                      onTap: () => onAvatarSelected(avatar),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(avatar),
                          ),
                          if (selectedAvatar == avatar)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Close button in top-right corner
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                ),
                child: SvgPicture.asset(
                  'assets/icons/close.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
