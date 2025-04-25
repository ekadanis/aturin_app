import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';

@RoutePage()
class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      //Aku pake PopScope agar ketika jika user ada di task/profile page dan menekan tombol back,
      //maka ia akan kembali ke halaman home page. Baru kalau dari home page dan user menekan back
      //maka ia akan keluar dari aplikasi. Soalnya banyak aplikasi yang kek gini. Contohnya WA
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        return;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white
          ),
          child: const Center(
              child: Text(
                'Welcome to the Homies Page!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ),
        bottomNavigationBar: BottomNavbar(currentIndex: 0)
      ),
    );
  }
}