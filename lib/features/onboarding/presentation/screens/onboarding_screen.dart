import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:aturin_app/shared/core/infrastructure/routers/app_router.dart';
import 'package:aturin_app/features/onboarding/data/models/on_boarding_content.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int currentPage = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _storeOnboardInfo() async {
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);

    if (!mounted) return;

    await context.router.replace(const LoginRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientationm, deviceType) {
        return Scaffold(
          body: Container(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  SizedBox(
                    height: 65.h,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: contents.length,
                      onPageChanged: (int page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7.w),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 40.h,
                                child: Center(
                                  child: Lottie.asset(
                                    contents[index].image,
                                    fit: BoxFit.contain,
                                    height: 40.h,
                                    width: 80.w,
                                    repeat: true,
                                    animate: true,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                overflow: TextOverflow.visible,
                                contents[index].title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24.sp,
                                  height: 1.3,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                child: Text(
                                  overflow: TextOverflow.visible,
                                  contents[index].description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18.sp,
                                    height: 1.5,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  DotsIndicator(
                    dotsCount: contents.length,
                    position: currentPage.toDouble(),
                    decorator: DotsDecorator(
                      activeColor: AppTheme.primaryColor,
                      activeSize: const Size(40, 10),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      size: const Size(10, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                  Container(
                    height: 12.h,
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 50.w,
                          height: 6.h,
                          child: ElevatedButtonTheme(
                            data: ElevatedButtonThemeData(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (currentPage == contents.length - 1) {
                                  await _storeOnboardInfo();
                                }
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                              ),
                              child: Text(
                                currentPage == contents.length - 1
                                    ? "Mulai"
                                    : "Lanjut",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6.h,
                          child:
                              currentPage > 0
                                  ? TextButtonTheme(
                                    data: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                        backgroundColor: Colors.transparent,
                                        overlayColor: Colors.transparent,
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Text(
                                        "Sebelumnya",
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  )
                                  : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
