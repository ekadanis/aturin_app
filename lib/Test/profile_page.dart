// import 'package:flutter/material.dart';
// import 'package:auto_route/auto_route.dart'; 

// import 'package:aturin_app/routers/app_router.dart';
// import 'package:aturin_app/core/widgets/bottom_navbar.dart';

// @RoutePage()
// class 1ProfilePage extends StatelessWidget {
//   const 1ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       //Aku pake PopScope agar ketika jika user ada di task/profile page dan menekan tombol back,
//       //maka ia akan kembali ke halaman home page. Baru kalau dari home page dan user menekan back
//       //maka ia akan keluar dari aplikasi. Soalnya banyak aplikasi yang kek gini. Contohnya WA
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) return;

//         context.router.pushAndPopUntil(
//           const HomeRoute(),
//           predicate: (_) => false
//         );

//         return;
//       },
//       child: Scaffold(
//         body: Container(
//           decoration: BoxDecoration(
//             color: Colors.white
//           ),
//           child: const Center(
//             child: Text(
//               'Welcome to the Ussr Page!',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         bottomNavigationBar: BottomNavbar(currentIndex: 2)
//       ),
//     );
//   }
// }