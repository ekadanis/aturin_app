import 'package:aturin_app/features/home/services/task_service.dart';
import 'package:aturin_app/features/profile/database/profile_database.dart';
import 'package:aturin_app/features/profile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GreetingHeader extends StatelessWidget implements PreferredSizeWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileDatabase profileDb = ProfileDatabase();

    return FutureBuilder<User?>(
      future: profileDb.getUserById(1),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return const PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Center(child: Text("Gagal memuat data user")),
          );
        }

        final user = snapshot.data!;

        return AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          title: Row(
            children: [
              CircleAvatar(backgroundImage: AssetImage(user.avatar)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hallo, ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: user.username,
                          style: TextStyle(fontSize: 16, color: Colors.black),
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
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        TextSpan(
                          text: '${TaskService.tasks.length}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' Tugas',
                          style: TextStyle(fontSize: 16, color: Colors.black),
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
