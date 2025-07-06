@echo off
echo =====================================
echo Rebuilding Aturin Widget Application
echo =====================================

echo.
echo [1/5] Cleaning project...
call flutter clean

echo.
echo [2/5] Getting dependencies...
call flutter pub get

echo.
echo [3/5] Building debug APK...
call flutter build apk --debug

echo.
echo [4/5] Installing on device...
call flutter install

echo.
echo [5/5] Done! Instructions:
echo - Open the app once
echo - Add the widget to your home screen
echo - If widget shows "cannot load" - restart your launcher:
echo   (go to Settings > Apps > Your launcher > Force stop)
echo.
echo Happy testing!
