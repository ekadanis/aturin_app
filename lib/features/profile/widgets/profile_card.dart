import 'package:flutter/material.dart';
import 'package:aturin_app/features/profile/models/user.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;

  const ProfileCard({
    Key? key,
    required this.user,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Background putih
      elevation: 0, // Menghapus shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Color(0xFFE4E4E7), // Warna stroke E4E4E7
          width: 1, // Ketebalan stroke
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 90,
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(user.avatar),
              ),
              const SizedBox(width: 12),

              // Username & Email
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              OutlinedButton(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(
                    color: Color(0xFF5263F3),
                    width: 1.5
                  ),
                  foregroundColor: Color(0xFF5263F3),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize:
                        16,
                    fontWeight: FontWeight
                        .w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
