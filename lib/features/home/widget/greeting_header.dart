import 'package:aturin_app/features/home/services/task_service.dart' as home;
import 'package:aturin_app/features/profile/database/profile_database.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

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
            preferredSize: const Size.fromHeight(65),
            child: Center(child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            )),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return PreferredSize(
            preferredSize: const Size.fromHeight(65),
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
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 65,

          titleSpacing: 16,
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0), // Increased from 8.0 to add more space from notification area
            child: Row(
              children: [
                // Avatar dan dot hijau dengan ukuran lebih kecil
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(user.avatar),
                      radius: 28,  // Diperkecil dari 35
                    ),
                    Positioned(
                      right: 0,
                      bottom: 5,
                      child: Container(
                        height: 14, // Diperkecil dari 16
                        width: 14,  // Diperkecil dari 16
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lightBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20), // Diperkecil dari 26
                
                // Informasi user dan task count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama pengguna
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Hallo, ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,  // Diperkecil dari 15
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: user.username,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,  // Diperkecil dari 15 
                                color: AppTheme.lightTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),  // Diperkecil dari 4
                      
                      // Jumlah tugas hari ini (menggunakan Consumer dengan alias yang benar)
                      Consumer<home.TaskService>(
                        builder: (context, taskService, _) {
                          final tasksCount = taskService.getTodayTasksCount();
                          
                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Hari ini: ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,  // Diperkecil dari 16
                                    color: AppTheme.lightTextColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text: '$tasksCount',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,  // Diperkecil dari 16
                                    color: AppTheme.dangerColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Tugas',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,  // Diperkecil dari 16
                                    color: AppTheme.lightTextColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);  // Increased from 65 to accommodate the extra top padding
}
