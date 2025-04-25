import 'package:aturin_app/features/home/services/task_service.dart';
import 'package:aturin_app/features/profile/database/profile_database.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class GreetingHeader extends StatelessWidget implements PreferredSizeWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileDatabase profileDb = ProfileDatabase();

    return FutureBuilder<User?>(
      future: profileDb.getUserById(1),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Center(child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            )),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Center(child: Text(
              "Gagal memuat data user",
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.lightTextColor,
              ),
            )),
          );
        }

        final user = snapshot.data!;

        return AppBar(
          backgroundColor: AppTheme.lightBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 80, 
          title: Row(
            children: [
              // Membungkus CircleAvatar dengan Stack untuk menambahkan indikator online
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(user.avatar),
                    radius: 35,
                  ),
                  // Indikator online (dot hijau)
                  Positioned(
                    right: 0,
                    bottom: 5,
                    child: Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor, // Warna hijau untuk status online
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.lightBackgroundColor,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 26), 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hallo, ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: user.username,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, 
                            color: AppTheme.lightTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      
                      children: [
                        TextSpan(
                          text: 'Hari ini: ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, 
                            color: AppTheme.lightTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: '${TaskService.tasks.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: AppTheme.dangerColor,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        TextSpan(
                          text: ' Tugas',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, 
                            color: AppTheme.lightTextColor,
                             fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80); 
}
