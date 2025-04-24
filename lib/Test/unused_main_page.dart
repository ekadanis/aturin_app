/*
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:aturin_app/Test/home_page.dart';
import 'package:aturin_app/Test/task_page.dart';
import 'package:aturin_app/Test/profile_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TaskPage(),
    const ProfilePage(),
  ];

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
            SafeArea(child: _pages[_currentIndex]),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 10.0,
                color: Color.fromARGB(255, 82, 99, 243),
                offset: Offset(0, 7)
              ),
            ],
          ),
          child: BottomNavbar(
            currentIndex: _currentIndex,
            onIndexChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
*/